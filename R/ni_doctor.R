#' Run runtime diagnostics
#'
#' Performs quick checks for runtime binaries, mount roots, profile shape, and
#' lockfile availability/consistency.
#'
#' @param cfg Optional resolved config list. Defaults to current effective
#'   config.
#' @param strict Logical; if `TRUE`, abort on any failed checks.
#' @param check_lock Logical; include lockfile checks.
#' @return Data frame with `check`, `status`, and `message` columns.
#' @export
ni_doctor <- function(cfg = NULL, strict = FALSE, check_lock = TRUE) {
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
  add_check("docker_bin", if (!is.null(ni_which_or_null(docker_bin))) "pass" else "warn",
            if (!is.null(ni_which_or_null(docker_bin))) sprintf("Found: %s", docker_bin) else sprintf("Not found: %s", docker_bin))
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
