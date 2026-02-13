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
