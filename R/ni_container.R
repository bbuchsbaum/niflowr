# Runtime and container execution helpers.
# Internal helpers for engine resolution, host->container path rewriting, and
# container argv construction.

#' @keywords internal
ni_which_or_null <- function(bin) {
  p <- Sys.which(bin)
  if (is.na(p) || p == "") NULL else unname(p)
}

#' @keywords internal
ni_norm <- function(path) {
  normalizePath(path, winslash = "/", mustWork = FALSE)
}

#' @keywords internal
ni_runtime_detect <- function(cfg, payload_cmd, engine_override = NULL) {
  engine <- engine_override %||% cfg$runtime$engine %||% "auto"
  if (!engine %in% c("auto", "native", "docker", "apptainer")) {
    cli::cli_abort("Unknown runtime engine: {.val {engine}}")
  }

  if (engine != "auto") return(engine)

  # Auto mode: native first if payload command exists.
  if (nzchar(Sys.which(payload_cmd))) return("native")

  prefer <- cfg$runtime$prefer %||% "apptainer"
  has_app <- !is.null(ni_which_or_null(cfg$apptainer$bin %||% "apptainer"))
  has_dok <- !is.null(ni_which_or_null(cfg$docker$bin %||% "docker"))

  if (identical(prefer, "apptainer") && has_app) return("apptainer")
  if (identical(prefer, "docker") && has_dok) return("docker")
  if (has_app) return("apptainer")
  if (has_dok) return("docker")

  cli::cli_abort(c(
    "Command {.code {payload_cmd}} not found on PATH.",
    "i" = "No container runtime available (apptainer/docker)."
  ))
}

#' @keywords internal
ni_prepare_mount_roots <- function(cfg) {
  in_root <- cfg$paths$in_root
  out_root <- cfg$paths$out_root
  work_root <- cfg$paths$work_root

  if (is.null(in_root) || is.null(out_root) || is.null(work_root)) {
    cli::cli_abort(c(
      "Container execution requires mounted host roots.",
      "i" = "Set `paths.in_root`, `paths.out_root`, and `paths.work_root` in niflowr.yml."
    ))
  }

  in_root <- ni_norm(in_root)
  out_root <- ni_norm(out_root)
  work_root <- ni_norm(work_root)

  if (!dir.exists(in_root)) {
    cli::cli_abort("Input mount root does not exist: {.path {in_root}}")
  }
  if (!dir.exists(out_root)) fs::dir_create(out_root)
  if (!dir.exists(work_root)) fs::dir_create(work_root)

  list(in_root = in_root, out_root = out_root, work_root = work_root)
}

#' @keywords internal
ni_mounts_from_cfg <- function(cfg) {
  roots <- ni_prepare_mount_roots(cfg)
  cin <- cfg$container_paths[["in"]] %||% "/in"
  cout <- cfg$container_paths[["out"]] %||% "/out"
  cwork <- cfg$container_paths[["work"]] %||% "/work"

  list(
    list(host = roots$in_root, cont = cin, mode = "ro"),
    list(host = roots$out_root, cont = cout, mode = "rw"),
    list(host = roots$work_root, cont = cwork, mode = "rw")
  )
}

#' @keywords internal
ni_relpath <- function(path, root) {
  if (is.null(root) || !nzchar(root)) return(NULL)

  path <- ni_norm(path)
  root <- ni_norm(root)
  root2 <- if (grepl("/$", root)) root else paste0(root, "/")

  if (!startsWith(path, root2)) return(NULL)

  escaped <- gsub("([\\^\\$\\.\\|\\(\\)\\[\\]\\*\\+\\?\\\\])", "\\\\\\1", root2)
  sub(paste0("^", escaped), "", path)
}

#' @keywords internal
ni_stage_unmapped_input <- function(host_path, cfg, roots) {
  if (!file.exists(host_path)) {
    cli::cli_abort(c(
      "Cannot stage missing path outside mounts: {.path {host_path}}",
      "i" = "Move path under mounted roots or disable container mode."
    ))
  }

  stage_dir <- cfg$paths$stage_dir %||% file.path(roots$work_root, "_stage")
  stage_dir <- ni_norm(stage_dir)
  fs::dir_create(stage_dir)

  if (is.null(ni_relpath(stage_dir, roots$work_root))) {
    cli::cli_abort(c(
      "paths.stage_dir must live under work_root for mapping.",
      "x" = "stage_dir: {.path {stage_dir}}",
      "i" = "work_root: {.path {roots$work_root}}"
    ))
  }

  tag <- substr(digest::digest(host_path, algo = "xxhash64"), 1, 12)
  staged <- file.path(stage_dir, paste0(tag, "_", basename(host_path)))
  ok <- file.copy(host_path, staged, overwrite = TRUE)
  if (!isTRUE(ok)) {
    cli::cli_abort("Failed to stage input file: {.path {host_path}}")
  }

  staged
}

#' @keywords internal
ni_map_host_to_container <- function(host_path, cfg) {
  roots <- ni_prepare_mount_roots(cfg)
  host_path <- ni_norm(host_path)

  cin <- cfg$container_paths[["in"]] %||% "/in"
  cout <- cfg$container_paths[["out"]] %||% "/out"
  cwork <- cfg$container_paths[["work"]] %||% "/work"

  if (!is.null(r <- ni_relpath(host_path, roots$in_root))) {
    return(file.path(cin, r, fsep = "/"))
  }
  if (!is.null(r <- ni_relpath(host_path, roots$out_root))) {
    return(file.path(cout, r, fsep = "/"))
  }
  if (!is.null(r <- ni_relpath(host_path, roots$work_root))) {
    return(file.path(cwork, r, fsep = "/"))
  }

  if (isTRUE(cfg$paths$stage_unmapped_inputs)) {
    staged <- ni_stage_unmapped_input(host_path, cfg, roots)
    rr <- ni_relpath(staged, roots$work_root)
    return(file.path(cwork, rr, fsep = "/"))
  }

  cli::cli_abort(c(
    "Path is outside mounted roots: {.path {host_path}}",
    "i" = "Expected under in_root/out_root/work_root.",
    "i" = "Move the path, expand mounts, or enable paths.stage_unmapped_inputs."
  ))
}

#' @keywords internal
ni_rewrite_values_for_container <- function(spec, values, cfg) {
  out <- values

  for (nm in names(spec$inputs)) {
    def <- spec$inputs[[nm]]
    val <- values[[nm]]
    if (is_missing_value(val)) next

    if (def$type %in% c("file", "dir")) {
      out[[nm]] <- ni_map_host_to_container(val, cfg)
      next
    }

    if (def$type == "list" && is.character(val)) {
      item_type <- def$items_type %||% "string"
      if (item_type %in% c("file", "dir")) {
        out[[nm]] <- unname(vapply(val, function(v) ni_map_host_to_container(v, cfg), character(1)))
        next
      }

      # Fail closed: avoid host path leakage when list item typing is missing.
      path_like <- vapply(val, function(v) {
        is.character(v) && (grepl("[/\\\\]", v) || grepl("^~", v) || file.exists(v))
      }, logical(1))
      if (any(path_like)) {
        cli::cli_abort(c(
          "List input {.arg {nm}} contains path-like values but `items_type` is not set.",
          "i" = "Set spec inputs.{nm}.items_type = 'file' (or 'dir') for container execution."
        ))
      }
    }
  }

  out
}

#' @keywords internal
ni_profile_resolve <- function(cfg, call) {
  profile <- call$runtime$profile %||% call$spec$runtime$profile
  if (is.null(profile) || !nzchar(profile)) {
    cli::cli_abort(c(
      "No runtime profile provided.",
      "i" = "Set `.profile` in ni_call() or `runtime.profile` in the spec."
    ))
  }

  prof <- cfg$profiles[[profile]]
  if (is.null(prof)) {
    cli::cli_abort(c(
      "Unknown runtime profile: {.val {profile}}",
      "i" = "Define it under `profiles` in niflowr.yml."
    ))
  }

  list(name = profile, config = prof)
}

#' @keywords internal
ni_apptainer_sif_path <- function(cfg, profile_name, profile_info) {
  roots <- ni_prepare_mount_roots(cfg)
  sif_dir <- cfg$apptainer$sif_dir %||% file.path(roots$work_root, "containers")
  sif_name <- profile_info$sif_name %||% paste0(gsub("[^A-Za-z0-9._-]", "-", profile_name), ".sif")
  fs::dir_create(sif_dir)
  ni_norm(file.path(sif_dir, sif_name))
}

#' @keywords internal
ni_apptainer_pull_if_needed <- function(cfg, sif_path, uri) {
  if (file.exists(sif_path)) return(invisible(sif_path))
  if (is.null(uri) || !nzchar(uri)) {
    cli::cli_abort("Cannot pull SIF: missing apptainer URI.")
  }

  bin <- cfg$apptainer$bin %||% "apptainer"
  if (is.null(ni_which_or_null(bin))) {
    cli::cli_abort("Apptainer binary not found: {.val {bin}}")
  }
  args <- c("pull", cfg$apptainer$pull_args %||% character(0), sif_path, uri)
  res <- processx::run(bin, args, error_on_status = FALSE)
  if (res$status != 0) {
    cli::cli_abort(c(
      "Apptainer pull failed.",
      "x" = "{res$stderr %||% res$stdout}"
    ))
  }
  invisible(sif_path)
}

#' @keywords internal
ni_resolve_apptainer_container_ref <- function(cfg, profile_name, profile_info) {
  use_sif <- isTRUE(cfg$apptainer$use_sif)
  uri <- profile_info$apptainer_uri
  if (is.null(uri) && !is.null(profile_info$docker_image)) {
    uri <- paste0("docker://", profile_info$docker_image)
  }

  if (!use_sif) {
    if (is.null(uri) || !nzchar(uri)) {
      cli::cli_abort("Profile is missing `apptainer_uri`.")
    }
    return(list(ref = uri, source = uri, sif = NULL))
  }

  sif <- ni_apptainer_sif_path(cfg, profile_name, profile_info)
  ni_apptainer_pull_if_needed(cfg, sif, uri)
  list(ref = sif, source = uri, sif = sif)
}

#' @keywords internal
ni_env_vector <- function(env) {
  if (is.null(env) || length(env) == 0) return(character(0))

  if (is.list(env)) {
    env <- unlist(env, use.names = TRUE)
  }
  if (is.null(names(env))) return(character(0))

  env <- as.character(env)
  names(env) <- names(env)
  env
}

#' @keywords internal
ni_build_docker_argv <- function(cfg, image, payload_cmd, payload_args, mounts, workdir, env) {
  if (is.null(image) || !nzchar(image)) {
    cli::cli_abort("Docker profile is missing `docker_image`.")
  }

  bin <- cfg$docker$bin %||% "docker"
  if (is.null(ni_which_or_null(bin))) {
    cli::cli_abort("Docker binary not found: {.val {bin}}")
  }
  pull_policy <- cfg$docker$pull_policy %||% "missing"
  extra <- as.character(cfg$docker$extra_run_args %||% character(0))

  argv <- c("run", "--rm", paste0("--pull=", pull_policy))

  for (m in mounts) {
    mount_kv <- c(
      "type=bind",
      paste0("src=", m$host),
      paste0("dst=", m$cont)
    )
    if (identical(m$mode, "ro")) mount_kv <- c(mount_kv, "readonly")
    argv <- c(argv, "--mount", paste(mount_kv, collapse = ","))
  }

  argv <- c(argv, "-w", workdir)

  user_cfg <- cfg$docker$user %||% "auto"
  if (identical(user_cfg, "auto") && .Platform$OS.type == "unix") {
    uid <- tryCatch(Sys.getuid(), error = function(e) NA_integer_)
    gid <- tryCatch(Sys.getgid(), error = function(e) NA_integer_)
    if (!is.na(uid) && !is.na(gid)) {
      argv <- c(argv, "-u", paste0(uid, ":", gid))
    }
  } else if (is.character(user_cfg) && nzchar(user_cfg) && !identical(user_cfg, "auto")) {
    argv <- c(argv, "-u", user_cfg)
  }

  if (length(env) > 0) {
    for (nm in names(env)) {
      argv <- c(argv, "-e", paste0(nm, "=", env[[nm]]))
    }
  }

  argv <- c(argv, extra, image, payload_cmd, payload_args)
  list(bin = bin, argv = as.character(argv))
}

#' @keywords internal
ni_build_apptainer_argv <- function(cfg, container_ref, payload_cmd, payload_args, mounts, workdir, env) {
  if (is.null(container_ref) || !nzchar(container_ref)) {
    cli::cli_abort("Apptainer container reference is missing.")
  }

  bin <- cfg$apptainer$bin %||% "apptainer"
  if (is.null(ni_which_or_null(bin))) {
    cli::cli_abort("Apptainer binary not found: {.val {bin}}")
  }
  argv <- c("exec")

  if (isTRUE(cfg$apptainer$cleanenv)) argv <- c(argv, "--cleanenv")
  if (isTRUE(cfg$apptainer$containall)) argv <- c(argv, "--containall")

  extra <- as.character(cfg$apptainer$extra_exec_args %||% character(0))
  argv <- c(argv, extra)

  for (m in mounts) {
    argv <- c(argv, "--bind", paste0(m$host, ":", m$cont, ":", m$mode))
  }

  argv <- c(argv, "--cwd", workdir)

  if (length(env) > 0) {
    for (nm in names(env)) {
      argv <- c(argv, "--env", paste0(nm, "=", env[[nm]]))
    }
  }

  argv <- c(argv, container_ref, payload_cmd, payload_args)
  list(bin = bin, argv = as.character(argv))
}

#' @keywords internal
ni_build_container_command <- function(engine, cfg, call, payload_cmd, payload_args, env) {
  profile <- ni_profile_resolve(cfg, call)
  mounts <- ni_mounts_from_cfg(cfg)
  workdir <- cfg$container_paths[["work"]] %||% "/work"
  lock_profile <- NULL
  if (isTRUE(cfg$runtime$lock_enforce)) {
    lock_profile <- ni_lock_profile_entry(cfg, profile$name)
  }

  if (identical(engine, "docker")) {
    image <- profile$config$docker_image
    if (isTRUE(cfg$runtime$lock_enforce)) {
      if (is.null(lock_profile$docker)) {
        cli::cli_abort("Lockfile profile {.val {profile$name}} has no docker entry.")
      }
      image <- lock_profile$docker$resolved_ref %||% lock_profile$docker$configured_ref
      if (is.null(image) || !nzchar(image)) {
        cli::cli_abort("Lockfile profile {.val {profile$name}} has no usable docker reference.")
      }
    }
    built <- ni_build_docker_argv(cfg, image, payload_cmd, payload_args, mounts, workdir, env)
    return(list(
      engine = "docker",
      profile = profile$name,
      profile_config = profile$config,
      container_ref = image,
      bin = built$bin,
      argv = built$argv,
      mounts = mounts
    ))
  }

  if (identical(engine, "apptainer")) {
    if (isTRUE(cfg$runtime$lock_enforce)) {
      if (is.null(lock_profile$apptainer)) {
        cli::cli_abort("Lockfile profile {.val {profile$name}} has no apptainer entry.")
      }

      lock_app <- lock_profile$apptainer
      locked_sif <- lock_app$sif_path
      locked_ref <- lock_app$resolved_ref %||% lock_app$configured_uri
      locked_uri <- lock_app$configured_uri %||% NULL

      if (!is.null(locked_sif) && nzchar(locked_sif)) {
        # Keep lock-enforced SIF paths bootstrappable by pulling from locked URI.
        if (!file.exists(locked_sif) && !is.null(locked_uri) && nzchar(locked_uri)) {
          ni_apptainer_pull_if_needed(cfg, locked_sif, locked_uri)
        }
        ref <- list(ref = locked_sif, source = locked_uri %||% locked_ref, sif = locked_sif)
      } else {
        if (is.null(locked_ref) || !nzchar(locked_ref)) {
          cli::cli_abort("Lockfile profile {.val {profile$name}} has no usable apptainer reference.")
        }
        ref <- list(ref = locked_ref, source = locked_uri %||% locked_ref, sif = NULL)
      }
    } else {
      ref <- ni_resolve_apptainer_container_ref(cfg, profile$name, profile$config)
    }
    built <- ni_build_apptainer_argv(cfg, ref$ref, payload_cmd, payload_args, mounts, workdir, env)
    return(list(
      engine = "apptainer",
      profile = profile$name,
      profile_config = profile$config,
      container_ref = ref$ref,
      container_source = ref$source,
      sif_path = ref$sif,
      bin = built$bin,
      argv = built$argv,
      mounts = mounts
    ))
  }

  cli::cli_abort("Unsupported container engine: {.val {engine}}")
}
