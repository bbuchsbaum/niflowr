test_that("ni_spec_read loads bundled spec", {
  spec <- ni_spec_read("fsl.bet")
  expect_s3_class(spec, "ni_spec")
  expect_equal(spec$id, "fsl.bet")
  expect_equal(spec$command, "bet")
  expect_true("in_file" %in% names(spec$inputs))
  expect_true("out_file" %in% names(spec$outputs))
})

test_that("ni_spec_read caches specs", {
  spec1 <- ni_spec_read("fsl.bet", cache = TRUE)
  spec2 <- ni_spec_read("fsl.bet", cache = TRUE)
  expect_identical(spec1, spec2)
})

test_that("ni_spec_read errors on missing spec", {
  expect_error(ni_spec_read("nonexistent.tool"), "No bundled spec")
})

test_that("ni_spec_list returns available specs", {
  specs <- ni_spec_list()
  expect_type(specs, "character")
  expect_true("fsl.bet" %in% specs)
})

test_that("print.ni_spec runs without error", {
  spec <- ni_spec_read("fsl.bet")
  expect_no_error(capture.output(print(spec), type = "message"))
})

test_that("ni_spec_validate catches invalid spec", {
  bad_spec <- list(id = "bad", command = "x")
  # Missing required fields: spec_version, inputs, outputs
  expect_error(ni_spec_validate(bad_spec, "test"), "validation failed")
})
