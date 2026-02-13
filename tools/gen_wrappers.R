#!/usr/bin/env Rscript
# Generate R wrapper functions from JSON specs
#
# Usage: Rscript tools/gen_wrappers.R
#
# Reads all inst/specs/*.json and generates R/wrappers_auto.R

library(jsonlite)

spec_dir <- "inst/specs"
output_file <- "R/wrappers_auto.R"

spec_files <- list.files(spec_dir, pattern = "\\.json$", full.names = TRUE)

# Map spec type to R default value representation
type_default <- function(def) {
  if (!is.null(def$default)) {
    val <- def$default
    if (is.character(val)) {
      if (length(val) == 1) return(paste0('"', val, '"'))
      return(paste0("c(", paste0('"', val, '"', collapse = ", "), ")"))
    }
    if (is.logical(val)) {
      if (length(val) == 1) return(if (val) "TRUE" else "FALSE")
      return(paste0("c(", paste(ifelse(val, "TRUE", "FALSE"), collapse = ", "), ")"))
    }
    if (is.numeric(val)) {
      if (length(val) == 1) return(as.character(val))
      return(paste0("c(", paste(as.character(val), collapse = ", "), ")"))
    }
    return("NULL")
  }
  "NULL"
}

# Map spec type to R @param type description
type_desc <- function(def) {
  base <- switch(def$type,
    file = "Character; file path",
    dir = "Character; directory path",
    string = "Character",
    int = "Integer",
    double = "Numeric",
    bool = "Logical",
    flag = "Logical",
    enum = paste0("Character; one of: ", paste0('"', def$choices, '"', collapse = ", ")),
    list = "Character or numeric vector",
    "Character"
  )
  if (!is.null(def$desc)) {
    # Escape special roxygen2 characters in Nipype descriptions
    desc <- gsub("\\{", "\\\\{", def$desc)
    desc <- gsub("\\}", "\\\\}", desc)
    desc <- gsub("\\[", "\\\\[", desc)
    desc <- gsub("\\]", "\\\\]", desc)
    desc <- gsub("[\r\n]+", " ", desc)
    desc <- gsub("\\s+", " ", desc)
    desc <- trimws(desc)
    paste0(base, ". ", desc)
  } else {
    base
  }
}

# Convert spec id to R function name: fsl.bet -> ni_fsl_bet
spec_id_to_func <- function(id) {
  paste0("ni_", gsub("\\.", "_", id))
}

# Generate one wrapper function
gen_wrapper <- function(spec_path) {
  spec <- fromJSON(spec_path, simplifyVector = TRUE, simplifyDataFrame = FALSE)

  func_name <- spec_id_to_func(spec$id)
  inputs <- spec$inputs

  # Reserved wrapper argument names used for execution controls
  reserved_names <- c(".cwd", ".env", ".container", "dry_run", "echo")
  safe_formal_name <- function(nm) {
    out <- if (nm %in% reserved_names) paste0(nm, "_arg") else nm
    out <- gsub("[^A-Za-z0-9_.]", "_", out)
    if (!grepl("^[A-Za-z.]", out)) {
      out <- paste0("param_", out)
    }
    out
  }

  # De-duplicate repeated input names (seen in some imported specs)
  input_names <- names(inputs)
  if (length(input_names) > 0) {
    keep <- !duplicated(input_names)
    inputs <- inputs[keep]
    input_names <- names(inputs)
  }

  # Build stable mapping: spec input name -> syntactic/unique function arg name
  formal_base <- vapply(input_names, safe_formal_name, character(1))
  formal_unique <- make.unique(formal_base, sep = "_")
  name_map <- stats::setNames(formal_unique, input_names)

  # Separate required and optional params
  req_names <- character(0)
  opt_names <- character(0)
  for (nm in names(inputs)) {
    if (isTRUE(inputs[[nm]]$required)) {
      req_names <- c(req_names, nm)
    } else {
      opt_names <- c(opt_names, nm)
    }
  }

  # Build function signature
  params <- character(0)
  fwd_pairs <- character(0)
  for (nm in req_names) {
    formal_nm <- name_map[[nm]]
    params <- c(params, formal_nm)
    fwd_pairs <- c(fwd_pairs, paste0(nm, " = ", formal_nm))
  }
  for (nm in opt_names) {
    def <- inputs[[nm]]
    formal_nm <- name_map[[nm]]
    params <- c(params, paste0(formal_nm, " = ", type_default(def)))
    fwd_pairs <- c(fwd_pairs, paste0(nm, " = ", formal_nm))
  }
  params <- c(params, ".cwd = NULL", ".env = NULL", ".container = NULL",
              "dry_run = FALSE", "echo = interactive()")
  sig <- paste(params, collapse = ",\n                     ")

  # Build roxygen
  roxy <- character(0)
  roxy <- c(roxy, paste0("#' ", spec$title))
  roxy <- c(roxy, "#'")
  if (!is.null(spec$description)) {
    roxy <- c(roxy, paste0("#' ", spec$description))
    roxy <- c(roxy, "#'")
  }
  for (nm in c(req_names, opt_names)) {
    def <- inputs[[nm]]
    tag <- if (isTRUE(def$required)) " **Required.**" else ""
    formal_nm <- name_map[[nm]]
    alias_note <- if (formal_nm != nm) paste0(" (spec input: ", nm, ")") else ""
    roxy <- c(roxy, paste0("#' @param ", formal_nm, " ", type_desc(def), alias_note, tag))
  }
  roxy <- c(roxy, "#' @param .cwd Working directory override.")
  roxy <- c(roxy, "#' @param .env Named character vector of environment variables.")
  roxy <- c(roxy, "#' @param .container Container configuration list.")
  roxy <- c(roxy, "#' @param dry_run Logical; preview command without executing.")
  roxy <- c(roxy, "#' @param echo Logical; echo stdout/stderr in real time.")
  roxy <- c(roxy, "#' @return An `ni_result` object.")
  roxy <- c(roxy, "#' @export")

  # Build the argument-forwarding call
  fwd <- paste(fwd_pairs, collapse = ", ")

  # Assemble function body
  lines <- c(
    paste(roxy, collapse = "\n"),
    paste0(func_name, " <- function(", sig, ") {"),
    paste0('  call <- ni_call("', spec$id, '", ', fwd,
           ", .cwd = .cwd, .env = .env, .container = .container)"),
    "  ni_run(call, dry_run = dry_run, echo = echo)",
    "}"
  )

  paste(lines, collapse = "\n")
}

# Generate all wrappers
cat("Generating wrappers from", length(spec_files), "specs...\n")

header <- paste0(
  "# Auto-generated wrapper functions — do not edit by hand\n",
  "# Generated by tools/gen_wrappers.R on ", Sys.Date(), "\n",
  "# Regenerate with: Rscript tools/gen_wrappers.R\n",
  "\n"
)

bodies <- vapply(spec_files, gen_wrapper, character(1))
content <- paste0(header, paste(bodies, collapse = "\n\n"), "\n")

writeLines(content, output_file)
cat("Wrote", output_file, "\n")
