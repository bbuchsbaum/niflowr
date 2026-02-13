#' List spec inputs as a table
#'
#' @param spec_id Spec ID, spec path, or `ni_spec` object.
#' @return A data frame (or tibble, if available) describing input parameters.
#' @export
ni_inputs <- function(spec_id) {
  spec <- if (inherits(spec_id, "ni_spec")) spec_id else ni_spec_read(spec_id)
  defs <- spec$inputs

  rows <- lapply(names(defs), function(nm) {
    def <- defs[[nm]]
    constraints <- format_constraints(def$constraints, def$validate)
    choices <- if (!is.null(def$choices)) paste(def$choices, collapse = ", ") else NA_character_

    data.frame(
      name = nm,
      type = def$type %||% NA_character_,
      required = isTRUE(def$required),
      default = format_default_value(def$default),
      description = def$desc %||% NA_character_,
      choices = choices,
      constraints = constraints,
      stringsAsFactors = FALSE
    )
  })

  as_tidy_table(do.call(rbind, rows))
}

#' List spec constraints as a table
#'
#' @param spec_id Spec ID, spec path, or `ni_spec` object.
#' @return A data frame (or tibble, if available) with one row per constraint.
#' @export
ni_constraints <- function(spec_id) {
  spec <- if (inherits(spec_id, "ni_spec")) spec_id else ni_spec_read(spec_id)
  defs <- spec$inputs
  rows <- list()

  for (nm in names(defs)) {
    def <- defs[[nm]]

    if (!is.null(def$constraints)) {
      for (kind in names(def$constraints)) {
        value <- format_constraint_value(def$constraints[[kind]])
        rows[[length(rows) + 1]] <- data.frame(
          input = nm,
          constraint = kind,
          value = value,
          stringsAsFactors = FALSE
        )
      }
    }

    if (!is.null(def$validate)) {
      for (kind in names(def$validate)) {
        value <- format_constraint_value(def$validate[[kind]])
        rows[[length(rows) + 1]] <- data.frame(
          input = nm,
          constraint = paste0("validate.", kind),
          value = value,
          stringsAsFactors = FALSE
        )
      }
    }
  }

  if (length(rows) == 0) {
    empty <- data.frame(
      input = character(0),
      constraint = character(0),
      value = character(0),
      stringsAsFactors = FALSE
    )
    return(as_tidy_table(empty))
  }

  as_tidy_table(do.call(rbind, rows))
}

#' @keywords internal
as_tidy_table <- function(df) {
  if (requireNamespace("tibble", quietly = TRUE)) {
    return(tibble::as_tibble(df))
  }
  df
}

#' @keywords internal
format_default_value <- function(x) {
  if (is.null(x)) return(NA_character_)
  if (length(x) == 0) return(NA_character_)
  if (is.atomic(x) && length(x) == 1) return(as.character(x))
  paste(as.character(unlist(x)), collapse = ", ")
}

#' @keywords internal
format_constraints <- function(constraints, validate) {
  parts <- character(0)

  if (!is.null(constraints)) {
    for (nm in names(constraints)) {
      parts <- c(parts, paste0(nm, "=", format_constraint_value(constraints[[nm]])))
    }
  }

  if (!is.null(validate)) {
    for (nm in names(validate)) {
      parts <- c(parts, paste0("validate.", nm, "=", format_constraint_value(validate[[nm]])))
    }
  }

  if (length(parts) == 0) {
    return(NA_character_)
  }

  paste(parts, collapse = "; ")
}

#' @keywords internal
format_constraint_value <- function(x) {
  if (is.null(x)) return("NULL")
  if (length(x) == 0) return("")
  paste(as.character(unlist(x)), collapse = ", ")
}
