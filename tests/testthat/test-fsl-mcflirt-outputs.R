test_that("mcflirt declares gated side outputs from stripped out basename (#13)", {
  call <- ni_call(
    "fsl.mcflirt",
    in_file = "/tmp/sub-01_task-rest_bold.nii.gz",
    out_file = "/tmp/sub-01_desc-mcf_bold.nii.gz",
    save_mats = TRUE,
    save_plots = TRUE,
    mean_vol = TRUE,
    .validate = FALSE
  )

  built <- niflowr:::build_command(call)
  out_idx <- which(built$args == "-out")
  expect_equal(built$args[[out_idx + 1L]], "/tmp/sub-01_desc-mcf_bold")

  expect_equal(call$outputs$out_file, "/tmp/sub-01_desc-mcf_bold.nii.gz")
  expect_equal(call$outputs$par_file, "/tmp/sub-01_desc-mcf_bold.par")
  expect_equal(call$outputs$mat_dir, "/tmp/sub-01_desc-mcf_bold.mat")
  expect_equal(call$outputs$mean_img, "/tmp/sub-01_desc-mcf_bold_mean_reg.nii.gz")
  expect_null(call$outputs$variance_img)
  expect_null(call$outputs$rms_abs_file)
})

test_that("mcflirt side outputs omit gated artifacts when flags are off", {
  call <- ni_call(
    "fsl.mcflirt",
    in_file = "/tmp/bold.nii.gz",
    out_file = "/tmp/bold_mc.nii.gz",
    .validate = FALSE
  )
  expect_equal(names(call$outputs), "out_file")
})

test_that("mcflirt stats and rms outputs appear when requested", {
  call <- ni_call(
    "fsl.mcflirt",
    in_file = "/tmp/bold.nii.gz",
    out_file = "/tmp/bold_mc.nii.gz",
    stats_imgs = TRUE,
    save_rms = TRUE,
    .validate = FALSE
  )
  expect_equal(call$outputs$variance_img, "/tmp/bold_mc_variance.nii.gz")
  expect_equal(call$outputs$std_img, "/tmp/bold_mc_sigma.nii.gz")
  expect_equal(call$outputs$rms_abs_file, "/tmp/bold_mc_abs.rms")
  expect_equal(call$outputs$rms_rel_file, "/tmp/bold_mc_rel.rms")
})
