#' Create a targets-compatible neuroimaging processing step
#'
#' A target factory that wraps an niflowr call as a `targets::tar_target()`
#' with `format = "file"`, so outputs are tracked as file dependencies.
#'
#' @param name Symbol; target name.
#' @param spec_id Spec ID string (e.g. `"fsl.bet"`).
#' @param ... Named arguments passed to [ni_call()].
#' @param packages Character vector of packages to load. Default includes `"niflowr"`.
#' @param priority Numeric priority for target scheduling (0 to 1).
#' @param pattern A dynamic branching pattern (e.g. `map(subjects)`).
#' @return A `tar_target` object.
#' @export
tar_ni_step <- function(name, spec_id, ..., packages = "niflowr",
                        priority = 0, pattern = NULL) {
  if (!requireNamespace("targets", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg targets} is required for pipeline integration.")
  }

  name <- targets::tar_deparse_language(substitute(name))
  pattern_lang <- substitute(pattern)

  # Capture the dots as a language object for non-standard eval
  call_args <- match.call(expand.dots = FALSE)$...

  # Replace ARGS_PLACEHOLDER with actual args
  # We need to build the ni_call expression dynamically
  call_expr_parts <- list(quote(niflowr::ni_call), spec_id)
  for (nm in names(call_args)) {
    call_expr_parts[[nm]] <- call_args[[nm]]
  }
  ni_call_expr <- as.call(call_expr_parts)

  full_cmd <- substitute({
    call <- NI_CALL
    files <- niflowr::ni_run(call, echo = FALSE, return = "files")
    as.character(files)
  }, list(NI_CALL = ni_call_expr))

  targets::tar_target_raw(
    name = name,
    command = full_cmd,
    format = "file",
    packages = packages,
    priority = priority,
    pattern = pattern_lang
  )
}

#' Run an niflowr call and return output file paths
#'
#' Convenience function for use inside `tar_target()` expressions.
#' Runs the call and returns a character vector of output paths,
#' suitable for `format = "file"` targets.
#'
#' @param spec_id Spec ID or `ni_spec` object.
#' @param ... Named arguments passed to [ni_call()].
#' @return Character vector of output file paths.
#' @export
ni_run_files <- function(spec_id, ...) {
  call <- ni_call(spec_id, ...)
  as.character(ni_run(call, echo = FALSE, provenance = TRUE, return = "files"))
}
