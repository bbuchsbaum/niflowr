#' Execute an ni_call
#'
#' Validates inputs, builds an argument vector, resolves runtime engine
#' (`native`, `docker`, `apptainer`), executes via [processx::run()], checks
#' outputs, and returns a structured result.
#'
#' @param call An `ni_call` object, or a spec ID (in which case remaining
#'   args are passed to [ni_call()]).
#' @param ... If `call` is a spec ID, passed to [ni_call()].
#' @param dry_run Logical; if `TRUE`, print the resolved command and return
#'   without executing.
#' @param echo Logical; if `TRUE`, print stdout/stderr in real time.
#'   Defaults to `interactive()`.
#' @param provenance Logical; write a provenance JSON sidecar. Default `TRUE`.
#' @param error_on_status Logical; if `TRUE` (default), error when the command
#'   exits with a non-zero status. If `FALSE`, issue a warning instead.
#' @param return One of `"result"` (default) or `"files"`.
#' @return An `ni_result` object, or (when `return = "files"`) a character
#'   vector of output files with the full result attached as `ni_result`
#'   attribute.
#' @export
ni_run <- function(call, ..., dry_run = FALSE, echo = interactive(),
                   provenance = TRUE, error_on_status = TRUE,
                   return = c("result", "files")) {
  if (is.character(call)) {
    call <- ni_call(call, ...)
  }
  stopifnot(inherits(call, "ni_call"))
  return <- match.arg(return)

  cfg <- ni_config_resolve()

  # Build host payload first for human-readable provenance and redirects.
  payload_host <- build_command(call)
  runtime <- call$runtime %||% list()
  engine_override <- runtime$engine %||% call$spec$runtime$engine
  engine <- ni_runtime_detect(cfg, payload_host$command, engine_override)

  # Resolve working dir and environment (global cfg < spec < call override).
  wd <- runtime$cwd %||% call$spec$runtime$cwd
  env <- ni_env_vector(c(
    cfg$env %||% list(),
    call$spec$runtime$env %||% list(),
    runtime$env %||% list()
  ))

  stdout_arg <- if (!is.null(payload_host$stdout)) payload_host$stdout else "|"
  stderr_arg <- if (!is.null(payload_host$stderr)) payload_host$stderr else "|"

  host_command <- list(
    engine = engine,
    command = payload_host$command,
    args = payload_host$args
  )

  if (identical(engine, "native")) {
    exec_command <- payload_host$command
    exec_args <- payload_host$args
    exec_wd <- wd
    payload_exec <- payload_host
  } else {
    # Rewrite path-like inputs only for container execution.
    call_container <- call
    call_container$values <- ni_rewrite_values_for_container(call$spec, call$values, cfg)
    payload_container <- build_command(call_container)
    payload_container$stdout <- payload_host$stdout
    payload_container$stderr <- payload_host$stderr
    payload_exec <- payload_container

    built <- ni_build_container_command(
      engine = engine,
      cfg = cfg,
      call = call,
      payload_cmd = payload_container$command,
      payload_args = payload_container$args,
      env = env
    )

    exec_command <- built$bin
    exec_args <- built$argv
    exec_wd <- NULL

    host_command <- c(host_command, list(
      profile = built$profile,
      container_ref = built$container_ref,
      command = built$bin,
      args = built$argv
    ))
    if (!is.null(built$container_source)) host_command$container_source <- built$container_source
    if (!is.null(built$sif_path)) host_command$sif_path <- built$sif_path

    ni_lock_enforce_profile(
      cfg = cfg,
      engine = engine,
      profile = built$profile,
      container_ref = built$container_ref,
      container_source = built$container_source %||% NULL,
      sif_path = built$sif_path %||% NULL
    )
  }

  if (dry_run) {
    cmd_str <- paste(c(exec_command, exec_args), collapse = " ")
    cli::cli_alert_info("Dry run [{engine}]: {.code {cmd_str}}")
    if (!is.null(exec_wd)) cli::cli_text("  Working dir: {.path {exec_wd}}")
    if (!is.null(payload_exec$stdout)) cli::cli_text("  stdout -> {.path {payload_exec$stdout}}")
    if (!is.null(payload_exec$stderr)) cli::cli_text("  stderr -> {.path {payload_exec$stderr}}")
    cli::cli_h3("Expected outputs")
    for (nm in names(call$outputs)) {
      cli::cli_text("  {.field {nm}}: {.path {call$outputs[[nm]]}}")
    }
    return(invisible(NULL))
  }

  if (echo && is.null(payload_exec$stdout)) stdout_arg <- ""
  if (echo && is.null(payload_exec$stderr)) stderr_arg <- ""

  start_time <- Sys.time()
  proc_result <- processx::run(
    command = exec_command,
    args = exec_args,
    wd = exec_wd,
    env = if (length(env) > 0) env else NULL,
    stdout = stdout_arg,
    stderr = stderr_arg,
    error_on_status = FALSE
  )
  end_time <- Sys.time()
  duration <- as.numeric(difftime(end_time, start_time, units = "secs"))

  output_warnings <- check_outputs(call)
  if (length(output_warnings) > 0) {
    for (w in output_warnings) cli::cli_warn(w)
  }

  prov <- list(
    spec_id = call$spec$id,
    engine = engine,
    profile = host_command$profile %||% NULL,
    payload = list(
      command = payload_host$command,
      args = payload_host$args
    ),
    host_command = host_command,
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
        engine = engine,
        profile = host_command$profile %||% NULL,
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

  if (provenance && proc_result$status == 0 && length(call$outputs) > 0) {
    primary_output <- call$outputs[[1]]
    if (!is.null(primary_output) && is.character(primary_output)) {
      prov_path <- paste0(fs::path_ext_remove(primary_output), "_provenance.json")
      tryCatch(
        ni_provenance_write(result, prov_path),
        error = function(e) cli::cli_warn("Could not write provenance sidecar: {e$message}")
      )
    }
  }

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

  if (identical(return, "files")) {
    files <- unname(unlist(call$outputs, use.names = FALSE))
    files <- as.character(files[nzchar(files)])
    out <- structure(files, class = c("ni_files", "character"))
    attr(out, "ni_result") <- result
    return(out)
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
