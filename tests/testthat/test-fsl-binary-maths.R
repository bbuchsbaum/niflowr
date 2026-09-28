test_that("binary maths accepts exactly one operand and renders it after the operation", {
  input <- tempfile(fileext = ".nii.gz")
  operand <- tempfile(fileext = ".nii.gz")
  output <- tempfile(fileext = ".nii.gz")
  file.create(input, operand)
  withr::defer(unlink(c(input, operand)))
  base <- list(in_file = input, operation = "mul", out_file = output,
               .engine = "native")
  for (value in list(list(operand_file = operand), list(operand_value = 2),
                     list(operand_value = 0), list(operand_value = -0.5))) {
    call <- do.call(ni_call, c(list("fsl.binary_maths"), base, value))
    expected <- if (!is.null(value$operand_file)) operand else sprintf("%.8f", value$operand_value)
    expect_equal(ni_cmd(call)$command, "fslmaths")
    expect_equal(ni_cmd(call)$args,
                 c(input, "-mul", expected, sub("[.]nii[.]gz$", "", output)))
    # Additional maths operations must follow the scalar as well as image operand.
    extra <- do.call(ni_call, c(list("fsl.binary_maths"), base, value, list(args = "-abs")))
    expect_equal(ni_cmd(extra)$args,
                 c(input, "-mul", expected, "-abs", sub("[.]nii[.]gz$", "", output)))
    expect_s3_class(do.call(ni_fsl_binary_maths, c(base, value, list(dry_run = TRUE))),
                    "ni_execution_plan")
  }
  for (fn in list(function(...) ni_call("fsl.binary_maths", ...), ni_fsl_binary_maths)) {
    expect_error(do.call(fn, base), "Required parameter.*operand")
    expect_error(do.call(fn, c(base, list(operand_file = operand, operand_value = 2))),
                 "mutually exclusive")
  }
})

test_that("binary maths scalar position survives spec regeneration", {
  path <- testthat::test_path("../../tools/spec_overrides/fsl.binary_maths.json")
  skip_if_not(file.exists(path), "overrides ship only in the source tree")
  override <- jsonlite::read_json(path)
  expect_equal(override$inputs$operand_value$cli$position,
               ni_spec_read("fsl.binary_maths")$inputs$operand_value$cli$position)
})
