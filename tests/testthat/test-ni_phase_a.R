test_that("ni_call coerces ni_result inputs for pipe-style chaining", {
  prev <- structure(
    list(
      outputs = list(out_file = "/tmp/brain.nii.gz")
    ),
    class = "ni_result"
  )

  call <- ni_call(
    "fsl.flirt",
    in_file = prev,
    reference = "/tmp/ref.nii.gz",
    out_file = "/tmp/reg.nii.gz",
    .validate = FALSE
  )

  expect_equal(call$values$in_file, "/tmp/brain.nii.gz")
})

test_that("ni_call auto-infers BIDS-style out_file when omitted", {
  old_cfg <- ni_config()
  on.exit(ni_config(derivatives_dir = old_cfg$derivatives_dir), add = TRUE)
  ni_config(derivatives_dir = "derivatives/custom")

  in_file <- file.path(tempdir(), "sub-01_T1w.nii.gz")
  file.create(in_file)

  call <- ni_call("fsl.bet", in_file = in_file)

  expect_true(is.character(call$values$out_file))
  expect_match(call$values$out_file, "^derivatives/custom")
  expect_match(call$values$out_file, "desc-brain")
  expect_equal(call$outputs$out_file, call$values$out_file)
})

test_that("ni_call auto-infers fallback out_file for non-BIDS inputs", {
  in_file <- file.path(tempdir(), "subject01_t1.nii.gz")
  file.create(in_file)

  call <- ni_call("fsl.bet", in_file = in_file)

  expect_match(call$values$out_file, "subject01_t1_brain\\.nii\\.gz$")
  expect_equal(dirname(call$values$out_file), dirname(in_file))
})

test_that("ni_inputs returns expected columns and rows", {
  tbl <- ni_inputs("fsl.bet")

  expect_true(all(c("name", "type", "required", "default", "description", "constraints") %in% names(tbl)))
  expect_true(any(tbl$name == "in_file"))
  expect_true(any(tbl$name == "frac"))
})

test_that("ni_constraints exposes xor/validate constraints", {
  tbl <- ni_constraints("fsl.bet")

  expect_true(all(c("input", "constraint", "value") %in% names(tbl)))
  expect_true(any(tbl$constraint == "xor"))
  expect_true(any(tbl$input == "functional"))
})
