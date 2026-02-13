test_that("ni_call creates a valid call object", {
  spec <- ni_spec_read("fsl.bet")
  withr::with_tempfile("tf", fileext = ".nii.gz", {
    file.create(tf)
    call <- ni_call(spec, in_file = tf, out_file = "/tmp/brain.nii.gz")
    expect_s3_class(call, "ni_call")
    expect_equal(call$values$in_file, tf)
    expect_equal(call$values$out_file, "/tmp/brain.nii.gz")
  })
})

test_that("ni_call resolves output paths", {
  spec <- ni_spec_read("fsl.bet")
  withr::with_tempfile("tf", fileext = ".nii.gz", {
    file.create(tf)
    call <- ni_call(spec, in_file = tf, out_file = "/tmp/brain.nii.gz")
    expect_equal(call$outputs$out_file, "/tmp/brain.nii.gz")
  })
})

test_that("ni_call accepts spec ID string", {
  withr::with_tempfile("tf", fileext = ".nii.gz", {
    file.create(tf)
    call <- ni_call("fsl.bet", in_file = tf, out_file = "/tmp/brain.nii.gz")
    expect_s3_class(call, "ni_call")
    expect_equal(call$spec$id, "fsl.bet")
  })
})

test_that("ni_cmd returns command components", {
  spec <- ni_spec_read("fsl.bet")
  call <- ni_call(spec, in_file = "/tmp/t1.nii.gz", out_file = "/tmp/brain.nii.gz",
                  .validate = FALSE)
  cmd <- ni_cmd(call)
  expect_type(cmd, "list")
  expect_equal(cmd$command, "bet")
  expect_type(cmd$args, "character")
  expect_true(length(cmd$args) >= 2)
})

test_that("print.ni_call runs without error", {
  spec <- ni_spec_read("fsl.bet")
  call <- ni_call(spec, in_file = "/tmp/t1.nii.gz", out_file = "/tmp/brain.nii.gz",
                  .validate = FALSE)
  expect_no_error(capture.output(print(call), type = "message"))
})

test_that("ni_call with .validate = FALSE skips validation", {
  spec <- ni_spec_read("fsl.bet")
  # This would normally fail validation (file doesn't exist)
  call <- ni_call(spec, in_file = "/nonexistent.nii.gz", out_file = "/tmp/out.nii.gz",
                  .validate = FALSE)
  expect_s3_class(call, "ni_call")
})
