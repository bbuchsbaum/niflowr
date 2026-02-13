#' Execute an ni_call
#'
#' Validates inputs, builds the argument vector, runs the command via
#' [processx::run()], checks outputs, and returns a structured `ni_result`.
#'
#' @param call An `ni_call` object, or a spec ID (in which case remaining
#'   args are passed to [ni_call()]).
#' @param ... If `call` is a spec ID, passed to [ni_call()].
#' @param dry_run Logical; if `TRUE`, print the command without executing.
#' @param echo Logical; if `TRUE`, print stdout/stderr in real time.
#'   Defaults to `interactive()`.
#' @param provenance Logical; write a provenance JSON sidecar. Default `TRUE`.
#' @param error_on_status Logical; if `TRUE` (default), error when the command
#'   exits with a non-zero status. If `FALSE`, issue a warning instead.
#' @return An `ni_result` object.
#' @export
ni_run <- function(call, ..., dry_run = FALSE, echo = interactive(),
                   provenance = TRUE, error_on_status = TRUE) {
  # Allow shorthand: ni_run("fsl.bet", in_file = ..., out_file = ...)
  if (is.character(call)) {
    call <- ni_call(call, ...)
  }

  stopifnot(inherits(call, "ni_call"))

  # Build command
  built <- build_command(call)

  # Apply container wrapping if needed
  container <- call$container %||% call$spec$runtime$container
  if (!is.null(container) && !identical(container$type, "none")) {
    built <- wrap_container(built, container, call)
  }

  # Resolve working directory
  wd <- call$cwd %||% call$spec$runtime$cwd

  # Resolve environment
  env <- call$env
  spec_env <- call$spec$runtime$env
  if (!is.null(spec_env)) {
    env <- c(spec_env, env)  # call-level overrides spec-level
  }

  if (dry_run) {
    cmd_str <- paste(c(built$command, built$args), collapse = " ")
    cli::cli_alert_info("Dry run: {.code {cmd_str}}")
    if (!is.null(wd)) cli::cli_text("  Working dir: {.path {wd}}")
    if (!is.null(built$stdout)) cli::cli_text("  stdout -> {.path {built$stdout}}")
    if (!is.null(built$stderr)) cli::cli_text("  stderr -> {.path {built$stderr}}")
    cli::cli_h3("Expected outputs")
    for (nm in names(call$outputs)) {
      cli::cli_text("  {.field {nm}}: {.path {call$outputs[[nm]]}}")
    }
    return(invisible(NULL))
  }

  # Determine stdout/stderr handling for processx
  stdout_arg <- if (!is.null(built$stdout)) built$stdout else "|"
  stderr_arg <- if (!is.null(built$stderr)) built$stderr else "|"

  # Execute
  start_time <- Sys.time()

  if (echo && is.null(built$stdout)) {
    stdout_arg <- ""
  }
  if (echo && is.null(built$stderr)) {
    stderr_arg <- ""
  }

  proc_result <- processx::run(
    command = built$command,
    args = built$args,
    wd = wd,
    env = if (!is.null(env)) env else NULL,
    stdout = stdout_arg,
    stderr = stderr_arg,
    error_on_status = FALSE
  )

  end_time <- Sys.time()
  duration <- as.numeric(difftime(end_time, start_time, units = "secs"))

  # Check outputs
  output_warnings <- check_outputs(call)

  if (length(output_warnings) > 0) {
    for (w in output_warnings) {
      cli::cli_warn(w)
    }
  }

  # Build provenance
  prov <- list(
    spec_id = call$spec$id,
    command = built$command,
    args = built$args,
    exit_status = proc_result$status,
    start_time = format(start_time, "%Y-%m-%dT%H:%M:%S%z"),
    end_time = format(end_time, "%Y-%m-%dT%H:%M:%S%z"),
    duration_secs = duration,
    outputs = call$outputs
  )

  result <- structure(
    list(
      spec_id = call$spec$id,
      outputs = call$outputs,
      runtime = list(
        exit_status = proc_result$status,
        stdout = proc_result$stdout %||% "",
        stderr = proc_result$stderr %||% "",
        duration_secs = duration,
        start_time = start_time,
        end_time = end_time
      ),
      provenance = prov,
      call = call
    ),
    class = "ni_result"
  )

  # Write provenance sidecar
  if (provenance && proc_result$status == 0 && length(call$outputs) > 0) {
    primary_output <- call$outputs[[1]]
    if (!is.null(primary_output) && is.character(primary_output)) {
      prov_path <- paste0(fs::path_ext_remove(primary_output), "_provenance.json")
      tryCatch(
        ni_provenance_write(result, prov_path),
        error = function(e) {
          cli::cli_warn("Could not write provenance sidecar: {e$message}")
        }
      )
    }
  }

  # Handle non-zero exit
  if (proc_result$status != 0) {
    msg <- c(
      "Command {.code {call$spec$id}} exited with status {proc_result$status}.",
      "i" = "Use {.code result$runtime$stderr} to see error output."
    )
    if (error_on_status) {
      cli::cli_abort(msg)
    } else {
      cli::cli_warn(msg)
    }
  }

  result
}

#' Run a spec as a dry run
#'
#' Shorthand for `ni_run(ni_call(spec, ...), dry_run = TRUE)`.
#'
#' @inheritParams ni_call
#' @export
ni_dry_run <- function(spec_id, ...) {
  call <- ni_call(spec_id, ..., .validate = FALSE)
  ni_run(call, dry_run = TRUE)
}

#' Check that expected outputs exist
#' @keywords internal
check_outputs <- function(call) {
  warnings <- character(0)

  for (nm in names(call$spec$outputs)) {
    odef <- call$spec$outputs[[nm]]
    if (!isTRUE(odef$must_exist)) next

    path <- call$outputs[[nm]]
    if (is.null(path)) next

    if (!file.exists(path)) {
      warnings <- c(warnings, cli::format_inline(
        "Expected output {.field {nm}} not found: {.path {path}}"
      ))
    }
  }

  warnings
}
