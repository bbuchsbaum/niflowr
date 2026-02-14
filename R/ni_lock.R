#' Create/update a runtime lockfile
#'
#' Resolves configured runtime profiles and writes a lockfile that captures the
#' pinned references used for reproducible execution.
#'
#' @param path Lockfile path. Defaults to `runtime.lockfile` in config (or
#'   `"niflowr.lock.yml"`).
#' @param cfg Optional resolved config list. Defaults to current effective
#'   config.
#' @param profiles Optional subset of profile names to lock. Defaults to all
#'   configured profiles.
#' @param pull Logical; allow pulling/resolving container artifacts when needed.
#' @param include_specs Logical; include spec id/version/profile index.
#' @return Parsed lock object (invisibly).
#' @export
ni_pin <- function(path = NULL, cfg = NULL, profiles = NULL,
                   pull = TRUE, include_specs = TRUE) {
  cfg <- cfg %||% ni_config_resolve()
  path <- path %||% (cfg$runtime$lockfile %||% "niflowr.lock.yml")

  profile_names <- profiles %||% names(cfg$profiles)
  if (length(profile_names) == 0) {
    cli::cli_abort("No profiles configured; nothing to pin.")
  }

  out_profiles <- list()

  for (pname in profile_names) {
    p <- cfg$profiles[[pname]]
    if (is.null(p)) {
      cli::cli_abort("Unknown profile in ni_pin(): {.val {pname}}")
    }

    entry <- list()

    if (!is.null(p$docker_image)) {
      entry$docker <- ni_pin_docker_entry(cfg, p$docker_image, pull = pull)
    }

    uri <- p$apptainer_uri
    if (is.null(uri) && !is.null(p$docker_image)) {
      uri <- paste0("docker://", p$docker_image)
    }
    if (!is.null(uri) || isTRUE(cfg$apptainer$use_sif)) {
      entry$apptainer <- ni_pin_apptainer_entry(cfg, pname, p, pull = pull)
    }

    out_profiles[[pname]] <- entry
  }

  lock <- list(
    lock_version = "0.1",
    generated_at_utc = format(Sys.time(), tz = "UTC", usetz = TRUE),
    runtime = list(
      engine = cfg$runtime$engine %||% "auto",
      prefer = cfg$runtime$prefer %||% "apptainer"
    ),
    profiles = out_profiles
  )

  if (isTRUE(include_specs)) {
    lock$specs <- ni_collect_spec_index()
  }

  ni_lock_write(lock, path = path)
  invisible(lock)
}

#' Read lockfile
#'
#' @param path Lockfile path. Defaults to config `runtime.lockfile`.
#' @return Parsed lockfile list.
#' @export
ni_lock_read <- function(path = NULL) {
  path <- path %||% (ni_config_get("runtime.lockfile", "niflowr.lock.yml"))
  if (!file.exists(path)) {
    cli::cli_abort("Lockfile not found: {.path {path}}")
  }
  if (!requireNamespace("yaml", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg yaml} is required to read lockfiles.")
  }
  lock <- yaml::read_yaml(path)
  if (is.null(lock)) list() else lock
}

#' Validate current runtime config against lockfile
#'
#' @param path Lockfile path. Defaults to config `runtime.lockfile`.
#' @param cfg Optional resolved config list. Defaults to current effective
#'   config.
#' @param profiles Optional subset of profile names to validate.
#' @param strict Logical; if `TRUE`, abort on any validation failures.
#' @param check_sif Logical; verify SIF file existence/checksum when present.
#' @return Data frame with validation checks.
#' @export
ni_lock_validate <- function(path = NULL, cfg = NULL, profiles = NULL,
                             strict = FALSE, check_sif = TRUE) {
  cfg <- cfg %||% ni_config_resolve()
  path <- path %||% (cfg$runtime$lockfile %||% "niflowr.lock.yml")

  checks <- list()
  add_check <- function(profile, check, status, message) {
    checks[[length(checks) + 1]] <<- data.frame(
      profile = profile,
      check = check,
      status = status,
      message = message,
      stringsAsFactors = FALSE
    )
  }

  if (!file.exists(path)) {
    add_check("*", "lockfile_exists", "fail", paste("Missing lockfile:", path))
    out <- ni_lock_checks_df(checks)
    if (strict) ni_lock_abort_if_failed(out, path)
    return(out)
  }

  lock <- ni_lock_read(path)
  lock_profiles <- lock$profiles %||% list()
  profile_names <- profiles %||% names(cfg$profiles)

  for (pname in profile_names) {
    cfg_p <- cfg$profiles[[pname]]
    lock_p <- lock_profiles[[pname]]

    if (is.null(cfg_p)) {
      add_check(pname, "profile_config_present", "fail", "Profile missing in current config.")
      next
    }
    if (is.null(lock_p)) {
      add_check(pname, "profile_locked", "fail", "Profile missing in lockfile.")
      next
    }

    cfg_docker <- cfg_p$docker_image
    if (!is.null(cfg_docker)) {
      locked_cfg <- lock_p$docker$configured_ref %||% NA_character_
      if (identical(cfg_docker, locked_cfg)) {
        add_check(pname, "docker_configured_ref", "pass", "Docker configured ref matches lock.")
      } else {
        add_check(
          pname, "docker_configured_ref", "fail",
          sprintf("Docker configured ref mismatch (cfg=%s lock=%s).", cfg_docker, locked_cfg)
        )
      }
    }

    cfg_uri <- cfg_p$apptainer_uri
    if (is.null(cfg_uri) && !is.null(cfg_docker)) cfg_uri <- paste0("docker://", cfg_docker)
    if (!is.null(cfg_uri)) {
      locked_uri <- lock_p$apptainer$configured_uri %||% NA_character_
      if (identical(cfg_uri, locked_uri)) {
        add_check(pname, "apptainer_configured_uri", "pass", "Apptainer configured URI matches lock.")
      } else {
        add_check(
          pname, "apptainer_configured_uri", "fail",
          sprintf("Apptainer URI mismatch (cfg=%s lock=%s).", cfg_uri, locked_uri)
        )
      }
    }

    if (isTRUE(check_sif)) {
      sif_path <- lock_p$apptainer$sif_path
      sif_sha <- lock_p$apptainer$sif_sha256
      if (!is.null(sif_path)) {
        if (file.exists(sif_path)) {
          add_check(pname, "sif_exists", "pass", "SIF path exists.")
          if (!is.null(sif_sha)) {
            cur <- ni_sha256_file(sif_path)
            if (identical(cur, sif_sha)) {
              add_check(pname, "sif_sha256", "pass", "SIF checksum matches lock.")
            } else {
              add_check(
                pname, "sif_sha256", "fail",
                sprintf("SIF checksum mismatch (current=%s lock=%s).", cur, sif_sha)
              )
            }
          }
        } else {
          add_check(pname, "sif_exists", "fail", sprintf("SIF path missing: %s", sif_path))
        }
      }
    }
  }

  out <- ni_lock_checks_df(checks)
  if (strict) ni_lock_abort_if_failed(out, path)
  out
}

#' @keywords internal
ni_lock_write <- function(lock, path) {
  if (!requireNamespace("yaml", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg yaml} is required to write lockfiles.")
  }
  fs::dir_create(fs::path_dir(path))
  yaml::write_yaml(lock, file = path)
  invisible(path)
}

#' @keywords internal
ni_lock_checks_df <- function(checks) {
  if (length(checks) == 0) {
    return(data.frame(
      profile = character(0),
      check = character(0),
      status = character(0),
      message = character(0),
      stringsAsFactors = FALSE
    ))
  }
  do.call(rbind, checks)
}

#' @keywords internal
ni_lock_abort_if_failed <- function(df, path) {
  bad <- df[df$status == "fail", , drop = FALSE]
  if (nrow(bad) == 0) return(invisible(TRUE))
  top <- paste(utils::head(sprintf("%s [%s] %s", bad$profile, bad$check, bad$message), 10), collapse = "\n")
  cli::cli_abort(c(
    "Lock validation failed against {.path {path}}.",
    "x" = "{top}"
  ))
}

#' @keywords internal
ni_pin_docker_entry <- function(cfg, image, pull = TRUE) {
  out <- list(
    configured_ref = image,
    resolved_ref = image,
    digest = ni_ref_digest(image),
    resolved = !is.null(ni_ref_digest(image))
  )

  if (out$resolved) return(out)

  bin <- cfg$docker$bin %||% "docker"
  if (is.null(ni_which_or_null(bin))) {
    out$note <- "docker binary unavailable; unresolved non-digest tag."
    return(out)
  }

  if (isTRUE(pull)) {
    processx::run(bin, c("pull", image), error_on_status = FALSE)
  }

  inspect <- processx::run(
    bin,
    c("image", "inspect", image, "--format", "{{index .RepoDigests 0}}"),
    error_on_status = FALSE
  )
  candidate <- trimws(inspect$stdout %||% "")
  if (inspect$status == 0 && nzchar(candidate) && !grepl("<no value>", candidate, fixed = TRUE)) {
    out$resolved_ref <- candidate
    out$digest <- ni_ref_digest(candidate)
    out$resolved <- !is.null(out$digest)
  } else {
    out$note <- "could not resolve docker digest from local daemon."
  }

  out
}

#' @keywords internal
ni_pin_apptainer_entry <- function(cfg, profile_name, profile_info, pull = TRUE) {
  uri <- profile_info$apptainer_uri
  if (is.null(uri) && !is.null(profile_info$docker_image)) {
    uri <- paste0("docker://", profile_info$docker_image)
  }

  out <- list(
    configured_uri = uri,
    resolved_ref = uri,
    digest = ni_ref_digest(uri)
  )

  if (!isTRUE(cfg$apptainer$use_sif)) {
    return(out)
  }

  sif_path <- tryCatch(
    ni_apptainer_sif_path(cfg, profile_name, profile_info),
    error = function(e) NULL
  )
  if (is.null(sif_path)) {
    out$note <- "SIF path unresolved (mount roots not configured)."
    return(out)
  }
  out$sif_path <- sif_path
  out$resolved_ref <- sif_path

  bin <- cfg$apptainer$bin %||% "apptainer"
  has_bin <- !is.null(ni_which_or_null(bin))
  if (!has_bin) {
    out$note <- "apptainer binary unavailable; SIF not resolved."
    return(out)
  }

  if (isTRUE(pull)) {
    if (!is.null(uri) && nzchar(uri)) {
      ni_apptainer_pull_if_needed(cfg, sif_path, uri)
    }
  }

  if (file.exists(sif_path)) {
    out$sif_sha256 <- ni_sha256_file(sif_path)
  }

  out
}

#' @keywords internal
ni_lock_profile_entry <- function(cfg, profile) {
  lock_path <- cfg$runtime$lockfile %||% "niflowr.lock.yml"
  if (!file.exists(lock_path)) {
    cli::cli_abort(c(
      "Lock enforcement is enabled, but lockfile is missing.",
      "x" = "{.path {lock_path}}"
    ))
  }

  lock <- ni_lock_read(lock_path)
  lp <- lock$profiles[[profile]]
  if (is.null(lp)) {
    cli::cli_abort("Profile {.val {profile}} is not present in lockfile {.path {lock_path}}.")
  }
  lp
}

#' @keywords internal
ni_collect_spec_index <- function() {
  ids <- sort(ni_spec_list())
  out <- vector("list", length(ids))
  names(out) <- ids

  for (id in ids) {
    sp <- ni_spec_read(id)
    out[[id]] <- list(
      spec_version = sp$spec_version %||% NA_character_,
      profile = sp$runtime$profile %||% NA_character_
    )
  }

  out
}

#' @keywords internal
ni_ref_digest <- function(ref) {
  if (is.null(ref) || !nzchar(ref)) return(NULL)
  m <- regexpr("@sha256:[A-Fa-f0-9]{64}$", ref)
  if (m[1] < 0) return(NULL)
  tolower(sub("^@", "", substr(ref, m[1], nchar(ref))))
}

#' @keywords internal
ni_sha256_file <- function(path) {
  tolower(digest::digest(file = path, algo = "sha256"))
}

#' @keywords internal
ni_lock_enforce_profile <- function(cfg, engine, profile, container_ref = NULL, container_source = NULL, sif_path = NULL) {
  enforce <- isTRUE(cfg$runtime$lock_enforce)
  if (!enforce) return(invisible(TRUE))

  lp <- ni_lock_profile_entry(cfg, profile)

  if (identical(engine, "docker")) {
    expected <- lp$docker$resolved_ref %||% lp$docker$configured_ref
    if (!is.null(expected) && !identical(expected, container_ref)) {
      cli::cli_abort(c(
        "Lock enforcement failed for profile {.val {profile}} (docker).",
        "x" = "Expected: {.val {expected}}",
        "x" = "Actual: {.val {container_ref}}"
      ))
    }
  }

  if (identical(engine, "apptainer")) {
    expected <- lp$apptainer$resolved_ref %||% lp$apptainer$configured_uri
    actual <- container_ref %||% container_source
    if (!is.null(expected) && !identical(expected, actual)) {
      cli::cli_abort(c(
        "Lock enforcement failed for profile {.val {profile}} (apptainer).",
        "x" = "Expected: {.val {expected}}",
        "x" = "Actual: {.val {actual}}"
      ))
    }

    expected_sif <- lp$apptainer$sif_path
    expected_sha <- lp$apptainer$sif_sha256
    if (!is.null(expected_sif)) {
      if (!file.exists(expected_sif)) {
        cli::cli_abort("Locked SIF path does not exist: {.path {expected_sif}}")
      }
      if (!is.null(expected_sha)) {
        cur <- ni_sha256_file(expected_sif)
        if (!identical(cur, expected_sha)) {
          cli::cli_abort(c(
            "Locked SIF checksum mismatch for profile {.val {profile}}.",
            "x" = "Expected: {.val {expected_sha}}",
            "x" = "Actual: {.val {cur}}"
          ))
        }
      }
    } else if (!is.null(sif_path) && !file.exists(sif_path)) {
      cli::cli_abort("Resolved SIF path does not exist: {.path {sif_path}}")
    }
  }

  invisible(TRUE)
}
