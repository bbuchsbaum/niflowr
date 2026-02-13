#' Read a niflowr interface spec
#'
#' Load and validate a JSON spec by ID (looks in bundled specs) or by file path.
#'
#' @param id_or_path A spec ID (e.g. `"fsl.bet"`) or path to a JSON file.
#' @param cache Logical; cache the parsed spec for reuse. Default `TRUE`.
#' @return An `ni_spec` object (S3 list).
#' @export
ni_spec_read <- function(id_or_path, cache = TRUE) {
  id_or_path <- resolve_legacy_spec_id(id_or_path)

  # Check cache first

  if (cache && exists(id_or_path, envir = .spec_registry, inherits = FALSE)) {
    return(get(id_or_path, envir = .spec_registry, inherits = FALSE))
  }

  path <- resolve_spec_path(id_or_path)

  # Validate the raw JSON file against schema (before parsing, to preserve array types)

  ni_spec_validate_file(path)

  raw <- jsonlite::fromJSON(path, simplifyVector = TRUE, simplifyDataFrame = FALSE)

  spec <- structure(raw, class = "ni_spec")

  if (cache) {
    assign(spec$id, spec, envir = .spec_registry)
    if (!identical(id_or_path, spec$id)) {
      assign(id_or_path, spec, envir = .spec_registry)
    }
  }

  spec
}

#' Resolve legacy spec IDs to canonical discovered IDs
#' @keywords internal
resolve_legacy_spec_id <- function(id_or_path) {
  if (!is.character(id_or_path) || length(id_or_path) != 1) {
    return(id_or_path)
  }

  legacy_aliases <- c(
    "afni.3dcalc" = "afni.calc",
    "afni.3dresample" = "afni.resample",
    "fsl.applywarp" = "fsl.apply_warp"
  )

  if (id_or_path %in% names(legacy_aliases)) {
    canonical <- unname(legacy_aliases[[id_or_path]])
    return(canonical)
  }

  id_or_path
}

#' List available bundled specs
#'
#' @return A character vector of spec IDs.
#' @export
ni_spec_list <- function() {
  spec_dir <- system.file("specs", package = "niflowr")
  if (!nzchar(spec_dir)) return(character(0))
  files <- list.files(spec_dir, pattern = "\\.json$", full.names = FALSE)
  sub("\\.json$", "", files)
}

#' Validate a spec JSON file against the schema
#'
#' Validates the raw JSON (before parsing) to preserve array types.
#'
#' @param path Path to a JSON spec file.
#' @return Invisible `TRUE` on success; raises an error on failure.
#' @keywords internal
ni_spec_validate_file <- function(path) {
  schema_path <- system.file("schema", "niflowr-spec-0.1.0.json", package = "niflowr")

  if (!nzchar(schema_path)) {
    cli::cli_warn("Cannot find niflowr spec schema; skipping validation.")
    return(invisible(TRUE))
  }

  json_str <- readLines(path, warn = FALSE)
  json_str <- paste(json_str, collapse = "\n")
  result <- jsonvalidate::json_validate(json_str, schema_path, verbose = TRUE,
                                        engine = "ajv")

  if (!isTRUE(result)) {
    errors <- attr(result, "errors")
    msg <- paste(errors$message, collapse = "\n  ")
    cli::cli_abort(c(
      "Spec validation failed for {.val {path}}:",
      "x" = "{msg}"
    ))
  }

  invisible(TRUE)
}

#' Validate a parsed spec list against the schema
#'
#' @param spec A parsed spec (list).
#' @param source Description of the source (for error messages).
#' @return Invisible `TRUE` on success; raises an error on failure.
#' @keywords internal
ni_spec_validate <- function(spec, source = "spec") {
  schema_path <- system.file("schema", "niflowr-spec-0.1.0.json", package = "niflowr")

  if (!nzchar(schema_path)) {
    cli::cli_warn("Cannot find niflowr spec schema; skipping validation.")
    return(invisible(TRUE))
  }

  json_str <- jsonlite::toJSON(spec, auto_unbox = TRUE, null = "null")
  result <- jsonvalidate::json_validate(json_str, schema_path, verbose = TRUE,
                                        engine = "ajv")

  if (!isTRUE(result)) {
    errors <- attr(result, "errors")
    msg <- paste(errors$message, collapse = "\n  ")
    cli::cli_abort(c(
      "Spec validation failed for {.val {source}}:",
      "x" = "{msg}"
    ))
  }

  invisible(TRUE)
}

#' Resolve a spec ID or path to a file path
#' @keywords internal
resolve_spec_path <- function(id_or_path) {
  # If it looks like a file path (contains / or ends in .json), use directly

  if (grepl("/", id_or_path, fixed = TRUE) || grepl("\\.json$", id_or_path)) {
    if (!file.exists(id_or_path)) {
      cli::cli_abort("Spec file not found: {.path {id_or_path}}")
    }
    return(id_or_path)
  }

  # Otherwise treat as a bundled spec ID

  path <- system.file("specs", paste0(id_or_path, ".json"), package = "niflowr")
  if (!nzchar(path)) {
    available <- ni_spec_list()
    cli::cli_abort(c(
      "No bundled spec found for ID {.val {id_or_path}}.",
      "i" = "Available specs: {.val {available}}"
    ))
  }
  path
}

#' @export
print.ni_spec <- function(x, ...) {
  cli::cli_h2("{x$title %||% x$id}")
  cli::cli_text("Command: {.code {x$command}}")
  cli::cli_text("Spec version: {x$spec_version}")

  if (!is.null(x$description)) {
    cli::cli_text("{x$description}")
  }

  inp_names <- names(x$inputs)
  req <- vapply(x$inputs, function(p) isTRUE(p$required), logical(1))
  cli::cli_h3("Inputs ({length(inp_names)})")
  for (nm in inp_names) {
    p <- x$inputs[[nm]]
    tag <- if (isTRUE(p$required)) " [required]" else ""
    desc <- if (!is.null(p$desc)) paste0(" - ", p$desc) else ""
    cli::cli_text("  {.field {nm}} ({p$type}){tag}{desc}")
  }

  out_names <- names(x$outputs)
  cli::cli_h3("Outputs ({length(out_names)})")
  for (nm in out_names) {
    o <- x$outputs[[nm]]
    cli::cli_text("  {.field {nm}} ({o$type})")
  }

  invisible(x)
}
