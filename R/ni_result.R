#' S3 class for execution results
#'
#' An `ni_result` captures the outputs, runtime info, and provenance from
#' running a neuroimaging tool.
#'
#' @name ni_result
NULL

#' Get output file paths from a result
#'
#' @param result An `ni_result` object.
#' @return A named list of output file paths.
#' @export
ni_outputs <- function(result) {
  stopifnot(inherits(result, "ni_result"))
  result$outputs
}

#' Get provenance metadata from a result
#'
#' @param result An `ni_result` object.
#' @return A list of provenance information.
#' @export
ni_provenance <- function(result) {
  stopifnot(inherits(result, "ni_result"))
  result$provenance
}

#' @export
print.ni_result <- function(x, ...) {
  status <- x$runtime$exit_status
  status_label <- if (status == 0) "success" else "FAILED"

  cli::cli_h3("ni_result: {x$spec_id} [{status_label}]")
  cli::cli_text("Exit status: {status}")
  cli::cli_text("Duration: {round(x$runtime$duration_secs, 2)}s")

  if (length(x$outputs) > 0) {
    cli::cli_h3("Outputs")
    for (nm in names(x$outputs)) {
      path <- x$outputs[[nm]]
      exists_tag <- if (file.exists(path)) "" else " [MISSING]"
      cli::cli_text("  {.field {nm}}: {.path {path}}{exists_tag}")
    }
  }

  if (status != 0 && nzchar(x$runtime$stderr)) {
    cli::cli_h3("Stderr (last 10 lines)")
    lines <- utils::tail(strsplit(x$runtime$stderr, "\n")[[1]], 10)
    for (line in lines) {
      cli::cli_text("  {line}")
    }
  }

  invisible(x)
}
