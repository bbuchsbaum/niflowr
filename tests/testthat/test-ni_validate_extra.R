test_that("validate_inputs rejects unknown parameters", {
  spec <- ni_spec_read("fsl.bet")
  withr::with_tempfile("tf", fileext = ".nii.gz", {
    file.create(tf)
    expect_error(
      niflowr:::validate_inputs(spec, list(
        in_file = tf,
        out_file = "/tmp/out.nii.gz",
        maask = TRUE  # typo for "mask"
      )),
      "Unknown parameter"
    )
  })
})

test_that("validate_type rejects non-integer for int type", {
  errs <- niflowr:::validate_type("dof", 3.5, list(type = "int"))
  expect_true(length(errs) > 0)
  expect_match(errs[1], "whole number")
})

test_that("validate_type accepts integer values for int type", {
  errs <- niflowr:::validate_type("dof", 6, list(type = "int"))
  expect_equal(length(errs), 0)

  errs2 <- niflowr:::validate_type("dof", 6L, list(type = "int"))
  expect_equal(length(errs2), 0)
})

test_that("validate_constraints_single uses dir.exists for dir type", {
  withr::with_tempdir({
    d <- file.path(getwd(), "existing_dir")
    dir.create(d)
    errs <- niflowr:::validate_constraints_single(
      "subjects_dir", d, list(exists = TRUE), type = "dir"
    )
    expect_equal(length(errs), 0)

    errs2 <- niflowr:::validate_constraints_single(
      "subjects_dir", "/nonexistent/dir", list(exists = TRUE), type = "dir"
    )
    expect_true(length(errs2) > 0)
    expect_match(errs2[1], "Directory")
  })
})
