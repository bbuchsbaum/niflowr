#' Run runtime diagnostics
#'
#' Performs quick checks for runtime binaries, mount roots, profile shape, and
#' lockfile availability/consistency. When Docker is available, optionally
#' probes each profile image to confirm the payload command actually runs
#' (catching shell ENTRYPOINTs that silently ignore the command).
#'
#' @param cfg Optional resolved config list. Defaults to current effective
#'   config.
#' @param strict Logical; if `TRUE`, abort on any failed checks.
#' @param check_lock Logical; include lockfile checks.
#' @param check_payload Logical; when `TRUE` (default), probe configured Docker
#'   profile images that are already present locally to verify the payload
#'   command executes. Skips profiles whose images are not available locally
#'   (does not pull).
#' @return Data frame with `check`, `status`, and `message` columns.
#' @export
ni_doctor <- function(cfg = NULL, strict = FALSE, check_lock = TRUE,
                      check_payload = TRUE) {
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
  docker_path <- ni_which_or_null(docker_bin)
  add_check("docker_bin", if (!is.null(docker_path)) "pass" else "warn",
            if (!is.null(docker_path)) sprintf("Found: %s", docker_bin) else sprintf("Not found: %s", docker_bin))
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

      field_checks <- ni_doctor_profile_docker_fields(pr, p)
      for (fc in field_checks) {
        add_check(fc$check, fc$status, fc$message)
      }
    }
  }

  # Payload execution probes (local images only; no pulls)
  if (isTRUE(check_payload) && !is.null(docker_path) && length(prof_names) > 0) {
    for (p in prof_names) {
      pr <- cfg$profiles[[p]]
      has_docker <- !is.null(pr$docker_image) && nzchar(pr$docker_image)
      if (!has_docker) next

      probe <- ni_doctor_probe_docker_payload(cfg, p, pr)
      add_check(probe$check, probe$status, probe$message)
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

#' Validate optional per-profile Docker field shapes without aborting.
#' @keywords internal
ni_doctor_profile_docker_fields <- function(profile, profile_name) {
  out <- list()
  add <- function(check, status, message) {
    out[[length(out) + 1]] <<- list(check = check, status = status, message = message)
  }

  if (!is.null(profile$entrypoint)) {
    ok <- tryCatch({
      ni_normalize_docker_entrypoint(profile$entrypoint, profile = profile_name)
      TRUE
    }, error = function(e) FALSE)
    if (ok) {
      ep <- ni_normalize_docker_entrypoint(profile$entrypoint, profile = profile_name)
      msg <- if (identical(ep$value, "")) {
        "entrypoint clears image ENTRYPOINT."
      } else {
        sprintf("entrypoint=%s", ep$value)
      }
      add(paste0("profile.", profile_name, ".entrypoint"), "pass", msg)
    } else {
      add(
        paste0("profile.", profile_name, ".entrypoint"),
        "fail",
        "Invalid entrypoint; use a string (\"\" clears) or omit."
      )
    }
  }

  if (!is.null(profile$platform)) {
    ok <- tryCatch({
      ni_normalize_docker_platform(profile$platform, profile = profile_name)
      TRUE
    }, error = function(e) FALSE)
    if (ok) {
      plat <- ni_normalize_docker_platform(profile$platform, profile = profile_name)
      add(paste0("profile.", profile_name, ".platform"), "pass", sprintf("platform=%s", plat))
    } else {
      add(
        paste0("profile.", profile_name, ".platform"),
        "fail",
        "Invalid platform; use a non-empty string such as linux/amd64."
      )
    }
  }

  out
}

#' Probe whether a Docker profile image executes the payload command.
#'
#' Only runs against images already present locally (`docker image inspect`).
#' Does not pull. Detects shell ENTRYPOINTs that exit 0 while ignoring CMD.
#'
#' @keywords internal
ni_doctor_probe_docker_payload <- function(cfg, profile_name, profile,
                                           marker = "NIFLOWR_PROBE_OK",
                                           timeout = 30) {
  check_name <- paste0("profile.", profile_name, ".payload")
  image <- profile$docker_image

  bin <- cfg$docker$bin %||% "docker"
  inspect <- tryCatch(
    processx::run(bin, c("image", "inspect", image), error_on_status = FALSE, timeout = 10),
    error = function(e) list(status = 1L, stdout = "", stderr = conditionMessage(e))
  )
  inspect_out <- paste(inspect$stdout %||% "", collapse = "\n")
  # Require a real `docker image inspect` JSON payload so stub binaries (e.g.
  # tests that set docker.bin = "echo") do not false-pass.
  if (!identical(as.integer(inspect$status), 0L) || !grepl("^\\s*\\[", inspect_out)) {
    return(list(
      check = check_name,
      status = "warn",
      message = sprintf("Image not available locally; skipped payload probe: %s", image)
    ))
  }

  # Avoid inheriting user pull_policy for probes; never pull here.
  probe_cfg <- cfg
  probe_cfg$docker$pull_policy <- "never"
  # Empty user disables -u injection for the probe.
  probe_cfg$docker$user <- ""

  built <- tryCatch(
    ni_build_docker_argv(
      cfg = probe_cfg,
      image = image,
      payload_cmd = "echo",
      payload_args = marker,
      mounts = list(),
      workdir = "/",
      env = character(0),
      entrypoint = profile$entrypoint,
      platform = profile$platform,
      profile = profile_name
    ),
    error = function(e) e
  )
  if (inherits(built, "error")) {
    return(list(
      check = check_name,
      status = "fail",
      message = conditionMessage(built)
    ))
  }

  res <- tryCatch(
    processx::run(built$bin, built$argv, error_on_status = FALSE, timeout = timeout),
    error = function(e) list(status = 1L, stdout = "", stderr = conditionMessage(e))
  )

  stdout <- paste(res$stdout %||% "", collapse = "\n")
  stderr <- paste(res$stderr %||% "", collapse = "\n")
  status <- suppressWarnings(as.integer(res$status %||% 1L))
  if (length(status) != 1L || is.na(status)) status <- 1L

  if (identical(status, 0L) && grepl(marker, stdout, fixed = TRUE)) {
    return(list(
      check = check_name,
      status = "pass",
      message = "Payload command executes in container."
    ))
  }

  if (identical(status, 0L) && !grepl(marker, stdout, fixed = TRUE)) {
    return(list(
      check = check_name,
      status = "fail",
      message = paste0(
        "Container exited 0 but payload marker was missing; image ENTRYPOINT ",
        "likely ignores the command. Set profiles.", profile_name,
        ".entrypoint: \"\" (or a real executable) in niflowr.yml."
      )
    ))
  }

  detail <- trimws(paste(c(stderr, stdout), collapse = "\n"))
  if (!nzchar(detail)) detail <- sprintf("exit status %s", status)
  list(
    check = check_name,
    status = "fail",
    message = sprintf("Payload probe failed: %s", detail)
  )
}
