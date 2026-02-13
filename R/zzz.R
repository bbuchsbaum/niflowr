# Spec registry — cached loaded specs keyed by id
.spec_registry <- new.env(parent = emptyenv())

#' @importFrom utils packageName
.onLoad <- function(libname, pkgname) {
  # Clear the registry on load

  rm(list = ls(.spec_registry, all.names = TRUE), envir = .spec_registry)
}
