# Use inline specs to test validation logic independent of bundled spec contents

make_test_spec <- function() {
  structure(list(
    spec_version = "0.1.0",
    id = "test.validate",
    command = "testcmd",
    inputs = list(
      in_file = list(
        type = "file",
        required = TRUE,
        validate = list(exists = TRUE),
        cli = list(argstr = "%s", position = 0L)
      ),
      out_file = list(
        type = "file",
        required = TRUE,
        cli = list(argstr = "%s", position = 1L)
      ),
      frac = list(
        type = "double",
        validate = list(min = 0, max = 1),
        cli = list(argstr = "-f %f")
      ),
      mask = list(
        type = "flag",
        cli = list(argstr = "-m")
      ),
      mode_a = list(
        type = "flag",
        cli = list(argstr = "-A"),
        constraints = list(xor = c("mode_a", "mode_b"))
      ),
      mode_b = list(
        type = "flag",
        cli = list(argstr = "-B"),
        constraints = list(xor = c("mode_a", "mode_b"))
      )
    ),
    outputs = list()
  ), class = "ni_spec")
}

test_that("validate_inputs catches missing required params", {
  spec <- make_test_spec()
  # Missing both required params
  expect_error(
    niflowr:::validate_inputs(spec, list()),
    "validation failed"
  )
  # Missing out_file
  expect_error(
    niflowr:::validate_inputs(spec, list(in_file = "/tmp/test.nii")),
    "validation failed"
  )
})

test_that("validate_inputs catches file-not-exists", {
  spec <- make_test_spec()
  expect_error(
    niflowr:::validate_inputs(spec, list(
      in_file = "/nonexistent/file.nii.gz",
      out_file = "/tmp/out.nii.gz"
    )),
    "validation failed"
  )
})

test_that("validate_inputs catches out-of-range numeric", {
  spec <- make_test_spec()
  withr::with_tempfile("tf", fileext = ".nii.gz", {
    file.create(tf)
    expect_error(
      niflowr:::validate_inputs(spec, list(
        in_file = tf,
        out_file = "/tmp/out.nii.gz",
        frac = 1.5  # max is 1.0
      )),
      "validation failed"
    )
    expect_error(
      niflowr:::validate_inputs(spec, list(
        in_file = tf,
        out_file = "/tmp/out.nii.gz",
        frac = -0.1  # min is 0.0
      )),
      "validation failed"
    )
  })
})

test_that("validate_inputs catches xor violations", {
  spec <- make_test_spec()
  withr::with_tempfile("tf", fileext = ".nii.gz", {
    file.create(tf)
    expect_error(
      niflowr:::validate_inputs(spec, list(
        in_file = tf,
        out_file = "/tmp/out.nii.gz",
        mode_a = TRUE,
        mode_b = TRUE
      )),
      "validation failed"
    )
  })
})

test_that("validate_inputs passes with valid inputs", {
  spec <- make_test_spec()
  withr::with_tempfile("tf", fileext = ".nii.gz", {
    file.create(tf)
    result <- niflowr:::validate_inputs(spec, list(
      in_file = tf,
      out_file = "/tmp/out.nii.gz",
      frac = 0.5,
      mask = TRUE
    ))
    expect_true(result)
  })
})

test_that("validate_inputs catches wrong type", {
  spec <- make_test_spec()
  withr::with_tempfile("tf", fileext = ".nii.gz", {
    file.create(tf)
    expect_error(
      niflowr:::validate_inputs(spec, list(
        in_file = tf,
        out_file = "/tmp/out.nii.gz",
        frac = "not a number"
      )),
      "validation failed"
    )
  })
})

# ---- Additional validation tests ----

test_that("validate_type rejects non-integer for int type", {
  errs <- niflowr:::validate_type("x", 1.5, list(type = "int"))
  expect_true(length(errs) > 0)
  expect_match(errs[1], "whole number")
})

test_that("validate_type rejects non-numeric for double type", {
  errs <- niflowr:::validate_type("x", "abc", list(type = "double"))
  expect_true(length(errs) > 0)
  expect_match(errs[1], "number")
})

test_that("validate_type accepts numeric for double type", {
  errs <- niflowr:::validate_type("x", 3.14, list(type = "double"))
  expect_equal(length(errs), 0)
})

test_that("validate_type rejects named list for list type", {
  # list type expects character or numeric vector, not a named list
  errs <- niflowr:::validate_type("x", list(a = 1), list(type = "list"))
  expect_true(length(errs) > 0)
})

test_that("validate_type accepts character vector for list type", {
  errs <- niflowr:::validate_type("x", c("a", "b", "c"), list(type = "list"))
  expect_equal(length(errs), 0)
})

test_that("validate_type accepts numeric vector for list type", {
  errs <- niflowr:::validate_type("x", c(1, 2, 3), list(type = "list"))
  expect_equal(length(errs), 0)
})

test_that("validate_constraints_single checks min", {
  errs <- niflowr:::validate_constraints_single("x", 5, list(min = 10))
  expect_true(length(errs) > 0)
  expect_match(errs[1], ">=")
})

test_that("validate_constraints_single checks max", {
  errs <- niflowr:::validate_constraints_single("x", 15, list(max = 10))
  expect_true(length(errs) > 0)
  expect_match(errs[1], "<=")
})

test_that("validate_constraints_single checks regex", {
  errs <- niflowr:::validate_constraints_single("x", "abc123", list(regex = "^[0-9]+$"))
  expect_true(length(errs) > 0)
  expect_match(errs[1], "pattern")
})

test_that("validate_constraints_single passes when constraints met", {
  errs <- niflowr:::validate_constraints_single("x", 5, list(min = 1, max = 10))
  expect_equal(length(errs), 0)
})

test_that("validate_constraints_single checks dir existence", {
  errs <- niflowr:::validate_constraints_single("x", "/nonexistent_dir", list(exists = TRUE), type = "dir")
  expect_true(length(errs) > 0)
  expect_match(errs[1], "Directory")
})

test_that("validate_constraints_single checks file existence", {
  errs <- niflowr:::validate_constraints_single("x", "/nonexistent_file.txt", list(exists = TRUE), type = "file")
  expect_true(length(errs) > 0)
  expect_match(errs[1], "File")
})

test_that("is_missing_value returns TRUE for NULL", {
  expect_true(niflowr:::is_missing_value(NULL))
})

test_that("is_missing_value returns FALSE for non-NULL values", {
  expect_false(niflowr:::is_missing_value(1))
  expect_false(niflowr:::is_missing_value("a"))
  expect_false(niflowr:::is_missing_value(TRUE))
  expect_false(niflowr:::is_missing_value(list(a = 1)))
})
