#' Build a command argument vector from an ni_call
#'
#' Implements the argstr/position/flag/sep rules to produce a safe character
#' vector of arguments (never a shell string).
#'
#' @param call An `ni_call` object.
#' @return A list with components `command`, `args`, `stdout`, `stderr`.
#' @keywords internal
build_command <- function(call) {
  spec <- call$spec
  values <- call$values

  # Determine the base command

  cmd <- spec$command
  if (is.list(cmd)) cmd <- unlist(cmd)

  # If command is a vector, first element is the executable, rest are prefix args
  if (length(cmd) > 1) {
    base_cmd <- cmd[1]
    prefix_args <- cmd[-1]
  } else {
    base_cmd <- cmd
    prefix_args <- character(0)
  }

  # Build argument entries: list of list(tokens, position)
  arg_entries <- list()
  stdout_file <- NULL
  stderr_file <- NULL

  for (nm in names(spec$inputs)) {
    val <- values[[nm]]
    if (is_missing_value(val)) next

    def <- spec$inputs[[nm]]
    cli_def <- def$cli
    if (is.null(cli_def)) next

    # Handle runner-level redirects
    if (!is.null(cli_def$stdout_to)) {
      stdout_file <- val
      next
    }
    if (!is.null(cli_def$stderr_to)) {
      stderr_file <- val
      next
    }

    argstr <- cli_def$argstr
    if (is.null(argstr)) next

    pos <- cli_def$position  # may be NULL

    tokens <- render_arg(val, def, argstr)

    if (length(tokens) > 0) {
      arg_entries[[length(arg_entries) + 1]] <- list(
        tokens = tokens,
        position = pos,
        name = nm
      )
    }
  }

  # Sort: positional args first (by position), then non-positional in alphabetical order
  has_pos <- vapply(arg_entries, function(e) !is.null(e$position), logical(1))
  positional <- arg_entries[has_pos]
  non_positional <- arg_entries[!has_pos]

  # Sort positional by position value
  if (length(positional) > 0) {
    pos_vals <- vapply(positional, function(e) e$position, integer(1))
    positional <- positional[order(pos_vals)]
  }

  # Sort non-positional by name for stable, locale-independent ordering
  if (length(non_positional) > 0) {
    np_names <- vapply(non_positional, function(e) e$name, character(1))
    non_positional <- non_positional[order(np_names, method = "radix")]
  }

  # Assemble final args vector
  sorted <- c(positional, non_positional)
  args <- unlist(c(
    list(prefix_args),
    lapply(sorted, function(e) e$tokens)
  ), use.names = FALSE)

  if (is.null(args)) args <- character(0)

  list(
    command = base_cmd,
    args = args,
    stdout = stdout_file,
    stderr = stderr_file
  )
}

#' Render a single argument value to CLI tokens
#' @keywords internal
render_arg <- function(value, def, argstr) {
  type <- def$type

  # Flag type: include argstr only if TRUE

  if (type == "flag") {
    if (isTRUE(value)) {
      return(strsplit(argstr, "\\s+")[[1]])
    } else {
      return(character(0))
    }
  }

  # Bool type: render as flag

  if (type == "bool") {
    if (grepl("%", argstr, fixed = TRUE)) {
      bval <- if (is.logical(value)) as.integer(value) else value
      return(render_single(bval, argstr))
    }
    if (isTRUE(value)) {
      return(strsplit(argstr, "\\s+")[[1]])
    } else {
      return(character(0))
    }
  }

  # List type with sep or repeat
  if (type == "list" && length(value) > 1) {
    cli_def <- def$cli
    if (isTRUE(cli_def$`repeat`)) {
      # Repeat the flag for each element
      tokens <- character(0)
      for (v in value) {
        tokens <- c(tokens, render_single(v, argstr))
      }
      return(tokens)
    }

    sep <- cli_def$sep %||% ","
    joined <- paste(value, collapse = sep)
    # Use render_nosplit to keep the joined value as a single token
    return(render_nosplit(joined, argstr))
  }

  # Single value
  render_single(value, argstr)
}

#' Render a value with sprintf, splitting the flag from the value but keeping
#' the value as one token (for joined list values that may contain spaces)
#' @keywords internal
render_nosplit <- function(value, argstr) {
  rendered <- tryCatch(
    sprintf(argstr, value),
    error = function(e) paste(argstr, value)
  )
  rendered <- trimws(rendered)
  # Split only on the first space to separate flag from value
  # e.g. "-c 10 20 30" -> c("-c", "10 20 30")
  space_pos <- regexpr(" ", rendered)
  if (space_pos > 0) {
    c(substr(rendered, 1, space_pos - 1),
      trimws(substr(rendered, space_pos + 1, nchar(rendered))))
  } else {
    rendered
  }
}

#' Render a single scalar value with sprintf then split on whitespace
#' @keywords internal
render_single <- function(value, argstr) {
  # Use sprintf to render the value into the argstr template
  rendered <- tryCatch(
    sprintf(argstr, value),
    error = function(e) {
      # Fallback: just paste
      paste(argstr, value)
    }
  )

  # Split on whitespace to get individual tokens
  strsplit(trimws(rendered), "\\s+")[[1]]
}
