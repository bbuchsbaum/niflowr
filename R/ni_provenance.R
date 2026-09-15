#' Write a provenance JSON sidecar
#'
#' @param result An `ni_result` object.
#' @param path Output path for the JSON sidecar. If `NULL`, derived from the
#'   primary output path.
#' @return The path written (invisibly).
#' @export
ni_provenance_write <- function(result, path = NULL) {
  stopifnot(inherits(result, "ni_result"))

  if (is.null(path)) {
    primary <- unlist(result$outputs, use.names = FALSE)[1]
    if (is.null(primary) || is.na(primary)) {
      cli::cli_abort("No output path available for provenance sidecar.")
    }
    path <- paste0(strip_known_extension(primary), "_provenance.json")
  }

  prov <- result$provenance

  # Identities are captured by ni_run before execution, never reconstructed
  # from possibly modified files while serializing a result.
  fs::dir_create(fs::path_dir(path))
  jsonlite::write_json(prov, path, auto_unbox = TRUE, pretty = TRUE, null = "null")

  invisible(path)
}

#' Read a provenance JSON sidecar
#'
#' @param path Path to a provenance JSON file.
#' @return A list of provenance metadata.
#' @export
ni_provenance_read <- function(path) {
  if (!file.exists(path)) {
    cli::cli_abort("Provenance file not found: {.path {path}}")
  }
  jsonlite::fromJSON(path, simplifyVector = TRUE, simplifyDataFrame = FALSE)
}

#' Probe tool version using spec runtime info
#' @keywords internal
get_tool_version <- function(spec, plan = NULL) {
  ver <- spec$runtime$version
  if (is.null(ver) || is.null(ver$args)) return(NULL)

  cmd <- as.character(unlist(spec$command))[[1]]

  args <- as.character(unlist(ver$args))
  wd <- NULL
  env <- NULL
  if (!is.null(plan)) {
    wd <- plan$execution$cwd
    env <- ni_process_env(plan$environment)
    if (!identical(plan$engine, "native")) {
      payload <- plan$container_payload
      argv <- plan$execution$args
      # Drop the execution payload, preserving exactly the selected runtime.
      prefix_n <- length(argv) - length(payload$args) - 1L
      args <- c(argv[seq_len(prefix_n)], payload$command, args)
      # A completed run's unique container name cannot be reused by a probe.
      i <- match("--name", args)
      if (!is.na(i)) args <- args[-c(i, i + 1L)]
      if (identical(plan$engine, "docker")) {
        args <- ni_without_pull_args(args)
        args <- append(args, "--pull=never", after = 1L)
      }
      cmd <- plan$execution$command
    }
  }
  tryCatch({
    result <- if (!is.null(plan) && identical(plan$engine, "docker")) {
      ni_docker_probe_run(cmd, args, timeout = 5, env = env)
    } else processx::run(
      cmd,
      args = args, wd = wd, env = env,
      error_on_status = FALSE,
      timeout = 5
    )
    if (result$status != 0) return(NULL)
    trimws(paste0(result$stdout, result$stderr))
  }, error = function(e) NULL)
}

# Ordered path identities preserve collection membership and in-place ancestry.
ni_file_identities <- function(paths) {
  lapply(as.character(paths), function(path) {
    exists <- file.exists(path)
    directory <- dir.exists(path)
    hash <- if (exists && !directory) digest::digest(file = path, algo = "sha256") else NULL
    if (directory) {
      children <- sort(list.files(path, recursive = TRUE, full.names = TRUE, all.files = TRUE))
      children <- children[!dir.exists(children)]
      hash <- digest::digest(lapply(children, function(x) list(
        path = as.character(fs::path_rel(x, path)), hash = digest::digest(file = x, algo = "sha256"))), algo = "sha256")
    }
    list(path = path, exists = exists, type = if (directory) "dir" else "file",
         size = if (exists && !directory) unname(file.info(path)$size) else NULL, hash = hash)
  })
}

ni_input_identities <- function(call) {
  outputs <- unique(vapply(call$spec$outputs, function(x) x$path$from_input %||% "", character(1)))
  identities <- list()
  for (nm in names(call$values)) {
    def <- call$spec$inputs[[nm]]
    if (is.null(def)) next
    if (is_path_sentinel(call$values[[nm]], def)) next
    role <- def$role %||% if (nm %in% outputs) "output" else "input"
    if (role == "output") next
    if (def$type %in% c("file", "dir") ||
        (def$type == "list" && (def$items_type %||% "") %in% c("file", "dir"))) {
      identities[[nm]] <- ni_file_identities(call$values[[nm]])
    }
  }
  identities
}
