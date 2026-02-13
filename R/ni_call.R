#' Construct an ni_call: bind parameter values to a spec
#'
#' Creates a validated call object that captures a spec plus concrete parameter
#' values, ready for execution or dry-run preview.
#'
#' @param spec_id A spec ID (e.g. `"fsl.bet"`), path to a JSON file, or an
#'   `ni_spec` object.
#' @param ... Named parameter values.
#' @param .cwd Working directory override.
#' @param .env Named character vector of environment variables.
#' @param .container List with `type` (`"docker"` or `"apptainer"`), `image`,
#'   and optional `args`.
#' @param .validate Logical; validate inputs at construction time. Default `TRUE`.
#' @return An `ni_call` object (S3 list).
#' @export
ni_call <- function(spec_id, ..., .cwd = NULL, .env = NULL, .container = NULL,
                    .validate = TRUE) {
  # Resolve spec
  if (inherits(spec_id, "ni_spec")) {
    spec <- spec_id
  } else {
    spec <- ni_spec_read(spec_id)
  }

  values <- list(...)

  # Validate
  if (.validate) {
    validate_inputs(spec, values)
  }

  # Resolve output paths
  outputs <- resolve_outputs(spec, values)

  call <- structure(
    list(
      spec = spec,
      values = values,
      outputs = outputs,
      cwd = .cwd,
      env = .env,
      container = .container
    ),
    class = "ni_call"
  )

  call
}

#' Resolve output paths from spec and input values
#' @keywords internal
resolve_outputs <- function(spec, values) {
  out <- list()

  for (nm in names(spec$outputs)) {
    odef <- spec$outputs[[nm]]
    path_spec <- odef$path

    if (!is.null(path_spec$from_input)) {
      # Path taken directly from an input value
      input_name <- path_spec$from_input
      out[[nm]] <- values[[input_name]]
    } else if (!is.null(path_spec$template)) {
      # Glue-style template using input values
      tmpl <- path_spec$template
      out[[nm]] <- tryCatch(
        glue::glue(tmpl, .envir = as.environment(values)),
        error = function(e) {
          cli::cli_abort(c(
            "Failed to resolve output template for {.field {nm}}.",
            "x" = "Template: {.code {tmpl}}",
            "i" = "Error: {e$message}",
            "i" = "Check that all template variables are provided as inputs."
          ))
        }
      )
    } else if (!is.null(path_spec$static)) {
      out[[nm]] <- path_spec$static
    }
  }

  out
}

#' Get the command + args that would be executed
#'
#' @param call An `ni_call` object.
#' @return A list with `command`, `args`, `wd`, `env`, `stdout`, `stderr`.
#' @export
ni_cmd <- function(call) {
  stopifnot(inherits(call, "ni_call"))
  built <- build_command(call)

  list(
    command = built$command,
    args = built$args,
    wd = call$cwd,
    env = call$env,
    stdout = built$stdout,
    stderr = built$stderr
  )
}

#' @export
print.ni_call <- function(x, ...) {
  built <- build_command(x)
  cmd_str <- paste(c(built$command, built$args), collapse = " ")

  cli::cli_h3("ni_call: {x$spec$id}")
  cli::cli_text("Command: {.code {cmd_str}}")

  if (!is.null(x$cwd)) {
    cli::cli_text("Working dir: {.path {x$cwd}}")
  }

  if (length(x$outputs) > 0) {
    cli::cli_h3("Expected outputs")
    for (nm in names(x$outputs)) {
      cli::cli_text("  {.field {nm}}: {.path {x$outputs[[nm]]}}")
    }
  }

  invisible(x)
}
