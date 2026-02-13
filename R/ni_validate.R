#' Validate parameter values against a spec
#'
#' Checks required params, types, file existence, numeric ranges, enum membership,
#' xor constraints, and requires constraints.
#'
#' @param spec An `ni_spec` object.
#' @param values Named list of parameter values.
#' @return Invisible `TRUE` on success; raises an error on failure.
#' @keywords internal
validate_inputs <- function(spec, values) {
  errors <- character(0)
  input_defs <- spec$inputs

  # 1. Required params
  for (nm in names(input_defs)) {
    def <- input_defs[[nm]]
    if (isTRUE(def$required) && is_missing_value(values[[nm]])) {
      errors <- c(errors, cli::format_inline(
        "Required parameter {.arg {nm}} is missing."
      ))
    }
  }

  # 2. Type + validation checks for provided values

  for (nm in names(values)) {
    val <- values[[nm]]
    if (is_missing_value(val)) next
    def <- input_defs[[nm]]
    if (is.null(def)) {
      errors <- c(errors, cli::format_inline(
        "Unknown parameter {.arg {nm}}. Available parameters: {.val {names(input_defs)}}"
      ))
      next
    }

    # Type-specific checks
    errs <- validate_type(nm, val, def)
    errors <- c(errors, errs)

    # Validate block
    if (!is.null(def$validate)) {
      errs <- validate_constraints_single(nm, val, def$validate, type = def$type)
      errors <- c(errors, errs)
    }

    # Enum choices
    if (def$type == "enum" && !is.null(def$choices)) {
      if (!val %in% def$choices) {
        errors <- c(errors, cli::format_inline(
          "{.arg {nm}} must be one of {.val {def$choices}}, got {.val {val}}."
        ))
      }
    }
  }

  # 3. XOR constraints
  errors <- c(errors, validate_xor(input_defs, values))

  # 4. Requires constraints
  errors <- c(errors, validate_requires(input_defs, values))

  if (length(errors) > 0) {
    header <- cli::format_inline(
      "Input validation failed for {.val {spec$id}}:"
    )
    cli::cli_abort(c(header, stats::setNames(errors, rep("x", length(errors)))))
  }

  invisible(TRUE)
}

#' Check a value matches the expected type
#' @keywords internal
validate_type <- function(name, value, def) {
  errors <- character(0)
  switch(def$type,
    file = , dir = , string = {
      if (!is.character(value) || length(value) != 1) {
        errors <- c(errors, cli::format_inline(
          "{.arg {name}} must be a single character string."
        ))
      }
    },
    int = {
      if (!is.numeric(value) || length(value) != 1) {
        errors <- c(errors, cli::format_inline(
          "{.arg {name}} must be a single integer."
        ))
      } else if (value != trunc(value)) {
        errors <- c(errors, cli::format_inline(
          "{.arg {name}} must be a whole number, got {.val {value}}."
        ))
      }
    },
    double = {
      if (!is.numeric(value) || length(value) != 1) {
        errors <- c(errors, cli::format_inline(
          "{.arg {name}} must be a single number."
        ))
      }
    },
    bool = , flag = {
      if (!is.logical(value) || length(value) != 1) {
        errors <- c(errors, cli::format_inline(
          "{.arg {name}} must be a single logical value."
        ))
      }
    },
    enum = {
      if (!is.character(value) || length(value) != 1) {
        errors <- c(errors, cli::format_inline(
          "{.arg {name}} must be a single character string."
        ))
      }
    },
    list = {
      if (!is.character(value) && !is.numeric(value)) {
        errors <- c(errors, cli::format_inline(
          "{.arg {name}} must be a character or numeric vector."
        ))
      }
    }
  )
  errors
}

#' Check single-param validation constraints (exists, min, max, regex)
#' @keywords internal
validate_constraints_single <- function(name, value, validate_block, type = NULL) {
  errors <- character(0)

  if (isTRUE(validate_block$exists) && is.character(value)) {
    exists_check <- if (identical(type, "dir")) dir.exists(value) else file.exists(value)
    if (!exists_check) {
      label <- if (identical(type, "dir")) "Directory" else "File"
      errors <- c(errors, cli::format_inline(
        "{label} for {.arg {name}} does not exist: {.path {value}}"
      ))
    }
  }

  if (!is.null(validate_block$min) && is.numeric(value)) {
    if (value < validate_block$min) {
      errors <- c(errors, cli::format_inline(
        "{.arg {name}} must be >= {validate_block$min}, got {value}."
      ))
    }
  }

  if (!is.null(validate_block$max) && is.numeric(value)) {
    if (value > validate_block$max) {
      errors <- c(errors, cli::format_inline(
        "{.arg {name}} must be <= {validate_block$max}, got {value}."
      ))
    }
  }

  if (!is.null(validate_block$regex) && is.character(value)) {
    if (!grepl(validate_block$regex, value)) {
      errors <- c(errors, cli::format_inline(
        "{.arg {name}} must match pattern {.code {validate_block$regex}}."
      ))
    }
  }

  errors
}

#' Check XOR constraints across parameters
#' @keywords internal
validate_xor <- function(input_defs, values) {
  errors <- character(0)
  # Collect xor groups
  seen_groups <- list()

  for (nm in names(input_defs)) {
    def <- input_defs[[nm]]
    xor_group <- def$constraints$xor
    if (is.null(xor_group)) next

    group_key <- paste(sort(xor_group), collapse = "|")
    if (group_key %in% names(seen_groups)) next
    seen_groups[[group_key]] <- TRUE

    # Count how many in the group are set
    set_params <- Filter(function(p) !is_missing_value(values[[p]]), xor_group)

    if (length(set_params) > 1) {
      errors <- c(errors, cli::format_inline(
        "Parameters {.arg {set_params}} are mutually exclusive (xor group)."
      ))
    }
  }

  errors
}

#' Check requires constraints across parameters
#' @keywords internal
validate_requires <- function(input_defs, values) {
  errors <- character(0)

  for (nm in names(input_defs)) {
    val <- values[[nm]]
    if (is_missing_value(val)) next

    def <- input_defs[[nm]]
    req <- def$constraints$requires
    if (is.null(req)) next

    missing_req <- Filter(function(p) is_missing_value(values[[p]]), req)
    if (length(missing_req) > 0) {
      errors <- c(errors, cli::format_inline(
        "{.arg {nm}} requires {.arg {missing_req}} to also be set."
      ))
    }
  }

  errors
}

#' Test if a value is missing/unset
#' @keywords internal
is_missing_value <- function(x) {
  is.null(x) || (is.logical(x) && length(x) == 1 && isFALSE(x) && FALSE) # NULL only
}
