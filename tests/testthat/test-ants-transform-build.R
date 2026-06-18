# Tests for the high-level ants.transform_build surface (issue #5)

test_that("ants.transform_build spec loads with expected fields (#5)", {
  spec <- ni_spec_read("ants.transform_build")
  expect_s3_class(spec, "ni_spec")
  expect_equal(spec$id, "ants.transform_build")
  expect_equal(spec$command, "antsRegistration")
  expect_equal(spec$render, "ants_transform_build")
  expect_equal(spec$runtime$profile, "ants")
  expect_equal(spec$origin$source, "manual")
  expect_true(isTRUE(spec$inputs$fixed_image$required))
  expect_true(isTRUE(spec$inputs$moving_image$required))
})

test_that("ants.transform_build renders a runnable composite-transform command (#5)", {
  fx <- withr::local_tempfile(fileext = ".nii.gz")
  mv <- withr::local_tempfile(fileext = ".nii.gz")
  file.create(fx)
  file.create(mv)

  call <- ni_call("ants.transform_build",
    fixed_image = fx,
    moving_image = mv,
    output_prefix = "work/xfm_",
    preset = "rigid_affine_syn",
    random_seed = 1
  )
  cmd <- ni_cmd(call)
  a <- cmd$args

  expect_equal(cmd$command, "antsRegistration")
  expect_false(any(grepl("%", a, fixed = TRUE)))
  # rigid + affine + SyN -> three stages
  expect_length(which(a == "--transform"), 3)
  # composite transform written
  wi <- which(a == "--write-composite-transform")
  expect_equal(a[wi + 1], "1")
  # bracketed output with prefix + warped QC image as a single token
  expect_true("[work/xfm_,work/xfm_Warped.nii.gz]" %in% a)
  expect_true(all(c("--random-seed", "1") %in% a))
})

test_that("ants.transform_build preset controls the number of stages (#5)", {
  fx <- withr::local_tempfile(fileext = ".nii.gz")
  mv <- withr::local_tempfile(fileext = ".nii.gz")
  file.create(fx)
  file.create(mv)

  rigid <- ni_cmd(ni_call("ants.transform_build",
    fixed_image = fx, moving_image = mv,
    output_prefix = "r_", preset = "rigid"
  ))$args
  expect_length(which(rigid == "--transform"), 1)

  ra <- ni_cmd(ni_call("ants.transform_build",
    fixed_image = fx, moving_image = mv,
    output_prefix = "ra_", preset = "rigid_affine"
  ))$args
  expect_length(which(ra == "--transform"), 2)
})

test_that("ants.transform_build emits only the masks provided (no literal NULL) (#5)", {
  fx <- withr::local_tempfile(fileext = ".nii.gz")
  mv <- withr::local_tempfile(fileext = ".nii.gz")
  fmask <- withr::local_tempfile(fileext = ".nii.gz")
  file.create(c(fx, mv, fmask))

  a <- ni_cmd(ni_call("ants.transform_build",
    fixed_image = fx, moving_image = mv, output_prefix = "m_",
    fixed_mask = fmask
  ))$args
  mi <- which(a == "--masks")
  expect_length(mi, 1)
  expect_equal(a[mi + 1], sprintf("[%s]", fmask))
  expect_false(any(grepl("NULL", a, fixed = TRUE)))
})

test_that("ants.transform_build exposes ANTs-native composite outputs (#5)", {
  fx <- withr::local_tempfile(fileext = ".nii.gz")
  mv <- withr::local_tempfile(fileext = ".nii.gz")
  file.create(fx)
  file.create(mv)

  call <- ni_call("ants.transform_build",
    fixed_image = fx,
    moving_image = mv,
    output_prefix = "work/xfm_"
  )
  expect_equal(call$outputs$composite_transform, "work/xfm_Composite.h5")
  expect_equal(call$outputs$inverse_composite_transform, "work/xfm_InverseComposite.h5")
  expect_equal(call$outputs$warped_image, "work/xfm_Warped.nii.gz")
})

test_that("ni_ants_transform_build wrapper exists and supports dry_run (#5)", {
  fx <- withr::local_tempfile(fileext = ".nii.gz")
  mv <- withr::local_tempfile(fileext = ".nii.gz")
  file.create(fx)
  file.create(mv)

  expect_true(is.function(ni_ants_transform_build))
  result <- ni_ants_transform_build(
    fixed_image = fx,
    moving_image = mv,
    output_prefix = "work/xfm_",
    .engine = "native",
    dry_run = TRUE
  )
  expect_null(result)
})
