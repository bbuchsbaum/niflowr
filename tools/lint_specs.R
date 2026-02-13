#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
fix <- "--fix" %in% args
strict <- "--strict" %in% args

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
  source("R/ni_forge.R")
  invisible(TRUE)
}

suppressPackageStartupMessages(bootstrap_niflowr())

findings <- ni_lint_specs(
  spec_dir = "inst/specs",
  strict = FALSE,
  fix = fix,
  write = fix
)

if (nrow(findings) == 0) {
  cat("No lint findings.\n")
  quit(status = 0)
}

print(findings)

errors <- findings[findings$level == "error" & !findings$fixed, , drop = FALSE]
if (strict && nrow(errors) > 0) {
  cat("\nUnresolved lint errors:", nrow(errors), "\n")
  quit(status = 1)
}
