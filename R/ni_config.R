#' Get or update niflowr runtime configuration
#'
#' @param derivatives_dir Base directory used for inferred BIDS-derivatives
#'   outputs. Default: `"derivatives/niflowr"`.
#' @param .reset Logical; if `TRUE`, reset config to defaults.
#' @return Named list with current configuration.
#' @export
ni_config <- function(derivatives_dir = NULL, .reset = FALSE) {
  if (isTRUE(.reset)) {
    .ni_config$derivatives_dir <- "derivatives/niflowr"
  }

  if (!is.null(derivatives_dir)) {
    if (!is.character(derivatives_dir) || length(derivatives_dir) != 1 || !nzchar(derivatives_dir)) {
      cli::cli_abort("{.arg derivatives_dir} must be a non-empty character string.")
    }
    .ni_config$derivatives_dir <- derivatives_dir
  }

  list(
    derivatives_dir = .ni_config$derivatives_dir %||% "derivatives/niflowr"
  )
}

#' @keywords internal
ni_config_get <- function(key, default = NULL) {
  val <- .ni_config[[key]]
  if (is.null(val)) default else val
}
