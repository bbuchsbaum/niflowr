# Tests for the staged antsRegistration custom renderer (issue #3)

test_that("ants.registration declares the staged custom renderer", {
  spec <- ni_spec_read("ants.registration")
  expect_s3_class(spec, "ni_spec")
  expect_equal(spec$command, "antsRegistration")
  expect_equal(spec$render, "ants_registration_staged")
})

test_that("ants.registration renders a runnable staged command (#3)", {
  call <- ni_call("ants.registration",
    fixed_image = "fixed.nii.gz",
    moving_image = "moving.nii.gz",
    transforms = c("Rigid", "Affine", "SyN"),
    metric = c("MI", "MI", "CC"),
    metric_weight = c(1, 1, 1),
    shrink_factors = c("8x4x2x1", "8x4x2x1", "8x4x2x1"),
    smoothing_sigmas = c("3x2x1x0vox", "3x2x1x0vox", "3x2x1x0vox"),
    output_transform_prefix = "out_",
    write_composite_transform = TRUE,
    random_seed = 1,
    dimension = 3,
    .validate = FALSE
  )
  cmd <- ni_cmd(call)
  a <- cmd$args

  expect_equal(cmd$command, "antsRegistration")
  # no leaked printf placeholders anywhere
  expect_false(any(grepl("%", a, fixed = TRUE)))
  expect_true(all(c("--dimensionality", "3") %in% a))

  # three transform stages, in order
  ti <- which(a == "--transform")
  expect_length(ti, 3)
  expect_equal(a[ti + 1], c("Rigid[0.1]", "Affine[0.1]", "SyN[0.1,3,0]"))

  # fixed and moving image paths appear inside every metric clause
  mi <- which(a == "--metric")
  expect_length(mi, 3)
  expect_true(all(grepl("fixed.nii.gz", a[mi + 1], fixed = TRUE)))
  expect_true(all(grepl("moving.nii.gz", a[mi + 1], fixed = TRUE)))
  expect_equal(a[mi + 1][1], "MI[fixed.nii.gz,moving.nii.gz,1,32]")
  expect_equal(a[mi + 1][3], "CC[fixed.nii.gz,moving.nii.gz,1,4]")

  # shrink factors and smoothing sigmas, per stage, in order
  expect_equal(a[which(a == "--shrink-factors") + 1], rep("8x4x2x1", 3))
  expect_equal(a[which(a == "--smoothing-sigmas") + 1], rep("3x2x1x0vox", 3))

  # output prefix and composite transform flag
  expect_true(all(c("--output", "out_") %in% a))
  wi <- which(a == "--write-composite-transform")
  expect_length(wi, 1)
  expect_equal(a[wi + 1], "1")
  expect_true(all(c("--random-seed", "1") %in% a))
})

test_that("ants.registration recycles a single fixed/moving image across stages", {
  call <- ni_call("ants.registration",
    fixed_image = "fixed.nii.gz",
    moving_image = "moving.nii.gz",
    transforms = c("Rigid", "SyN"),
    metric = c("MI", "CC"),
    metric_weight = c(1, 1),
    shrink_factors = c("4x2x1", "4x2x1"),
    smoothing_sigmas = c("2x1x0vox", "2x1x0vox"),
    output_transform_prefix = "r_",
    .validate = FALSE
  )
  a <- ni_cmd(call)$args
  mi <- which(a == "--metric")
  expect_length(mi, 2)
  expect_true(all(grepl("fixed.nii.gz,moving.nii.gz", a[mi + 1], fixed = TRUE)))
})

test_that("ants.registration rejects mismatched per-stage level counts", {
  call <- ni_call("ants.registration",
    fixed_image = "f.nii.gz",
    moving_image = "m.nii.gz",
    transforms = "SyN",
    metric = "CC",
    metric_weight = 1,
    shrink_factors = "8x4x2x1",        # 4 levels
    smoothing_sigmas = "3x2x1x0x0vox", # 5 levels
    output_transform_prefix = "p_",
    .validate = FALSE
  )
  expect_error(ni_cmd(call), "level")
})

test_that("ants.registration passes through args / save_state / restore_state", {
  call <- ni_call("ants.registration",
    fixed_image = "f.nii.gz",
    moving_image = "m.nii.gz",
    transforms = "Rigid",
    metric = "MI",
    metric_weight = 1,
    shrink_factors = "1",
    smoothing_sigmas = "0vox",
    output_transform_prefix = "p_",
    save_state = "state.mat",
    restore_state = "prev.mat",
    args = "--verbose 1",
    .validate = FALSE
  )
  a <- ni_cmd(call)$args
  expect_true(all(c("--save-state", "state.mat") %in% a))
  expect_true(all(c("--restore-state", "prev.mat") %in% a))
  expect_true(all(c("--verbose", "1") %in% a))
})
