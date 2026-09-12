test_that("apply_required_defaults fills required inputs that carry a default", {
  spec <- list(inputs = list(
    a = list(required = TRUE, default = 3),
    b = list(required = TRUE),
    c = list(default = 7)
  ))
  v <- niflowr:::apply_required_defaults(spec, list(b = "x"))
  expect_identical(v$a, 3)
  expect_null(v$c)   # optional defaults stay uninjected, so rendered commands are unchanged
})

test_that("a required input carrying a default need not be repeated by the caller", {
  spec <- ni_spec_read("fsl.eddy_correct")
  withdef <- names(Filter(function(d) isTRUE(d$required) && !is.null(d$default), spec$inputs))
  skip_if(!length(withdef), "no required input with a default in this spec")
  req <- names(Filter(function(d) isTRUE(d$required) && is.null(d$default), spec$inputs))
  args <- stats::setNames(lapply(req, function(nm) if (identical(spec$inputs[[nm]]$type, "file")) "in.nii.gz" else "1"), req)
  expect_no_error(do.call(ni_call, c(list("fsl.eddy_correct"), args)))
})
