#!/usr/bin/env Rscript

out <- "tests/golden/cmdline_golden.json"
args <- commandArgs(trailingOnly = TRUE)
if (length(args) >= 1 && nzchar(args[[1]])) {
  out <- args[[1]]
}

bootstrap_niflowr <- function() {
  if (requireNamespace("pkgload", quietly = TRUE)) {
    ok <- tryCatch({
      pkgload::load_all(".", quiet = TRUE)
      TRUE
    }, error = function(e) FALSE)
    if (ok) return(invisible(TRUE))
  }

  source("R/zzz.R")
  source("R/ni_introspection.R")
  source("R/ni_bids.R")
  source("R/ni_config.R")
  source("R/ni_validate.R")
  source("R/ni_spec.R")
  source("R/ni_call.R")
  source("R/ni_build.R")
  source("R/ni_forge.R")
  invisible(TRUE)
}

suppressPackageStartupMessages(bootstrap_niflowr())

ni_golden_cmdline_generate(output = out)
cat("Wrote", out, "\n")
