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
#'   the inspectable execution plan without executing.
#' @param echo Logical; if `TRUE`, print stdout/stderr in real time.
#'   Defaults to `interactive()`.
#' @param provenance Logical; write a provenance JSON sidecar. Default `TRUE`.
#' @param error_on_status Logical; if `TRUE` (default), error when the command
#'   exits with a non-zero status. If `FALSE`, issue a warning instead.
#' @param timeout Wall-time limit in seconds; `Inf` disables the limit.
#' @param log_dir Directory for per-invocation logs and provenance. Defaults to
#'   `.niflowr/runs` beside the first output, or in the working directory.
#' @param return One of `"result"` (default) or `"files"`.
#' @return An `ni_result` object, or (when `return = "files"`) a character
#'   vector of output files with the full result attached as `ni_result`
#'   attribute.
#' @export
ni_run <- function(call, ..., dry_run = FALSE, echo = interactive(),
                   provenance = TRUE, error_on_status = TRUE,
                   return = c("result", "files"), timeout = Inf, log_dir = NULL) {
  if (is.character(call)) call <- ni_call(call, ...)
  return <- match.arg(return)
  if (!is.numeric(timeout) || length(timeout) != 1L || is.na(timeout) || timeout <= 0)
    cli::cli_abort("timeout must be a positive number of seconds.")
  plan <- ni_plan(call)
  call <- plan$call
  if (dry_run) {
    cli::cli_alert_info("Dry run [{plan$engine}]: {.code {paste(c(plan$execution$command, plan$execution$args), collapse = ' ')}}")
    return(invisible(plan))
  }
  files <- unname(unlist(call$outputs, use.names = FALSE))
  parent <- if (length(files)) dirname(files[[1]]) else plan$host_cwd
  log_root <- log_dir %||% file.path(parent, ".niflowr", "runs")
  fs::dir_create(log_root)
  run_dir <- tempfile("run-", tmpdir = log_root)
  fs::dir_create(run_dir)
  stdout_path <- file.path(run_dir, "stdout.log")
  stderr_path <- file.path(run_dir, "stderr.log")
  file.create(stdout_path, stderr_path)
  input_identities <- ni_input_identities(call)
  before <- ni_file_identities(files)
  preexisting <- character()
  for (nm in names(call$outputs)) {
    if (!isTRUE(call$spec$outputs[[nm]]$must_exist)) next
    paths <- call$outputs[[nm]]
    inout <- unlist(call$values[names(Filter(function(d) identical(d$role, "inout"), call$spec$inputs))], use.names = FALSE)
    preexisting <- c(preexisting, paths[file.exists(paths) & !paths %in% inout])
  }
  exec <- plan$execution
  container_name <- NULL
  if (plan$engine == "docker") {
    container_name <- paste0("niflowr-", basename(run_dir), "-", Sys.getpid())
    exec$args <- append(exec$args, c("--name", container_name), after = 1L)
  }
  plan$execution <- exec
  proc <- NULL
  attempted <- FALSE
  cleanup <- function() {
    if (!is.null(proc) && proc$is_alive()) try(proc$kill_tree(), silent = TRUE)
    if (attempted && !is.null(container_name)) {
      try(processx::run(exec$command, c("rm", "-f", container_name),
                       error_on_status = FALSE, timeout = 10), silent = TRUE)
    }
  }
  on.exit(cleanup(), add = TRUE)
  start <- Sys.time()
  timed_out <- FALSE
  interrupted <- FALSE
  failure <- NULL
  status <- NA_integer_
  if (length(preexisting)) {
    failure <- paste("Refusing pre-existing required outputs; use fresh invocation paths:", paste(preexisting, collapse = ", "))
  } else {
    tryCatch({
      if (plan$engine == "apptainer" && !is.null(plan$sif_path) && !file.exists(plan$sif_path))
        ni_apptainer_pull_if_needed(ni_config_resolve(), plan$sif_path, plan$container_source, timeout = timeout)
      attempted <- TRUE
      proc <- processx::process$new(exec$command, exec$args, wd = exec$cwd,
        env = ni_process_env(plan$environment),
        stdout = "|", stderr = "|", cleanup_tree = TRUE)
      drain <- function() {
        a <- proc$read_output(); b <- proc$read_error()
        if (nzchar(a)) { cat(a, file = stdout_path, append = TRUE); if (echo) cat(a) }
        if (nzchar(b)) { cat(b, file = stderr_path, append = TRUE); if (echo) cat(b, file = stderr()) }
      }
      while (proc$is_alive()) {
        proc$poll_io(100)
        drain()
        if (as.numeric(difftime(Sys.time(), start, units = "secs")) >= timeout) {
          timed_out <- TRUE
          cleanup()
          break
        }
      }
      proc$wait(1000)
      drain()
      status <- proc$get_exit_status() %||% NA_integer_
    }, interrupt = function(e) {
      interrupted <<- TRUE; failure <<- "Execution interrupted."; cleanup()
    }, error = function(e) {
      failure <<- conditionMessage(e); cleanup()
    })
  }
  if (!is.null(proc)) try({
    cat(proc$read_output(), file = stdout_path, append = TRUE)
    cat(proc$read_error(), file = stderr_path, append = TRUE)
  }, silent = TRUE)
  end <- Sys.time()
  read_log <- function(path) paste(readLines(path, warn = FALSE), collapse = "\n")
  stdout <- read_log(stdout_path); stderr <- read_log(stderr_path)
  # Redirects retain their public meaning while the invocation always keeps logs.
  if (!is.null(plan$host_payload$stdout)) file.copy(stdout_path, plan$host_payload$stdout, overwrite = TRUE)
  if (!is.null(plan$host_payload$stderr)) file.copy(stderr_path, plan$host_payload$stderr, overwrite = TRUE)
  output_errors <- check_outputs(call)
  # Explicit in-place outputs must change their content, not merely mtime.
  after <- ni_file_identities(files)
  for (i in seq_along(after)) {
    if (length(before) >= i && isTRUE(before[[i]]$exists) &&
        identical(before[[i]]$hash, after[[i]]$hash) && !is.null(after[[i]]$hash))
      output_errors <- c(output_errors, paste("Unchanged pre-existing output:", after[[i]]$path))
  }
  success <- is.null(failure) && !timed_out && !interrupted && identical(as.integer(status), 0L) && !length(output_errors)
  runtime <- list(engine = plan$engine, profile = plan$profile, exit_status = status,
    success = success, artifact_status = if (length(output_errors)) "failed" else if (!attempted || !isTRUE(status == 0)) "not_checked" else "passed",
    output_errors = output_errors, timed_out = timed_out, interrupted = interrupted,
    error = failure, stdout = stdout, stderr = stderr,
    stdout_path = stdout_path, stderr_path = stderr_path,
    duration_secs = as.numeric(difftime(end, start, units = "secs")), start_time = start, end_time = end)
  plan_record <- unclass(plan); plan_record$call <- NULL
  host_command <- c(list(engine = plan$engine, profile = plan$profile, container_ref = plan$container_ref), exec)
  prov <- list(spec_id = call$spec$id, engine = plan$engine, profile = plan$profile,
    plan = plan_record, payload = plan$host_payload, host_command = host_command,
    exit_status = status, success = success, runtime = runtime,
    input_identities = input_identities,
    input_hashes = lapply(input_identities, function(xs) vapply(xs, function(x) x$hash %||% NA_character_, character(1))),
    output_identities = if (success) after else list(), outputs = call$outputs,
    tool_version = if (attempted && !timed_out && !interrupted) get_tool_version(call$spec, plan) else NULL)
  result <- structure(list(spec_id = call$spec$id, outputs = call$outputs,
    runtime = runtime, provenance = prov, call = call), class = "ni_result")
  if (provenance) {
    prov_path <- file.path(run_dir, "provenance.json")
    result$runtime$provenance_path <- prov_path
    ni_provenance_write(result, prov_path)
    if (success && length(files)) ni_provenance_write(result, paste0(strip_known_extension(files[[1]]), "_provenance.json"))
  }
  if (!success) {
    msg <- paste(c(paste0("Command ", call$spec$id, " exited with status ", status, "."),
      if (timed_out) "Wall-time limit exceeded.", failure, output_errors, if (nzchar(stderr)) stderr), collapse = "\n")
    if (error_on_status || identical(return, "files")) {
      cli::cli_abort("{msg}", class = "ni_execution_error", result = result, stderr = stderr)
    } else cli::cli_warn("{msg}")
  }
  if (identical(return, "files")) {
    out <- structure(as.character(files[nzchar(files)]), class = c("ni_files", "character"))
    attr(out, "ni_result") <- result
    return(out)
  }
  result
}

#' Run a spec as a dry run
#' @inheritParams ni_call
#' @export
ni_dry_run <- function(spec_id, ...) {
  ni_run(ni_call(spec_id, ..., .validate = FALSE), dry_run = TRUE)
}

#' @keywords internal
check_outputs <- function(call) {
  errors <- character()
  for (nm in names(call$spec$outputs)) {
    def <- call$spec$outputs[[nm]]
    if (!isTRUE(def$must_exist)) next
    path <- call$outputs[[nm]]
    # Absent names represent gated-off outputs. Resolvers must list active names.
    if (is.null(path)) {
      if (is.null(call$spec$output_resolver) && output_when_holds(def$when, apply_spec_defaults(call$spec, call$values)))
        errors <- c(errors, paste("Required output path is unresolved:", nm))
      next
    }
    exists <- if (identical(def$type, "dir")) dir.exists(path) else file.exists(path) & !dir.exists(path)
    if (any(!exists)) errors <- c(errors, paste("Expected output", nm, "not found:", paste(path[!exists], collapse = ", ")))
    if (identical(def$type, "dir") && any(exists) && !length(list.files(path[exists], all.files = FALSE)))
      errors <- c(errors, paste("Expected output directory is empty:", path))
  }
  errors
}
