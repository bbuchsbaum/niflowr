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
    primary <- result$outputs[[1]]
    if (is.null(primary)) {
      cli::cli_abort("No output path available for provenance sidecar.")
    }
    path <- paste0(fs::path_ext_remove(primary), "_provenance.json")
  }

  prov <- result$provenance

  # Add input hashes if inputs are files that exist
  input_hashes <- list()
  for (nm in names(result$call$values)) {
    val <- result$call$values[[nm]]
    def <- result$call$spec$inputs[[nm]]
    if (!is.null(def) && def$type == "file" && is.character(val) && file.exists(val)) {
      input_hashes[[nm]] <- digest::digest(file = val, algo = "xxhash64")
    }
  }
  if (length(input_hashes) > 0) {
    prov$input_hashes <- input_hashes
  }

  # Try to get tool version
  version_info <- get_tool_version(result$call$spec)
  if (!is.null(version_info)) {
    prov$tool_version <- version_info
  }

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
get_tool_version <- function(spec) {
  ver <- spec$runtime$version
  if (is.null(ver) || is.null(ver$args)) return(NULL)

  cmd <- spec$command
  if (is.list(cmd)) cmd <- cmd[[1]]

  tryCatch({
    result <- processx::run(
      cmd,
      args = ver$args,
      error_on_status = FALSE,
      timeout = 5
    )
    trimws(paste0(result$stdout, result$stderr))
  }, error = function(e) NULL)
}
