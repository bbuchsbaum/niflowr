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

  # Custom renderers handle commands whose argument structure cannot be
  # expressed by the generic per-input argstr loop (e.g. staged antsRegistration
  # with repeated --transform/--metric/--convergence groups).
  if (!is.null(spec$render)) {
    return(dispatch_custom_render(spec$render, call))
  }

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

  # Nipype repeated-argument convention: an argstr ending in "..." means the
  # flag is emitted once per value (e.g. "-f %s..." -> "-f a -f b"), NOT that a
  # literal ellipsis is appended to the value. Only the simple single-conversion
  # form is expanded here; multi-conversion tuple argstrs (e.g.
  # "-stim_times %d %s '%s'...") need grouped rendering and fall through to the
  # generic path unchanged rather than be silently corrupted.
  if (grepl("\\.\\.\\.\\s*$", argstr)) {
    base_argstr <- trimws(sub("\\.\\.\\.\\s*$", "", argstr))
    conv <- gregexpr("%[-+ #0-9.*]*[diouxXeEfgGaAs]", base_argstr)[[1]]
    n_conv <- if (conv[1] == -1L) 0L else length(conv)
    # Skip shell-quoted templates (e.g. "-gltsym 'SYM: %s'..."): their quoting
    # groups a space-containing argument that the argv model cannot reproduce,
    # so leave them to the generic path rather than split them mid-token.
    if (n_conv == 1L && !grepl("'", base_argstr, fixed = TRUE)) {
      tokens <- character(0)
      for (v in value) {
        tokens <- c(tokens, render_single(v, base_argstr))
      }
      return(tokens)
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

#' Coerce a value to match the printf conversion in an argstr
#'
#' Enum/choice coercion stores values as character, but numeric printf
#' conversions (`%d`, `%f`, ...) require numeric input or `sprintf()` errors and
#' the literal placeholder leaks into the rendered argument. Inspect the first
#' conversion specifier and coerce accordingly. If coercion is not safe (would
#' introduce `NA`, or is non-integral for an integer conversion), the value is
#' returned untouched so the existing fallback path still applies.
#'
#' @keywords internal
coerce_for_argstr <- function(value, argstr) {
  m <- regexpr("%[-+ #0-9.*]*[diouxXeEfgGaAs]", argstr)
  if (m < 0) return(value)
  conv <- regmatches(argstr, m)
  letter <- substr(conv, nchar(conv), nchar(conv))

  if (letter %in% c("d", "i", "o", "u", "x", "X")) {
    num <- suppressWarnings(as.numeric(value))
    # Coerce only when every element is a finite, integral value within R's
    # integer range; otherwise leave it untouched so we never emit a silent "NA"
    # token for Inf/NaN/overflowing inputs.
    if (!anyNA(num) && all(is.finite(num)) && all(num == trunc(num)) &&
        all(abs(num) <= .Machine$integer.max)) {
      return(as.integer(num))
    }
  } else if (letter %in% c("e", "E", "f", "g", "G", "a", "A")) {
    num <- suppressWarnings(as.numeric(value))
    if (!anyNA(num)) {
      return(num)
    }
  }

  value
}

#' Render a value with sprintf, splitting the flag from the value but keeping
#' the value as one token (for joined list values that may contain spaces)
#' @keywords internal
render_nosplit <- function(value, argstr) {
  value <- coerce_for_argstr(value, argstr)
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
  value <- coerce_for_argstr(value, argstr)
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
