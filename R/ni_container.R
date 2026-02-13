#' Wrap a command for container execution
#'
#' Transforms the command and args to run inside a Docker or Apptainer container.
#' Automatically bind-mounts directories containing input and output files.
#'
#' @param built List with `command`, `args`, `stdout`, `stderr`.
#' @param container List with `type`, `image`, and optional `args`.
#' @param call The `ni_call` object (for inspecting file paths).
#' @return Modified `built` list with container-wrapped command/args.
#' @keywords internal
wrap_container <- function(built, container, call) {
  ctype <- container$type
  image <- container$image

  if (is.null(image) || !nzchar(image)) {
    cli::cli_abort("Container image must be specified when container type is {.val {ctype}}.")
  }

  # Collect all file paths that need to be bind-mounted
  bind_dirs <- collect_bind_dirs(call)

  extra_args <- container$args %||% character(0)

  if (ctype == "docker") {
    bind_args <- unlist(lapply(bind_dirs, function(d) c("-v", paste0(d, ":", d))))
    new_args <- c("run", "--rm", bind_args, extra_args, image, built$command, built$args)
    built$command <- "docker"
    built$args <- new_args
  } else if (ctype == "apptainer") {
    bind_str <- paste(bind_dirs, collapse = ",")
    bind_args <- if (nzchar(bind_str)) c("--bind", bind_str) else character(0)
    new_args <- c("exec", bind_args, extra_args, image, built$command, built$args)
    built$command <- "apptainer"
    built$args <- new_args
  } else {
    cli::cli_abort("Unknown container type: {.val {ctype}}. Use 'docker' or 'apptainer'.")
  }

  built
}

#' Collect unique directories from file-type input/output values
#' @keywords internal
collect_bind_dirs <- function(call) {
  dirs <- character(0)

  # Input file directories
  for (nm in names(call$values)) {
    val <- call$values[[nm]]
    def <- call$spec$inputs[[nm]]
    if (!is.null(def) && def$type %in% c("file", "dir") && is.character(val)) {
      if (def$type == "dir") {
        dirs <- c(dirs, val)
      } else {
        dirs <- c(dirs, dirname(val))
      }
    }
  }

  # Output directories — ensure they exist so they can be bind-mounted
  output_dirs <- character(0)
  for (path in call$outputs) {
    if (is.character(path) && nzchar(path)) {
      output_dirs <- c(output_dirs, dirname(path))
    }
  }

  # Create output directories that don't exist yet
  for (d in unique(output_dirs)) {
    if (!file.exists(d)) {
      fs::dir_create(d)
    }
  }

  all_dirs <- c(dirs, output_dirs)
  unique(fs::path_real(all_dirs[file.exists(all_dirs)]))
}
