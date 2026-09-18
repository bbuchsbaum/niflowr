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
  # Flattened nested stage values get a hint about the string form.
  expect_error(
    ni_cmd(do.call(ni_call, c(base, list(
      transforms = c("Rigid", "SyN"), metric = c("MI", "CC"),
      transform_parameters = list(0.1, c(0.1, 3, 0))
    )))),
    "one string"
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
})
