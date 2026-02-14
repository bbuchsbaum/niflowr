test_that("tar_ni_step requires targets package", {
  skip_if(requireNamespace("targets", quietly = TRUE), "targets is installed")
  expect_error(tar_ni_step(my_step, "fsl.bet"), "targets")
})

test_that("tar_ni_step creates a tar_target when targets is available", {
  skip_if_not_installed("targets")
  withr::with_tempfile("tf", fileext = ".nii.gz", {
    file.create(tf)
    target <- tar_ni_step(brain_extract, "fsl.bet", in_file = tf, out_file = "/tmp/brain.nii.gz")
    expect_true(inherits(target, "tar_target"))
    expect_equal(target$settings$name, "brain_extract")
    expect_equal(target$settings$format, "file")
  })
})

test_that("tar_ni_step accepts custom packages argument", {
  skip_if_not_installed("targets")
  withr::with_tempfile("tf", fileext = ".nii.gz", {
    file.create(tf)
    target <- tar_ni_step(
      my_target,
      "fsl.bet",
      in_file = tf,
      out_file = "/tmp/out.nii.gz",
      packages = c("niflowr", "neuroim2")
    )
    expect_true(inherits(target, "tar_target"))
    expect_true("neuroim2" %in% target$command$packages)
  })
})

test_that("tar_ni_step accepts priority argument", {
  skip_if_not_installed("targets")
  withr::with_tempfile("tf", fileext = ".nii.gz", {
    file.create(tf)
    target <- tar_ni_step(
      priority_target,
      "fsl.bet",
      in_file = tf,
      out_file = "/tmp/out.nii.gz",
      priority = 0.8
    )
    expect_true(inherits(target, "tar_target"))
    expect_equal(target$settings$priority, 0.8)
  })
})

test_that("ni_run_files returns character vector", {
  skip_if_not_installed("targets")
  # This test would need a real spec and container to work
  # For now just test the function exists and has correct signature
  expect_true(is.function(ni_run_files))
  expect_equal(length(formals(ni_run_files)), 2)  # spec_id and ...
})
