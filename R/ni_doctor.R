#' Run runtime diagnostics
#'
#' Performs quick checks for runtime binaries, mount roots, profile shape, and
#' lockfile availability/consistency. When `probe_profiles = TRUE` and Docker is
#' available, profiles with a local `docker_image` are probed with a short
#' `true` command so a wrapping image ENTRYPOINT cannot silently ignore the
#' payload.
#'
#' @param cfg Optional resolved config list. Defaults to current effective
#'   config.
#' @param strict Logical; if `TRUE`, abort on any failed checks.
#' @param check_lock Logical; include lockfile checks.
#' @param probe_profiles Logical; if `TRUE` (default), probe local Docker images
#'   so entrypoint/platform misconfiguration is caught early.
#' @return Data frame with `check`, `status`, and `message` columns.
#' @export
ni_doctor <- function(cfg = NULL, strict = FALSE, check_lock = TRUE,
                      probe_profiles = TRUE) {
  cfg <- cfg %||% ni_config_resolve()
  checks <- list()

  add_check <- function(check, status, message) {
    checks[[length(checks) + 1]] <<- data.frame(
      check = check,
      status = status,
      message = message,
      stringsAsFactors = FALSE
    )
  }

  # Runtime binaries
  docker_bin <- cfg$docker$bin %||% "docker"
  apptainer_bin <- cfg$apptainer$bin %||% "apptainer"
  docker_ok <- !is.null(ni_which_or_null(docker_bin))
  add_check("docker_bin", if (docker_ok) "pass" else "warn",
            if (docker_ok) sprintf("Found: %s", docker_bin) else sprintf("Not found: %s", docker_bin))
  add_check("apptainer_bin", if (!is.null(ni_which_or_null(apptainer_bin))) "pass" else "warn",
            if (!is.null(ni_which_or_null(apptainer_bin))) sprintf("Found: %s", apptainer_bin) else sprintf("Not found: %s", apptainer_bin))

  # Mount roots
  in_root <- cfg$paths$in_root
  out_root <- cfg$paths$out_root
  work_root <- cfg$paths$work_root
  add_check("paths.in_root", if (!is.null(in_root) && dir.exists(in_root)) "pass" else "fail",
            if (!is.null(in_root)) sprintf("in_root=%s", in_root) else "in_root not configured")
  add_check("paths.out_root", if (!is.null(out_root) && dir.exists(out_root)) "pass" else "warn",
            if (!is.null(out_root)) sprintf("out_root=%s", out_root) else "out_root not configured")
  add_check("paths.work_root", if (!is.null(work_root) && dir.exists(work_root)) "pass" else "warn",
            if (!is.null(work_root)) sprintf("work_root=%s", work_root) else "work_root not configured")

  # Profiles
  prof_names <- names(cfg$profiles)
  if (length(prof_names) == 0) {
    add_check("profiles", "fail", "No runtime profiles configured.")
  } else {
    add_check("profiles", "pass", sprintf("%d profiles configured.", length(prof_names)))
    for (p in prof_names) {
      pr <- cfg$profiles[[p]]
      has_docker <- !is.null(pr$docker_image) && nzchar(pr$docker_image)
      has_appt <- (!is.null(pr$apptainer_uri) && nzchar(pr$apptainer_uri)) || has_docker
      if (!has_docker && !has_appt) {
        add_check(paste0("profile.", p), "fail", "Missing docker_image/apptainer_uri.")
      } else {
        add_check(paste0("profile.", p), "pass", "Profile has container reference(s).")
      }

      if (!is.null(pr$platform) && !(is.character(pr$platform) && length(pr$platform) == 1L && nzchar(pr$platform))) {
        add_check(paste0("profile.", p, ".platform"), "fail",
                  "`platform` must be a non-empty string (e.g. linux/amd64).")
      } else if (!is.null(pr$platform)) {
        add_check(paste0("profile.", p, ".platform"), "pass",
                  sprintf("platform=%s", pr$platform))
      }

      if (!is.null(pr$entrypoint)) {
        ep <- tryCatch(ni_profile_entrypoint(pr$entrypoint), error = function(e) NULL)
        if (is.null(ep)) {
          add_check(paste0("profile.", p, ".entrypoint"), "fail",
                    "`entrypoint` must be a string or character vector.")
        } else {
          add_check(paste0("profile.", p, ".entrypoint"), "pass",
                    sprintf("entrypoint=%s", if (identical(ep, "")) '""' else ep))
        }
      }

      if (isTRUE(probe_profiles) && has_docker && docker_ok) {
        probe <- ni_doctor_probe_docker_profile(cfg, p, pr)
        add_check(paste0("profile.", p, ".probe"), probe$status, probe$message)
      }
    }
  }

  # Lock checks
  if (isTRUE(check_lock)) {
    lock_path <- cfg$runtime$lockfile %||% "niflowr.lock.yml"
    if (file.exists(lock_path)) {
      add_check("lockfile.exists", "pass", sprintf("Found lockfile: %s", lock_path))
      lv <- ni_lock_validate(path = lock_path, cfg = cfg, strict = FALSE, check_sif = FALSE)
      if (nrow(lv) == 0 || all(lv$status != "fail")) {
        add_check("lockfile.validate", "pass", "Lockfile is consistent with current config.")
      } else {
        add_check("lockfile.validate", "warn", "Lockfile exists but has mismatches.")
      }
    } else {
      add_check("lockfile.exists", if (isTRUE(cfg$runtime$lock_enforce)) "fail" else "warn",
                sprintf("Lockfile not found: %s", lock_path))
    }
  }

  out <- do.call(rbind, checks)
  if (isTRUE(strict) && any(out$status == "fail")) {
    top <- paste(utils::head(sprintf("%s: %s", out$check[out$status == "fail"], out$message[out$status == "fail"]), 10), collapse = "\n")
    cli::cli_abort(c(
      "ni_doctor found failing checks.",
      "x" = "{top}"
    ))
  }

  out
}

#' Probe that a Docker profile actually executes a payload command
#'
#' Runs `true` inside the profile image with the same `--platform` /
#' `--entrypoint` flags `ni_run` would use. Skips when the image is not present
#' locally so doctor stays offline-friendly.
#'
#' @keywords internal
ni_doctor_probe_docker_profile <- function(cfg, profile_name, profile_cfg,
                                           timeout = 15) {
  image <- profile_cfg$docker_image
  bin <- cfg$docker$bin %||% "docker"

  inspect <- tryCatch(
    processx::run(bin, c("image", "inspect", image), error_on_status = FALSE, timeout = 10),
    error = function(e) list(status = 1L, stderr = conditionMessage(e), timeout = grepl("timeout", conditionMessage(e), ignore.case = TRUE))
  )
  if (!identical(inspect$status, 0L)) {
    return(list(
      status = "warn",
      message = sprintf("Image not local (%s); skip runtime probe.", image)
    ))
  }

  argv <- c("run", "--rm", "--pull=never")
  if (is.character(profile_cfg$platform) && length(profile_cfg$platform) == 1L &&
      nzchar(profile_cfg$platform)) {
    argv <- c(argv, "--platform", profile_cfg$platform)
  }
  entrypoint <- ni_profile_entrypoint(profile_cfg$entrypoint)
  if (!is.null(entrypoint)) {
    argv <- c(argv, "--entrypoint", entrypoint)
  }
  argv <- c(argv, image, "true")

  result <- tryCatch(
    processx::run(bin, argv, error_on_status = FALSE, timeout = timeout),
    error = function(e) {
      list(
        status = NA_integer_,
        stdout = "",
        stderr = conditionMessage(e),
        timeout = grepl("timeout", conditionMessage(e), ignore.case = TRUE)
      )
    }
  )

  if (isTRUE(result$timeout) || (is.na(result$status) && grepl("timeout", result$stderr %||% "", ignore.case = TRUE))) {
    return(list(
      status = "fail",
      message = sprintf(
        "Payload command timed out after %ss. Image ENTRYPOINT may wrap a shell; set profiles.%s.entrypoint (often \"\") and/or platform.",
        timeout, profile_name
      )
    ))
  }

  if (!identical(as.integer(result$status), 0L)) {
    detail <- trimws(paste(result$stderr %||% "", result$stdout %||% ""))
    if (!nzchar(detail)) detail <- sprintf("exit status %s", result$status %||% "NA")
    return(list(
      status = "fail",
      message = sprintf(
        "Payload `true` failed under profile entrypoint/platform: %s",
        detail
      )
    ))
  }

  list(status = "pass", message = "Payload command runs under profile entrypoint/platform.")
}
