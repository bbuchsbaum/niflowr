#!/usr/bin/env Rscript

parse_args <- function(args) {
  out <- list(
    spec = "inst/specs/dcm2niix.convert.json",
    mode = "check",
    write = FALSE,
    strict = FALSE,
    help_file = NULL
  )

  i <- 1L
  while (i <= length(args)) {
    a <- args[[i]]
    if (identical(a, "--spec")) {
      i <- i + 1L
      out$spec <- args[[i]]
    } else if (identical(a, "--mode")) {
      i <- i + 1L
      out$mode <- args[[i]]
    } else if (identical(a, "--help-file")) {
      i <- i + 1L
      out$help_file <- args[[i]]
    } else if (identical(a, "--write")) {
      out$write <- TRUE
    } else if (identical(a, "--strict")) {
      out$strict <- TRUE
    } else {
      stop(sprintf("Unknown argument: %s", a), call. = FALSE)
    }
    i <- i + 1L
  }

  if (!out$mode %in% c("check", "sync-desc")) {
    stop("--mode must be one of: check, sync-desc", call. = FALSE)
  }
  out
}

read_help_lines <- function(help_file = NULL) {
  if (!is.null(help_file)) {
    if (!file.exists(help_file)) {
      stop(sprintf("Help file not found: %s", help_file), call. = FALSE)
    }
    return(readLines(help_file, warn = FALSE))
  }

  fetch <- function(arg) {
    out <- tryCatch(
      suppressWarnings(system2("dcm2niix", arg, stdout = TRUE, stderr = TRUE)),
      error = function(e) structure(character(0), status = 127L)
    )
    status <- attr(out, "status")
    if (is.null(status)) status <- 0L
    list(status = status, out = out)
  }

  h <- fetch("-h")
  if ((h$status == 0L || length(h$out) > 0L) && length(h$out) > 0L) return(h$out)

  h2 <- fetch("--help")
  if ((h2$status == 0L || length(h2$out) > 0L) && length(h2$out) > 0L) return(h2$out)

  stop(
    "Unable to read dcm2niix help output. Install dcm2niix or provide --help-file.",
    call. = FALSE
  )
}

clean_desc <- function(x) {
  x <- gsub("[\r\n]+", " ", x)
  x <- gsub("\\s+", " ", x)
  trimws(x)
}

extract_flags <- function(line) {
  m <- gregexpr(
    "-[0-9]+\\.\\.-[0-9]+|--[A-Za-z][A-Za-z0-9_-]*|-[A-Za-z0-9]{1,3}",
    line,
    perl = TRUE
  )[[1]]
  if (identical(m, -1L)) return(character(0))
  regmatches(line, list(m))[[1]]
}

parse_help_options <- function(lines) {
  options <- list()
  for (ln in lines) {
    line <- trimws(ln)
    if (!nzchar(line)) next
    if (!grepl("^-", line)) next

    flags <- extract_flags(line)
    if (length(flags) == 0) next

    desc <- if (grepl(":", line, fixed = TRUE)) {
      sub("^.*?:", "", line)
    } else {
      pos <- regexpr(flags[[1]], line, fixed = TRUE)
      substring(line, pos + nchar(flags[[1]]))
    }
    desc <- clean_desc(desc)
    if (!nzchar(desc)) next

    for (flag in flags) {
      if (is.null(options[[flag]])) {
        options[[flag]] <- desc
      }
    }
  }
  options
}

spec_flag <- function(def) {
  argstr <- def$cli$argstr
  if (!is.character(argstr) || length(argstr) != 1) return(NULL)

  token <- strsplit(trimws(argstr), "\\s+")[[1]][1]
  if (!nzchar(token)) return(NULL)
  if (identical(token, "-%d")) {
    minv <- suppressWarnings(as.numeric(def$validate$min %||% NA))
    maxv <- suppressWarnings(as.numeric(def$validate$max %||% NA))
    if (!is.na(minv) && !is.na(maxv) && minv == 1 && maxv == 9) {
      return("-1..-9")
    }
    return(token)
  }

  if (!grepl("^-", token)) return(NULL)
  token
}

`%||%` <- function(x, y) if (is.null(x)) y else x

spec_flag_map <- function(spec) {
  out <- list()
  for (nm in names(spec$inputs)) {
    def <- spec$inputs[[nm]]
    fl <- spec_flag(def)
    if (!is.null(fl)) {
      out[[nm]] <- fl
    }
  }
  out
}

sync_descriptions <- function(spec, help_opts) {
  updated <- 0L
  for (nm in names(spec$inputs)) {
    def <- spec$inputs[[nm]]
    fl <- spec_flag(def)
    if (is.null(fl)) next
    desc <- help_opts[[fl]]
    if (is.null(desc) || !nzchar(desc)) next
    if (!identical(def$desc, desc)) {
      spec$inputs[[nm]]$desc <- desc
      updated <- updated + 1L
    }
  }
  list(spec = spec, updated = updated)
}

main <- function() {
  cfg <- parse_args(commandArgs(trailingOnly = TRUE))
  if (!file.exists(cfg$spec)) stop(sprintf("Spec not found: %s", cfg$spec), call. = FALSE)

  lines <- read_help_lines(cfg$help_file)
  help_opts <- parse_help_options(lines)
  if (length(help_opts) == 0) {
    stop("No dcm2niix options parsed from help output.", call. = FALSE)
  }

  spec <- jsonlite::read_json(cfg$spec, simplifyVector = FALSE)
  flag_map <- spec_flag_map(spec)
  spec_flags <- unique(unname(unlist(flag_map, use.names = FALSE)))
  help_flags <- sort(unique(names(help_opts)), method = "radix")

  ignore_help <- c("-h", "--help", "--version")
  help_for_compare <- setdiff(help_flags, ignore_help)

  missing_in_spec <- setdiff(help_for_compare, spec_flags)
  stale_in_spec <- setdiff(spec_flags, help_for_compare)

  cat(sprintf("Parsed help flags: %d\n", length(help_flags)))
  cat(sprintf("Spec CLI flags: %d\n", length(spec_flags)))
  cat(sprintf("Missing in spec: %d\n", length(missing_in_spec)))
  if (length(missing_in_spec) > 0) {
    cat("  ", paste(missing_in_spec, collapse = ", "), "\n", sep = "")
  }
  cat(sprintf("Stale in spec: %d\n", length(stale_in_spec)))
  if (length(stale_in_spec) > 0) {
    cat("  ", paste(stale_in_spec, collapse = ", "), "\n", sep = "")
  }

  if (identical(cfg$mode, "sync-desc")) {
    synced <- sync_descriptions(spec, help_opts)
    cat(sprintf("Descriptions updated: %d\n", synced$updated))
    if (isTRUE(cfg$write) && synced$updated > 0L) {
      jsonlite::write_json(
        synced$spec,
        path = cfg$spec,
        pretty = TRUE,
        auto_unbox = TRUE,
        null = "null"
      )
      cat(sprintf("Wrote %s\n", cfg$spec))
    } else if (isTRUE(cfg$write)) {
      cat("No description changes to write.\n")
    }
  }

  if (isTRUE(cfg$strict) && (length(missing_in_spec) > 0L || length(stale_in_spec) > 0L)) {
    quit(status = 1L)
  }
}

main()
