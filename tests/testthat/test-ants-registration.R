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

# ---- #27: declared defaults and transform parameters ----------------------

test_that("ni_ants_registration() runs with its own winsorize defaults (#27)", {
  wd <- withr::local_tempdir()
  plan <- suppressMessages(ni_ants_registration(
    fixed_image = "F.nii.gz", moving_image = "M.nii.gz",
    metric = list("MI"), metric_weight = list(1), transforms = list("Rigid"),
    shrink_factors = list("8x4x2x1"), smoothing_sigmas = list("3x2x1x0"),
    dry_run = TRUE, echo = FALSE, .engine = "native", .cwd = wd
  ))
  a <- plan$execution$args
  expect_equal(a[which(a == "--transform") + 1], "Rigid[0.1]")
  # [0, 1] is antsRegistration's no-op default, so no clip flag is emitted.
  expect_false("--winsorize-image-intensities" %in% a)
  # save_state is optional; it must not be auto-filled and emitted.
  expect_false("--save-state" %in% a)
  expect_null(plan$outputs$save_state)
})

test_that("winsorize quantiles are numeric and rendered only when clipping (#27)", {
  args <- list(
    "ants.registration", fixed_image = "f.nii.gz", moving_image = "m.nii.gz",
    transforms = "Rigid", metric = "MI", metric_weight = 1,
    shrink_factors = "4x2x1", smoothing_sigmas = "2x1x0vox"
  )
  a <- ni_cmd(do.call(ni_call, c(args, list(
    winsorize_lower_quantile = 0.005, winsorize_upper_quantile = 0.995
  ))))$args
  wi <- which(a == "--winsorize-image-intensities")
  expect_length(wi, 1)
  expect_equal(a[wi + 1], "[0.005,0.995]")

  expect_error(
    do.call(ni_call, c(args, list(winsorize_lower_quantile = "0.005"))),
    "winsorize_lower_quantile.*single number"
  )
  expect_error(
    do.call(ni_call, c(args, list(winsorize_upper_quantile = 1.5))),
    "winsorize_upper_quantile.*<= 1"
  )
  expect_error(
    ni_cmd(do.call(ni_call, c(args, list(
      winsorize_lower_quantile = 0.9, winsorize_upper_quantile = 0.1
    )))),
    "lower < upper"
  )
})

test_that("bracketed transforms are passed through, not re-parameterised (#27)", {
  call <- ni_call("ants.registration",
    fixed_image = "f.nii.gz", moving_image = "m.nii.gz",
    transforms = c("Rigid[0.1]", "Affine[0.1]", "SyN[0.1,3,0]"),
    metric = c("MI", "MI", "CC"), metric_weight = 1,
    shrink_factors = "4x2x1", smoothing_sigmas = "2x1x0vox"
  )
  a <- ni_cmd(call)$args
  expect_equal(a[which(a == "--transform") + 1],
    c("Rigid[0.1]", "Affine[0.1]", "SyN[0.1,3,0]"))
})

test_that("transform_parameters set per-stage transform parameters (#27)", {
  args <- list(
    "ants.registration", fixed_image = "f.nii.gz", moving_image = "m.nii.gz",
    metric = c("MI", "MI", "CC"), metric_weight = 1,
    shrink_factors = "4x2x1", smoothing_sigmas = "2x1x0vox"
  )
  a <- ni_cmd(do.call(ni_call, c(args, list(
    transforms = c("Rigid", "Affine", "SyN"),
    transform_parameters = c("0.05", "0.08", "0.2,3,0")
  ))))$args
  expect_equal(a[which(a == "--transform") + 1],
    c("Rigid[0.05]", "Affine[0.08]", "SyN[0.2,3,0]"))

  # Parameters given twice for one stage are ambiguous.
  expect_error(
    ni_cmd(do.call(ni_call, c(args, list(
      transforms = c("Rigid", "Affine", "SyN[0.1,3,0]"),
      transform_parameters = c("0.1", "0.1", "0.2,3,0")
    )))),
    "already carries its parameters"
  )
})

# ---- #28: per-stage convergence, metric, and sampling inputs -------------

test_that("a three-stage rigid + affine + SyN registration renders exactly (#28)", {
  call <- ni_call("ants.registration",
    fixed_image = "F.nii.gz", moving_image = "M.nii.gz",
    transforms = c("Rigid", "Affine", "SyN"),
    transform_parameters = c("0.05", "0.08", "0.1,3,0"),
    metric = c("Mattes", "Mattes", "CC"),
    metric_weight = 1,
    radius_or_number_of_bins = c(56, 56, 4),
    sampling_strategy = c("Regular", "Regular", "None"),
    sampling_percentage = c(0.25, 0.25, 1),
    number_of_iterations = c("100x100", "100x100", "100x70x50x20"),
    convergence_threshold = 1e-6,
    convergence_window_size = c(20, 20, 10),
    shrink_factors = c("2x1", "2x1", "8x4x2x1"),
    smoothing_sigmas = c("1x0vox", "1x0vox", "3x2x1x0vox"),
    use_histogram_matching = TRUE,
    winsorize_lower_quantile = 0.005,
    winsorize_upper_quantile = 0.995,
    output_transform_prefix = "out_",
    output_warped_image = "out_Warped.nii.gz",
    output_inverse_warped_image = "out_InverseWarped.nii.gz",
    write_composite_transform = TRUE,
    float = TRUE
  )
  cmd <- ni_cmd(call)
  expect_equal(cmd$command, "antsRegistration")
  expect_equal(cmd$args, c(
    "--dimensionality", "3",
    "--output", "[out_,out_Warped.nii.gz,out_InverseWarped.nii.gz]",
    "--interpolation", "Linear",
    "--winsorize-image-intensities", "[0.005,0.995]",
    "--collapse-output-transforms", "1",
    "--use-histogram-matching", "1",
    "--transform", "Rigid[0.05]",
    "--metric", "Mattes[F.nii.gz,M.nii.gz,1,56,Regular,0.25]",
    "--convergence", "[100x100,0.000001,20]",
    "--shrink-factors", "2x1",
    "--smoothing-sigmas", "1x0vox",
    "--transform", "Affine[0.08]",
    "--metric", "Mattes[F.nii.gz,M.nii.gz,1,56,Regular,0.25]",
    "--convergence", "[100x100,0.000001,20]",
    "--shrink-factors", "2x1",
    "--smoothing-sigmas", "1x0vox",
    "--transform", "SyN[0.1,3,0]",
    "--metric", "CC[F.nii.gz,M.nii.gz,1,4,None,1]",
    "--convergence", "[100x70x50x20,0.000001,10]",
    "--shrink-factors", "8x4x2x1",
    "--smoothing-sigmas", "3x2x1x0vox",
    "--write-composite-transform", "1",
    "--float", "1"
  ))

  expect_equal(call$outputs$warped_image, "out_Warped.nii.gz")
  expect_equal(call$outputs$inverse_warped_image, "out_InverseWarped.nii.gz")
  expect_equal(call$outputs$composite_transform, "out_Composite.h5")
  expect_equal(call$outputs$inverse_composite_transform, "out_InverseComposite.h5")
})

test_that("composite outputs carry transform metadata for ni_read_transform()", {
  spec <- ni_spec_read("ants.registration", cache = FALSE)
  fwd <- spec$outputs$composite_transform$transform
  inv <- spec$outputs$inverse_composite_transform$transform
  expect_equal(unlist(fwd), c(kind = "composite", format = "ants_h5",
    source = "moving_image", target = "fixed_image"))
  expect_equal(inv$source, "fixed_image")
  expect_equal(inv$target, "moving_image")

  call <- ni_call("ants.registration",
    fixed_image = "f.nii.gz", moving_image = "m.nii.gz", transforms = "Rigid",
    metric = "MI", metric_weight = 1, shrink_factors = "1", smoothing_sigmas = "0vox"
  )
  expect_null(call$outputs$composite_transform)
})

test_that("args is appended once after every stage, not per stage (#28)", {
  call <- ni_call("ants.registration",
    fixed_image = "f.nii.gz", moving_image = "m.nii.gz",
    transforms = c("Rigid", "SyN"), metric = c("MI", "CC"), metric_weight = 1,
    shrink_factors = "4x2x1", smoothing_sigmas = "2x1x0vox",
    args = "--minimum-convergence-window 5"
  )
  a <- ni_cmd(call)$args
  expect_equal(sum(a == "--minimum-convergence-window"), 1L)
  expect_equal(utils::tail(a, 2), c("--minimum-convergence-window", "5"))
  expect_lt(max(which(a == "--smoothing-sigmas")), which(a == "--minimum-convergence-window"))
})

test_that("per-stage inputs must have one value or one per stage (#28)", {
  call <- ni_call("ants.registration",
    fixed_image = "f.nii.gz", moving_image = "m.nii.gz",
    transforms = c("Rigid", "Affine", "SyN"), metric = c("MI", "CC"), metric_weight = 1,
    shrink_factors = "4x2x1", smoothing_sigmas = "2x1x0vox",
    .validate = FALSE
  )
  expect_error(ni_cmd(call), "metric.*2 values.*3 stages")
})

test_that("per-stage iteration ladders must match shrink factor levels (#28)", {
  call <- ni_call("ants.registration",
    fixed_image = "f.nii.gz", moving_image = "m.nii.gz",
    transforms = "Rigid", metric = "MI", metric_weight = 1,
    shrink_factors = "8x4x2x1", smoothing_sigmas = "3x2x1x0vox",
    number_of_iterations = "1000x500"
  )
  expect_error(ni_cmd(call), "number_of_iterations.*2 levels")
})

test_that("metric sampling inputs are validated (#28)", {
  args <- list(
    "ants.registration", fixed_image = "f.nii.gz", moving_image = "m.nii.gz",
    transforms = "Rigid", metric = "MI", metric_weight = 1,
    shrink_factors = "1", smoothing_sigmas = "0vox"
  )
  expect_error(
    do.call(ni_call, c(args, list(sampling_strategy = "Dense"))),
    "sampling_strategy.*Dense"
  )
  expect_error(
    do.call(ni_call, c(args, list(sampling_percentage = 0.25))),
    "sampling_percentage"
  )
  # The renderer re-checks, so unvalidated calls cannot emit a bad token either.
  expect_error(
    ni_cmd(do.call(ni_call, c(args, list(sampling_strategy = "Dense", .validate = FALSE)))),
    "None, Regular, or Random"
  )
  expect_error(
    ni_cmd(do.call(ni_call, c(args, list(
      sampling_strategy = "Regular", sampling_percentage = 1.5, .validate = FALSE
    )))),
    "\\(0, 1\\]"
  )
})

test_that("histogram matching is one global flag, as antsRegistration applies it (#28)", {
  args <- list(
    "ants.registration", fixed_image = "f.nii.gz", moving_image = "m.nii.gz",
    transforms = c("Rigid", "SyN"), metric = c("MI", "CC"), metric_weight = 1,
    shrink_factors = "4x2x1", smoothing_sigmas = "2x1x0vox"
  )
  for (flag in c(TRUE, FALSE)) {
    a <- ni_cmd(do.call(ni_call, c(args, list(use_histogram_matching = flag))))$args
    hi <- which(a == "--use-histogram-matching")
    expect_length(hi, 1)
    expect_equal(a[hi + 1], if (flag) "1" else "0")
    expect_lt(hi, min(which(a == "--transform")))
  }
  expect_false("--use-histogram-matching" %in% ni_cmd(do.call(ni_call, args))$args)
  expect_error(
    do.call(ni_call, c(args, list(use_histogram_matching = c(TRUE, FALSE)))),
    "use_histogram_matching.*single logical"
  )
})

test_that("staged registration rejects incomplete or missing stage values", {
  base <- list(
    "ants.registration", fixed_image = "f.nii.gz", moving_image = "m.nii.gz",
    metric_weight = 1, shrink_factors = "4x2x1", smoothing_sigmas = "2x1x0vox",
    .validate = FALSE
  )
  expect_error(
    ni_cmd(do.call(ni_call, c(base, list(transforms = character(0), metric = "MI")))),
    "at least one registration stage"
  )
  expect_error(
    ni_cmd(do.call(ni_call, c(base, list(transforms = c("Rigid", "SyN"), metric = c("MI", NA))))),
    "metric.*missing values"
  )
  expect_error(
    ni_cmd(do.call(ni_call, c(base, list(
      transforms = "Rigid", metric = "MI", output_inverse_warped_image = "iw.nii.gz"
    )))),
    "requires .*output_warped_image"
  )
  # Stage-count mismatches point at the one-element-per-stage form.
  expect_error(
    ni_cmd(do.call(ni_call, c(base, list(
      transforms = c("Rigid", "SyN"), metric = c("MI", "CC", "CC")
    )))),
    "3 values, but the call has 2 stages.*one element per stage"
  )
})

test_that("staged registration renders numbers ANTs parses literally", {
  call <- ni_call("ants.registration",
    fixed_image = "f.nii.gz", moving_image = "m.nii.gz", transforms = "Rigid",
    metric = "MI", metric_weight = 1, shrink_factors = "1", smoothing_sigmas = "0vox",
    convergence_window_size = 1e5, convergence_threshold = 1e-8,
    output_warped_image = "w.nii.gz", output_inverse_warped_image = ""
  )
  a <- ni_cmd(call)$args
  expect_equal(a[which(a == "--convergence") + 1], "[1000,0.00000001,100000]")
  # An empty inverse path is absent, not an empty bracket slot.
  expect_equal(a[which(a == "--output") + 1], "[transform,w.nii.gz]")
})

# ---- nested per-stage values and multi-metric stages ----------------------

test_that("nested per-stage values survive ni_call() instead of being flattened", {
  call <- ni_call("ants.registration",
    fixed_image = "f.nii.gz", moving_image = "m.nii.gz",
    transforms = c("Rigid", "SyN"),
    transform_parameters = list(0.1, c(0.1, 3, 0)),
    metric = list("Mattes", c("Mattes", "CC")),
    metric_weight = list(1, c(0.5, 0.5)),
    number_of_iterations = list(c(100, 100), c(100, 70, 50)),
    shrink_factors = list(c(2, 1), c(4, 2, 1)),
    smoothing_sigmas = list(c(1, 0), c(2, 1, 0)),
    sigma_units = "vox"
  )
  expect_identical(call$values$metric, list("Mattes", c("Mattes", "CC")))
  expect_identical(call$values$transform_parameters, list(0.1, c(0.1, 3, 0)))

  a <- ni_cmd(call)$args
  expect_equal(a[which(a == "--transform") + 1], c("Rigid[0.1]", "SyN[0.1,3,0]"))
  expect_equal(a[which(a == "--convergence") + 1], c("[100x100,1e-6,10]", "[100x70x50,1e-6,10]"))
  expect_equal(a[which(a == "--shrink-factors") + 1], c("2x1", "4x2x1"))
  expect_equal(a[which(a == "--smoothing-sigmas") + 1], c("1x0vox", "2x1x0vox"))
})

test_that("niworkflows' t1w-mni_registration_precise_001 preset renders exactly", {
  # nipreps/niworkflows niworkflows/data/t1w-mni_registration_precise_001.json:
  # the SyN stage combines Mattes and CC at 0.5/0.5 with no metric sampling.
  call <- ni_call("ants.registration",
    fixed_image = "F.nii.gz", moving_image = "M.nii.gz",
    transforms = c("Rigid", "Affine", "SyN"),
    transform_parameters = list(0.05, 0.1, c(0.2, 3, 0)),
    metric = list("Mattes", "Mattes", c("Mattes", "CC")),
    metric_weight = list(1, 1, c(0.5, 0.5)),
    radius_or_number_of_bins = list(56, 56, c(56, 4)),
    sampling_strategy = list("Regular", "Regular", c(NA, NA)),
    sampling_percentage = list(0.3, 0.3, c(NA, NA)),
    number_of_iterations = list(c(100, 100), c(100, 100), c(100, 30, 20)),
    convergence_threshold = c(1e-8, 1e-8, -0.01),
    convergence_window_size = c(20, 20, 5),
    smoothing_sigmas = list(c(2, 1), c(2, 1), c(1, 0.5, 0)),
    sigma_units = "vox",
    shrink_factors = list(c(2, 1), c(2, 1), c(4, 2, 1)),
    winsorize_lower_quantile = 0.005,
    winsorize_upper_quantile = 0.995,
    # The preset lists [false, false, true]; ANTs applies the last value to
    # every stage, so the effective setting is TRUE.
    use_histogram_matching = TRUE,
    collapse_output_transforms = TRUE,
    write_composite_transform = FALSE,
    interpolation = "LanczosWindowedSinc",
    output_transform_prefix = "ants_t1_to_mni",
    output_warped_image = "ants_t1_to_mni_Warped.nii.gz"
  )
  expect_equal(ni_cmd(call)$args, c(
    "--dimensionality", "3",
    "--output", "[ants_t1_to_mni,ants_t1_to_mni_Warped.nii.gz]",
    "--interpolation", "LanczosWindowedSinc",
    "--winsorize-image-intensities", "[0.005,0.995]",
    "--collapse-output-transforms", "1",
    "--use-histogram-matching", "1",
    "--transform", "Rigid[0.05]",
    "--metric", "Mattes[F.nii.gz,M.nii.gz,1,56,Regular,0.3]",
    "--convergence", "[100x100,0.00000001,20]",
    "--shrink-factors", "2x1",
    "--smoothing-sigmas", "2x1vox",
    "--transform", "Affine[0.1]",
    "--metric", "Mattes[F.nii.gz,M.nii.gz,1,56,Regular,0.3]",
    "--convergence", "[100x100,0.00000001,20]",
    "--shrink-factors", "2x1",
    "--smoothing-sigmas", "2x1vox",
    "--transform", "SyN[0.2,3,0]",
    "--metric", "Mattes[F.nii.gz,M.nii.gz,0.5,56]",
    "--metric", "CC[F.nii.gz,M.nii.gz,0.5,4]",
    "--convergence", "[100x30x20,-0.01,5]",
    "--shrink-factors", "4x2x1",
    "--smoothing-sigmas", "1x0.5x0vox",
    "--write-composite-transform", "0"
  ))
})

test_that("images pair with the metrics within a stage, as in nipype", {
  # antsBrainExtraction-style: the SyN stage matches the images and their
  # Laplacians with one CC metric each.
  call <- ni_call("ants.registration",
    fixed_image = c("T.nii.gz", "T_lap.nii.gz"),
    moving_image = c("A.nii.gz", "A_lap.nii.gz"),
    transforms = c("Rigid", "SyN"),
    metric = list("MI", c("CC", "CC")),
    metric_weight = list(1, c(0.5, 0.5)),
    radius_or_number_of_bins = list(32, 4),
    sampling_strategy = list("Regular", "None"),
    sampling_percentage = list(0.25, 1),
    shrink_factors = "2x1", smoothing_sigmas = "1x0vox"
  )
  a <- ni_cmd(call)$args
  expect_equal(a[which(a == "--metric") + 1], c(
    "MI[T.nii.gz,A.nii.gz,1,32,Regular,0.25]",
    "CC[T.nii.gz,A.nii.gz,0.5,4,None,1]",
    "CC[T_lap.nii.gz,A_lap.nii.gz,0.5,4,None,1]"
  ))
})

test_that("multi-metric stages reject mismatched per-metric settings", {
  base <- list(
    "ants.registration", moving_image = "m.nii.gz",
    transforms = c("Rigid", "SyN"), shrink_factors = "2x1", smoothing_sigmas = "1x0vox"
  )
  expect_error(
    ni_cmd(do.call(ni_call, c(base, list(
      fixed_image = "f.nii.gz",
      metric = list("MI", c("Mattes", "CC")), metric_weight = list(1, c(0.2, 0.3, 0.5))
    )))),
    "Stage 2.*metric_weight.*3 values for 2 metrics"
  )
  # One image per stage is not a thing antsRegistration has.
  expect_error(
    ni_cmd(do.call(ni_call, c(base, list(
      metric = c("MI", "CC"), fixed_image = c("f1.nii.gz", "f2.nii.gz")
    )))),
    "pair with the metrics"
  )
  expect_error(
    do.call(ni_call, c(base, list(fixed_image = "f.nii.gz", metric = "MI", sigma_units = "px"))),
    "sigma_units"
  )
  expect_error(
    ni_cmd(do.call(ni_call, c(base, list(fixed_image = "f.nii.gz", metric = "MI", sigma_units = "mm")))),
    "already says"
  )
})

test_that("a preset loaded from JSON renders the same with either jsonlite reader", {
  # fromJSON() turns equal-length ladders into a matrix and null into NA;
  # read_json(simplifyVector = FALSE) keeps lists and gives NULL for null.
  preset <- '{
    "transforms": ["Affine", "SyN"],
    "transform_parameters": [[0.1], [0.1, 3.0, 0.0]],
    "metric": ["Mattes", ["Mattes", "CC"]],
    "metric_weight": [1, [0.5, 0.5]],
    "radius_or_number_of_bins": [56, [56, 4]],
    "sampling_strategy": ["Regular", [null, null]],
    "sampling_percentage": [0.25, [null, null]],
    "number_of_iterations": [[100, 50], [100, 50]],
    "shrink_factors": [[2, 1], [2, 1]],
    "smoothing_sigmas": [[1, 0], [1, 0]],
    "sigma_units": ["vox", "vox"]
  }'
  render <- function(values) {
    ni_cmd(do.call(ni_call, c(
      list("ants.registration", fixed_image = "F.nii.gz", moving_image = "M.nii.gz"),
      values
    )))$args
  }
  simplified <- jsonlite::fromJSON(preset)
  expect_true(is.matrix(simplified$number_of_iterations))
  a <- render(simplified)
  expect_identical(render(jsonlite::parse_json(preset, simplifyVector = FALSE)), a)

  expect_equal(a[which(a == "--metric") + 1], c(
    "Mattes[F.nii.gz,M.nii.gz,1,56,Regular,0.25]",
    "Mattes[F.nii.gz,M.nii.gz,0.5,56]",
    "CC[F.nii.gz,M.nii.gz,0.5,4]"
  ))
  expect_equal(a[which(a == "--transform") + 1], c("Affine[0.1]", "SyN[0.1,3,0]"))
  expect_equal(a[which(a == "--convergence") + 1], rep("[100x50,1e-6,10]", 2))
  expect_equal(a[which(a == "--smoothing-sigmas") + 1], rep("1x0vox", 2))
})

test_that("multi-metric stages must agree on sampling, as ANTs samples per stage", {
  base <- list(
    "ants.registration", fixed_image = "f.nii.gz", moving_image = "m.nii.gz",
    transforms = "SyN", metric = list(c("Mattes", "CC")), radius_or_number_of_bins = list(c(32, 4)),
    shrink_factors = "2x1", smoothing_sigmas = "1x0vox"
  )
  expect_error(
    ni_cmd(do.call(ni_call, c(base, list(sampling_strategy = list(c("Regular", "None")))))),
    "sampling settings differ"
  )
  expect_error(
    ni_cmd(do.call(ni_call, c(base, list(
      sampling_strategy = "Regular", sampling_percentage = list(c(0.25, 0.5))
    )))),
    "sampling settings differ"
  )
  # A shared setting is fine and applies to both metrics.
  a <- ni_cmd(do.call(ni_call, c(base, list(
    sampling_strategy = "Regular", sampling_percentage = 0.25
  ))))$args
  expect_equal(a[which(a == "--metric") + 1], c(
    "Mattes[f.nii.gz,m.nii.gz,1,32,Regular,0.25]",
    "CC[f.nii.gz,m.nii.gz,1,4,Regular,0.25]"
  ))
  expect_error(
    do.call(ni_call, c(base, list(sampling_strategy = list(c("Regular", "bogus"))))),
    "sampling_strategy.*bogus"
  )
})

test_that("one bins value is not shared between different metric types", {
  base <- list(
    "ants.registration", fixed_image = "f.nii.gz", moving_image = "m.nii.gz",
    transforms = "SyN", shrink_factors = "2x1", smoothing_sigmas = "1x0vox"
  )
  # 32 bins for Mattes would be a 65-voxel-wide CC window.
  expect_error(
    ni_cmd(do.call(ni_call, c(base, list(
      metric = list(c("Mattes", "CC")), radius_or_number_of_bins = 32
    )))),
    "cannot serve metrics"
  )
  a <- ni_cmd(do.call(ni_call, c(base, list(
    metric = list(c("CC", "CC")), radius_or_number_of_bins = 2
  ))))$args
  expect_equal(a[which(a == "--metric") + 1], rep("CC[f.nii.gz,m.nii.gz,1,2]", 2))
  expect_error(
    ni_cmd(do.call(ni_call, c(base, list(metric = character(0))))),
    "at least one metric"
  )
})

test_that("lint keeps nested lists to non-path inputs of custom-rendered specs", {
  lint <- function(spec) niflowr:::lint_single_spec(spec, "x.json")$findings
  codes <- function(f) vapply(f, function(x) x$code, character(1))
  generic <- list(id = "x", inputs = list(a = list(type = "list", nested = TRUE, cli = list(argstr = "%s"))))
  expect_true("invalid_nested_list" %in% codes(lint(generic)))
  paths <- list(id = "x", render = "r", inputs = list(a = list(type = "list", nested = TRUE, items_type = "file")))
  expect_true("invalid_nested_list" %in% codes(lint(paths)))
  # A nested input that mentions images is not mistaken for a path list.
  ok <- list(id = "x", render = "r", inputs = list(a = list(
    type = "list", nested = TRUE, desc = "the metric for each image pair"
  )))
  expect_false(any(c("invalid_nested_list", "path_list_items_type") %in% codes(lint(ok))))
})

test_that("ants.registration fixes live in the Nipype spec override (#27, #28)", {
  override <- testthat::test_path("..", "..", "tools", "spec_overrides", "ants.registration.json")
  skip_if_not(file.exists(override), "spec overrides ship only in the source tree")
  ov <- jsonlite::read_json(override)
  spec <- ni_spec_read("ants.registration", cache = FALSE)

  added <- c(
    "transform_parameters", "number_of_iterations", "convergence_threshold",
    "convergence_window_size", "radius_or_number_of_bins", "sampling_strategy",
    "sampling_percentage", "use_histogram_matching", "output_warped_image",
    "output_inverse_warped_image"
  )
  expect_true(all(added %in% names(ov$inputs)))
  expect_true(all(added %in% names(spec$inputs)))
  for (nm in c("winsorize_lower_quantile", "winsorize_upper_quantile")) {
    expect_identical(ov$inputs[[nm]]$type, "double")
    expect_identical(spec$inputs[[nm]]$type, "double")
  }
  expect_setequal(names(ov$outputs), names(spec$outputs))
  nested <- c(
    "metric", "metric_weight", "radius_or_number_of_bins", "sampling_strategy",
    "sampling_percentage", "number_of_iterations", "shrink_factors",
    "smoothing_sigmas", "transform_parameters"
  )
  for (nm in nested) {
    expect_true(isTRUE(ov$inputs[[nm]]$nested), info = nm)
    expect_true(isTRUE(spec$inputs[[nm]]$nested), info = nm)
  }
})
