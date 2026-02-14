# Spec registry — cached loaded specs keyed by id
.spec_registry <- new.env(parent = emptyenv())
.ni_config <- new.env(parent = emptyenv())

# Internal null-coalescing helper
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

#' @importFrom utils packageName
.onLoad <- function(libname, pkgname) {
  # Clear the registry on load

  rm(list = ls(.spec_registry, all.names = TRUE), envir = .spec_registry)

  # Runtime config behavior
  .ni_config$overrides <- list()
  .ni_config$config_file <- "niflowr.yml"
  .ni_config$auto_read <- TRUE
}
