#' Write an explicit FSL slicetimer custom-timing file
#'
#' Converts slice acquisition times and a desired temporal reference into the
#' forward-shift fractions consumed by FSL `slicetimer --tcustom`. This avoids
#' passing BIDS `SliceTiming` seconds directly to an interface that expects
#' fractions of TR with opposite sign for later-acquired slices.
#'
#' @param slice_timing Numeric slice acquisition times.
#' @param repetition_time Positive scalar repetition time.
#' @param reference_time Scalar temporal reference within the TR.
#' @param path Destination text file.
#' @param units Units of all time values. Only `"seconds"` is accepted.
#' @return A record containing `path`, `shifts`, units, repetition time, and
#'   reference time. Pass `result$path`, `custom_timing_units =
#'   "fraction_of_tr"`, and `timing_reference =
#'   "forward_shift_to_reference"` to [ni_fsl_slice_timer()].
#' @export
ni_fsl_slice_timing_file <- function(slice_timing, repetition_time,
                                     reference_time, path,
                                     units = "seconds") {
  if (!identical(units, "seconds")) {
    cli::cli_abort("{.arg units} must be {.val seconds}; FSL custom timings are written as fractions of TR.")
  }
  if (!is.numeric(slice_timing) || !length(slice_timing) || anyNA(slice_timing) ||
      any(!is.finite(slice_timing))) {
    cli::cli_abort("{.arg slice_timing} must be a non-empty finite numeric vector in seconds.")
  }
  if (!is.numeric(repetition_time) || length(repetition_time) != 1L ||
      is.na(repetition_time) || !is.finite(repetition_time) || repetition_time <= 0) {
    cli::cli_abort("{.arg repetition_time} must be one positive finite value in seconds.")
  }
  if (!is.numeric(reference_time) || length(reference_time) != 1L ||
      is.na(reference_time) || !is.finite(reference_time) ||
      reference_time < 0 || reference_time >= repetition_time) {
    cli::cli_abort("{.arg reference_time} must be within [0, repetition_time) seconds.")
  }
  if (any(slice_timing < 0 | slice_timing >= repetition_time)) {
    cli::cli_abort("Every {.arg slice_timing} value must be within [0, repetition_time) seconds.")
  }
  if (!is.character(path) || length(path) != 1L || is.na(path) || !nzchar(path)) {
    cli::cli_abort("{.arg path} must be one non-empty file path.")
  }

  shifts <- (reference_time - slice_timing) / repetition_time
  parent <- dirname(path)
  if (!dir.exists(parent)) {
    cli::cli_abort("Parent directory for {.arg path} does not exist: {.path {parent}}")
  }
  writeLines(sprintf("%.17g", shifts), path, useBytes = TRUE)
  path <- fs::path_abs(path)
  structure(
    list(
      path = path,
      shifts = shifts,
      units = "fraction_of_tr",
      timing_reference = "forward_shift_to_reference",
      repetition_time_seconds = repetition_time,
      reference_time_seconds = reference_time
    ),
    class = c("ni_fsl_slice_timing", "list")
  )
}
