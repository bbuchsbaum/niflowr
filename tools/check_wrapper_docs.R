#!/usr/bin/env Rscript

parse_args <- function(args) {
  out <- list(
    wrappers = "R/wrappers_auto.R",
    namespace = "NAMESPACE",
    man_dir = "man"
  )

  i <- 1L
  while (i <= length(args)) {
    a <- args[[i]]
    if (identical(a, "--wrappers")) {
      i <- i + 1L
      out$wrappers <- args[[i]]
    } else if (identical(a, "--namespace")) {
      i <- i + 1L
      out$namespace <- args[[i]]
    } else if (identical(a, "--man-dir")) {
      i <- i + 1L
      out$man_dir <- args[[i]]
    } else {
      stop(sprintf("Unknown argument: %s", a), call. = FALSE)
    }
    i <- i + 1L
  }

  out
}

read_text <- function(path) {
  if (!file.exists(path)) {
    stop(sprintf("Missing required file: %s", path), call. = FALSE)
  }
  readLines(path, warn = FALSE)
}

extract_wrapper_names <- function(lines) {
  hits <- grep("^ni_[A-Za-z0-9_]+\\s*<-\\s*function\\(", lines, value = TRUE)
  unique(sub("\\s*<-\\s*function\\(.*$", "", hits))
}

extract_exports <- function(lines) {
  hits <- grep("^export\\([A-Za-z0-9_.]+\\)$", lines, value = TRUE)
  unique(sub("^export\\(([^)]+)\\)$", "\\1", hits))
}

has_alias <- function(rd_lines, fn) {
  needle <- sprintf("\\\\alias\\{%s\\}", fn)
  any(grepl(needle, rd_lines))
}

main <- function() {
  cfg <- parse_args(commandArgs(trailingOnly = TRUE))
  wrapper_lines <- read_text(cfg$wrappers)
  namespace_lines <- read_text(cfg$namespace)

  wrappers <- extract_wrapper_names(wrapper_lines)
  exports <- extract_exports(namespace_lines)
  exported_wrappers <- sort(intersect(wrappers, exports), method = "radix")

  if (length(exported_wrappers) == 0) {
    stop("No exported generated wrappers found to check.", call. = FALSE)
  }

  missing_rd <- character(0)
  missing_alias <- character(0)

  for (fn in exported_wrappers) {
    rd <- file.path(cfg$man_dir, paste0(fn, ".Rd"))
    if (!file.exists(rd)) {
      missing_rd <- c(missing_rd, fn)
      next
    }

    rd_lines <- readLines(rd, warn = FALSE)
    if (!has_alias(rd_lines, fn)) {
      missing_alias <- c(missing_alias, fn)
    }
  }

  if (length(missing_rd) > 0 || length(missing_alias) > 0) {
    cat("Wrapper documentation check failed.\n")
    if (length(missing_rd) > 0) {
      cat("\nMissing Rd files:\n")
      for (fn in missing_rd) cat(" - ", fn, "\n", sep = "")
    }
    if (length(missing_alias) > 0) {
      cat("\nMissing alias in Rd:\n")
      for (fn in missing_alias) cat(" - ", fn, "\n", sep = "")
    }
    quit(status = 1L)
  }

  cat(sprintf(
    "Wrapper documentation check passed: %d exported generated wrappers have matching Rd aliases.\n",
    length(exported_wrappers)
  ))
}

main()
