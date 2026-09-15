#' Resolve an inspectable execution plan
#'
#' Resolves the selected engine, environment overrides (configuration < spec <
#' call), working directories, mounts, payload and execution argv. No workload
#' is launched. Mount directories may be created and unmapped inputs staged.
#' @param call An `ni_call` object.
#' @return An `ni_execution_plan` list, also returned by `ni_run(dry_run = TRUE)`.
#' @export
ni_plan <- function(call) {
  stopifnot(inherits(call, "ni_call"))
  cfg <- ni_config_resolve()
  runtime <- call$runtime %||% list()
  payload_host <- build_command(call)
  engine <- ni_runtime_detect(cfg, payload_host$command, runtime$engine %||% call$spec$runtime$engine)
  wd <- runtime$cwd %||% call$spec$runtime$cwd %||%
    if (engine == "native") getwd() else cfg$paths$work_root
  wd <- ni_norm(wd)
  env <- ni_env_vector(c(cfg$env %||% list(), call$spec$runtime$env %||% list(), runtime$env %||% list()))
  # Anchor every typed path before host/container rendering and identity capture.
  call$values <- ni_absolute_values(call$spec, call$values, wd)
  call$outputs <- lapply(call$outputs, function(x) as.character(fs::path_abs(x, start = wd)))
  payload_host <- build_command(call)
  built <- NULL
  payload_exec <- payload_host
  if (engine == "native") {
    fs::dir_create(wd)
    execution <- list(command = payload_host$command, args = payload_host$args, cwd = wd)
  } else {
    mapped <- call
    mapped$values <- ni_rewrite_values_for_container(call$spec, call$values, cfg)
    payload_exec <- build_command(mapped)
    built <- ni_build_container_command(engine, cfg, call, payload_exec$command, payload_exec$args, env, prepare = FALSE)
    ni_lock_enforce_profile(cfg, engine, built$profile, built$container_ref,
                           built$container_source %||% NULL, built$sif_path %||% NULL)
    for (nm in names(call$outputs)) {
      if (!isTRUE(call$spec$outputs[[nm]]$must_exist)) next
      for (path in call$outputs[[nm]]) {
        matches <- Filter(function(m) !is.null(ni_relpath(path, m$host)), built$mounts)
        if (!length(matches)) cli::cli_abort("Required output is outside mounted roots: {.path {path}}")
        mount <- matches[[which.max(vapply(matches, function(m) nchar(m$host), integer(1)))]]
        if (!identical(mount$mode, "rw")) cli::cli_abort("Required output is on a read-only mount: {.path {path}}")
      }
    }
    execution <- list(command = built$bin, args = built$argv, cwd = NULL)
    wd <- built$host_cwd
  }
  # Environment settings are overrides to the inherited host environment for
  # native execution; containers receive the explicit values as runtime flags.
  source_identity <- ni_source_identity()
  structure(list(
    engine = engine, environment = as.list(env), host_cwd = wd,
    container_cwd = built$container_cwd, mounts = built$mounts %||% list(),
    profile = built$profile, profile_config = built$profile_config,
    image_identity = if (engine == "docker") tryCatch({
      info <- processx::run(built$bin, c("image", "inspect", built$container_ref), timeout = 5, error_on_status = FALSE)
      if (info$status != 0) NULL else {
        image <- jsonlite::fromJSON(info$stdout, simplifyVector = FALSE)[[1]]
        list(id = image$Id, repo_digests = image$RepoDigests)
      }
    }, error = function(e) NULL) else if (!is.null(built$sif_path) && file.exists(built$sif_path)) ni_file_identities(built$sif_path) else NULL,
    container_ref = built$container_ref, container_source = built$container_source, sif_path = built$sif_path,
    host_payload = payload_host, container_payload = if (engine != "native") payload_exec else NULL,
    execution = execution,
    spec_id = call$spec$id, spec_hash = digest::digest(call$spec, algo = "sha256"),
    niflowr_version = as.character(utils::packageVersion("niflowr")),
    niflowr_commit = source_identity$commit,
    niflowr_source_hash = source_identity$hash,
    outputs = call$outputs, call = call
  ), class = "ni_execution_plan")
}

ni_absolute_values <- function(spec, values, wd) {
  for (nm in names(values)) {
    def <- spec$inputs[[nm]]
    if (is.null(def) || is.null(values[[nm]])) next
    if (is_path_sentinel(values[[nm]], def)) next
    if (def$type %in% c("file", "dir") ||
        (def$type == "list" && (def$items_type %||% "") %in% c("file", "dir"))) {
      values[[nm]] <- as.character(fs::path_abs(values[[nm]], start = wd))
    }
  }
  values
}

ni_source_identity <- function() {
  root <- getNamespaceInfo(asNamespace("niflowr"), "path")
  files <- c(file.path(root, "DESCRIPTION"), sort(list.files(file.path(root, "R"), full.names = TRUE)))
  hashes <- vapply(files[file.exists(files) & !dir.exists(files)], function(p) digest::digest(file = p, algo = "sha256"), character(1))
  commit <- utils::packageDescription("niflowr")$RemoteSha %||% NULL
  if (file.exists(file.path(root, ".git"))) commit <- tryCatch(trimws(processx::run("git", c("rev-parse", "HEAD"), wd = root, timeout = 2)$stdout), error = function(e) commit)
  list(commit = commit, hash = digest::digest(unname(hashes), algo = "sha256"))
}
