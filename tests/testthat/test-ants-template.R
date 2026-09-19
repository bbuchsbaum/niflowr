# Tests for the pinned T1w-to-template presets, the antsApplyTransforms and
# MeasureImageSimilarity renderers, and registration QA (#29).

test_that("both presets load and only set ants.registration inputs", {
  inputs <- names(ni_spec_read("ants.registration", cache = FALSE)$inputs)
  for (name in c("precise", "testing")) {
    preset <- ni_ants_template_preset(name)
    expect_equal(preset$name, paste0("t1w-template_", name))
    for (field in c("title", "intended_for", "provenance", "cost")) {
      expect_true(nzchar(preset[[field]]), info = paste(name, field))
    }
    expect_true(all(names(preset$values) %in% inputs), info = name)
  }
  expect_error(ni_ants_template_preset("fast"), "should be one of")
})

precise_plan <- function(..., envir = parent.frame()) {
  wd <- withr::local_tempdir(.local_envir = envir)
  suppressMessages(ni_ants_register_to_template(
    fixed_image = "fixed.nii.gz", moving_image = "moving.nii.gz",
    output_prefix = "prefix", ..., dry_run = TRUE, echo = FALSE, .engine = "native",
    .cwd = wd
  ))
}

test_that("the precise preset is the schedule measured against fMRIPrep in #29", {
  # The command from the issue, with fixed/moving/prefix as literal names.
  issue <- paste(
    "--dimensionality 3 --float 1 --collapse-output-transforms 1",
    "--output [prefix,prefixWarped.nii.gz] --interpolation LanczosWindowedSinc",
    "--use-histogram-matching 1 --winsorize-image-intensities [0.005,0.995]",
    "--initial-moving-transform [fixed,moving,1]",
    "--transform Rigid[0.1] --metric Mattes[fixed,moving,1,56,Regular,0.25]",
    "--convergence [1000x500x250x100,1e-6,10] --shrink-factors 8x4x2x1 --smoothing-sigmas 3x2x1x0vox",
    "--transform Affine[0.1] --metric Mattes[fixed,moving,1,56,Regular,0.25]",
    "--convergence [1000x500x250x100,1e-6,10] --shrink-factors 8x4x2x1 --smoothing-sigmas 3x2x1x0vox",
    "--transform SyN[0.1,3,0] --metric CC[fixed,moving,1,4]",
    "--convergence [100x100x70x50x20,1e-6,10] --shrink-factors 10x6x4x2x1 --smoothing-sigmas 5x3x2x1x0vox",
    "--write-composite-transform 1"
  )
  issue <- strsplit(issue, " ", fixed = TRUE)[[1]]

  wd <- withr::local_tempdir()
  plan <- suppressMessages(ni_ants_register_to_template(
    fixed_image = "fixed", moving_image = "moving", output_prefix = "prefix",
    dry_run = TRUE, echo = FALSE, .engine = "native", .cwd = wd
  ))
  ours <- plan$execution$args
  ours <- gsub(paste0(normalizePath(wd), "/"), "", ours, fixed = TRUE)
  ours <- gsub(paste0(wd, "/"), "", ours, fixed = TRUE)
  # The same threshold, written without scientific notation.
  ours <- gsub("0.000001", "1e-6", ours, fixed = TRUE)

  # Stage groups must match in order; global options only as a set.
  stages <- function(a) a[min(which(a == "--transform")):length(a)]
  globals <- function(a) {
    g <- a[seq_len(min(which(a == "--transform")) - 1L)]
    tail <- stages(a)
    trailing <- which(tail == "--write-composite-transform" | tail == "--float")
    for (i in trailing) g <- c(g, tail[i], tail[i + 1L])
    sort(paste(g[c(TRUE, FALSE)], g[c(FALSE, TRUE)]))
  }
  strip <- function(a) {
    s <- stages(a)
    drop <- which(s %in% c("--write-composite-transform", "--float"))
    if (length(drop)) s <- s[-c(drop, drop + 1L)]
    s
  }
  expect_equal(strip(ours), strip(issue))
  expect_equal(globals(ours), globals(issue))
})

test_that("preset overrides replace whole values, and NULL drops one", {
  plan <- precise_plan(
    metric = list("MI", "MI", "CC"), radius_or_number_of_bins = list(32, 32, 4),
    random_seed = 7, sampling_strategy = NULL, sampling_percentage = NULL
  )
  a <- plan$execution$args
  expect_true(all(grepl("^(MI|CC)\\[", a[which(a == "--metric") + 1])))
  expect_false(any(grepl("Regular", a, fixed = TRUE)))
  expect_equal(a[which(a == "--random-seed") + 1], "7")
  expect_true("--write-composite-transform" %in% a)
  expect_equal(basename(plan$outputs$composite_transform), "prefixComposite.h5")
  expect_equal(basename(plan$outputs$warped_image), "prefixWarped.nii.gz")

  expect_error(
    ni_ants_register_to_template("f.nii.gz", "m.nii.gz", "p_", "testing", 7, dry_run = TRUE),
    "must be named"
  )
  expect_error(
    ni_ants_register_to_template("f.nii.gz", "m.nii.gz", "p_", output_warped_image = "w.nii.gz",
      dry_run = TRUE),
    "output_warped_image.*output_prefix"
  )
})

test_that("an explicit initial transform replaces the preset's centre-of-mass start", {
  a <- precise_plan(initial_moving_transform = "init.mat")$execution$args
  imt <- a[which(a == "--initial-moving-transform") + 1]
  expect_length(imt, 1)
  expect_match(imt, "init.mat$")
})

test_that("the testing preset keeps the precise stage structure", {
  a <- precise_plan()$execution$args
  wd <- withr::local_tempdir()
  t <- suppressMessages(ni_ants_register_to_template(
    "fixed.nii.gz", "moving.nii.gz", "prefix", preset = "testing",
    dry_run = TRUE, echo = FALSE, .engine = "native", .cwd = wd
  ))$execution$args
  expect_equal(t[which(t == "--transform") + 1], a[which(a == "--transform") + 1])
  expect_equal(sub("\\[.*", "", t[which(t == "--metric") + 1]), c("Mattes", "Mattes", "CC"))
  expect_true("--write-composite-transform" %in% t)
})

# ---- antsApplyTransforms and MeasureImageSimilarity --------------------------

test_that("antsApplyTransforms renders each transform, inversions, and composite fields", {
  cmd <- ni_cmd(ni_call("ants.apply_transforms",
    dimension = 3, input_image = "in.nii.gz", reference_image = "ref.nii.gz",
    transforms = c("warp.nii.gz", "affine.mat"), invert_transform_flags = c(FALSE, TRUE),
    interpolation = "NearestNeighbor", output_image = "out.nii.gz"
  ))
  expect_equal(cmd$command, "antsApplyTransforms")
  expect_equal(cmd$args, c(
    "--dimensionality", "3", "--input", "in.nii.gz", "--reference-image", "ref.nii.gz",
    "--output", "out.nii.gz", "--interpolation", "NearestNeighbor", "--default-value", "0",
    "--transform", "warp.nii.gz", "--transform", "[affine.mat,1]"
  ))

  field <- ni_cmd(ni_call("ants.apply_transforms",
    reference_image = "ref.nii.gz", transforms = "Composite.h5",
    print_out_composite_warp_file = TRUE, output_image = "field.nii.gz"
  ))$args
  expect_equal(field[which(field == "--output") + 1], "[field.nii.gz,1]")
  expect_false("--input" %in% field)

  expect_error(
    ni_cmd(ni_call("ants.apply_transforms", reference_image = "r.nii.gz",
      transforms = "t.h5", output_image = "o.nii.gz")),
    "input_image.*required"
  )
  expect_error(
    ni_cmd(ni_call("ants.apply_transforms", input_image = "i.nii.gz",
      reference_image = "r.nii.gz", transforms = c("a.h5", "b.mat"),
      invert_transform_flags = TRUE, output_image = "o.nii.gz")),
    "1 value for 2 transforms"
  )
})

test_that("MeasureImageSimilarity renders a full metric token and masks", {
  similarity <- function(..., .validate = FALSE) {
    ni_cmd(ni_call("ants.measure_image_similarity", fixed_image = "f.nii.gz",
      moving_image = "m.nii.gz", ..., .validate = .validate))$args
  }
  a <- similarity(metric = "MI", radius_or_number_of_bins = 32L, fixed_image_mask = "fm.nii.gz")
  expect_equal(a, c("--dimensionality", "3", "--metric", "MI[f.nii.gz,m.nii.gz,1,32]",
    "--masks", "fm.nii.gz"))

  a <- similarity(metric = "CC", radius_or_number_of_bins = 4L, sampling_strategy = "Regular",
    sampling_percentage = 0.5, fixed_image_mask = "fm.nii.gz", moving_image_mask = "mm.nii.gz")
  expect_equal(a[which(a == "--metric") + 1], "CC[f.nii.gz,m.nii.gz,1,4,Regular,0.5]")
  expect_equal(a[which(a == "--masks") + 1], "[fm.nii.gz,mm.nii.gz]")

  expect_error(similarity(metric = "MI", radius_or_number_of_bins = 32L,
    moving_image_mask = "mm.nii.gz"), "requires .*fixed_image_mask")
  expect_error(similarity(metric = "MI", radius_or_number_of_bins = 32L,
    sampling_strategy = "Regular", sampling_percentage = 0), "\\(0, 1\\]")
  expect_error(similarity(metric = "MI", radius_or_number_of_bins = 32L,
    sampling_percentage = 0.5, .validate = TRUE), "sampling_percentage")
  # A mask ANTs cannot read is silently ignored, so it must exist up front.
  expect_error(similarity(metric = "MI", radius_or_number_of_bins = 32L,
    fixed_image_mask = "no-such-mask.nii.gz", .validate = TRUE), "does not exist")
})

test_that("antsApplyTransforms needs an explicit output path", {
  expect_error(
    ni_call("ants.apply_transforms", input_image = "i.nii.gz",
      reference_image = "r.nii.gz", transforms = "t.h5"),
    "output_image.*missing"
  )
})

# ---- registration QA ---------------------------------------------------------

test_that("QA summaries compute Dice, label Dice, and Jacobian statistics", {
  expect_equal(ni_parse_similarity("-0.508135\n", "MI"), -0.508135)
  expect_error(ni_parse_similarity("Exception thrown", "MI"), "Could not read the MI value")

  a <- array(FALSE, c(4, 4, 4)); a[1:2, , ] <- TRUE
  b <- array(FALSE, c(4, 4, 4)); b[2:3, , ] <- TRUE
  expect_equal(ni_dice(a, b), 0.5)
  expect_true(is.na(ni_dice(array(FALSE, c(2, 2, 2)), array(FALSE, c(2, 2, 2)))))
  expect_error(ni_dice(a, array(FALSE, c(2, 2, 2))), "different grids")
  shifted <- b
  attr(shifted, "xform") <- diag(4)
  attr(a, "xform") <- diag(c(2, 2, 2, 1))
  expect_error(ni_dice(a, shifted), "different grids")

  fixed <- array(c(0, 1, 1, 2), c(2, 2, 1))
  moving <- array(c(0, 1, 2, 2), c(2, 2, 1))
  ld <- ni_label_dice(fixed, moving)
  expect_equal(ld$label, c(1, 2))
  expect_equal(ld$dice, c(2 / 3, 2 / 3))

  jac <- array(c(1, 0.5, -0.1, NaN, 2, 1, 1, 1), c(2, 2, 2))
  whole <- ni_jacobian_summary(jac)
  expect_equal(whole$min, -0.1)
  expect_equal(whole$n_nonpositive, 1)
  expect_equal(whole$n_nonfinite, 1)
  inside <- ni_jacobian_summary(jac, jac > 0.9 & is.finite(jac))
  expect_equal(inside$region, "fixed mask")
  expect_equal(inside$n_nonpositive, 0)
})

tidy <- function(x) as.character(fs::path_abs(x))

qa_fixture <- function(dir) {
  img <- function(name, value) {
    path <- file.path(dir, name)
    RNifti::writeNifti(array(value, c(3, 3, 3)), path)
    path
  }
  composite <- file.path(dir, "sub_Composite.h5")
  file.create(composite)
  list(
    fixed = img("fixed.nii.gz", 1), moving = img("moving.nii.gz", 1),
    fixed_mask = img("fixed_mask.nii.gz", 1), moving_mask = img("moving_mask.nii.gz", 1),
    composite = composite
  )
}

# Mock ni_run(): record calls, answer similarity on stdout, and write outputs
# with the fresh-output rule ni_run() enforces.
mock_ants <- function(env = parent.frame()) {
  calls <- new.env()
  calls$list <- list()
  testthat::local_mocked_bindings(ni_run = function(call, ...) {
    v <- call$values
    calls$list[[length(calls$list) + 1L]] <- list(
      spec = call$spec$id, values = v, runtime = call$runtime
    )
    if (identical(call$spec$id, "ants.measure_image_similarity")) {
      return(list(runtime = list(stdout = if (v$metric == "MI") "-0.5\n" else "-0.6\n")))
    }
    out <- v$output_image %||% v$outputImage
    if (file.exists(out)) stop("Unchanged pre-existing output: ", out)
    value <- if (identical(call$spec$id, "ants.create_jacobian_determinant_image")) 1.2 else 1
    RNifti::writeNifti(array(value, c(3, 3, 3)), out)
    list(runtime = list(stdout = ""))
  }, .env = env)
  calls
}

test_that("QA wires the registration's images, transform, engine, and profile through ANTs", {
  skip_if_not_installed("RNifti")
  f <- qa_fixture(withr::local_tempdir())
  registration <- structure(list(
    call = list(values = list(fixed_image = c(f$fixed, "fixed_lap.nii.gz"), moving_image = f$moving)),
    outputs = list(composite_transform = f$composite),
    runtime = list(engine = "native", profile = "ants-custom")
  ), class = "ni_result")
  calls <- mock_ants()

  qa <- ni_ants_registration_qa(registration, fixed_mask = f$fixed_mask, moving_mask = f$moving_mask)
  recorded <- calls$list
  specs <- vapply(recorded, `[[`, "", "spec")
  expect_equal(specs, c(
    "ants.apply_transforms", "ants.measure_image_similarity", "ants.measure_image_similarity",
    "ants.apply_transforms", "ants.apply_transforms", "ants.create_jacobian_determinant_image"
  ))
  expect_true(all(vapply(recorded, function(x) identical(x$runtime$engine, "native"), logical(1))))
  expect_true(all(vapply(recorded, function(x) identical(x$runtime$profile, "ants-custom"), logical(1))))

  warp <- recorded[[1]]$values
  expect_equal(warp$input_image, tidy(f$moving))
  expect_equal(warp$reference_image, tidy(f$fixed))
  expect_equal(warp$transforms, tidy(f$composite))
  expect_equal(warp$interpolation, "Linear")
  expect_equal(basename(warp$output_image), "warped.nii.gz")
  expect_match(basename(dirname(warp$output_image)), "^sub_qa-")

  expect_equal(recorded[[2]]$values$moving_image, warp$output_image)
  expect_equal(recorded[[2]]$values$fixed_image_mask, tidy(f$fixed_mask))
  expect_equal(recorded[[4]]$values$interpolation, "NearestNeighbor")
  expect_true(isTRUE(recorded[[5]]$values$print_out_composite_warp_file))
  expect_false(file.exists(recorded[[5]]$values$output_image))

  expect_equal(qa$similarity$value, c(-0.5, -0.6))
  expect_equal(qa$mask_dice, 1)
  expect_equal(qa$jacobian$min, 1.2)
  expect_equal(qa$jacobian$n_nonpositive, 0)
  shown <- paste(testthat::capture_messages(print(qa)), collapse = "")
  expect_match(shown, "lower is better")
  expect_match(shown, "0 non-positive")
})

test_that("QA can be re-run, resolves relative paths, and takes transform chains", {
  skip_if_not_installed("RNifti")
  dir <- withr::local_tempdir()
  f <- qa_fixture(dir)
  affine <- file.path(dir, "sub_0GenericAffine.mat")
  file.create(affine)
  calls <- mock_ants()
  withr::local_dir(dir)

  first <- ni_ants_registration_qa(fixed_image = "fixed.nii.gz", moving_image = "moving.nii.gz",
    transform = c("sub_Composite.h5", "sub_0GenericAffine.mat"), fixed_mask = "fixed_mask.nii.gz",
    jacobian = FALSE, .engine = "native")
  second <- ni_ants_registration_qa(fixed_image = "fixed.nii.gz", moving_image = "moving.nii.gz",
    transform = c("sub_Composite.h5", "sub_0GenericAffine.mat"), fixed_mask = "fixed_mask.nii.gz",
    jacobian = FALSE, .engine = "native")
  expect_false(identical(first$files$qa_dir, second$files$qa_dir))

  warp <- calls$list[[1]]$values
  expect_equal(normalizePath(warp$transforms), normalizePath(c(f$composite, affine)))
  expect_true(fs::is_absolute_path(calls$list[[2]]$values$fixed_image_mask))

  expect_error(
    ni_ants_registration_qa(fixed_image = "fixed.nii.gz", moving_image = "moving.nii.gz",
      transform = "sub_Composite.h5", fixed_mask = "missing_mask.nii.gz", jacobian = FALSE),
    "fixed_mask.*does not exist"
  )
})

test_that("QA explains what it needs when the transform is missing", {
  expect_error(
    ni_ants_registration_qa(fixed_image = "f.nii.gz", moving_image = "m.nii.gz"),
    "write_composite_transform = TRUE"
  )
  expect_error(
    ni_ants_registration_qa(fixed_image = "f", moving_image = "m", transform = "t.h5",
      similarity = c(32, 4), jacobian = FALSE),
    "unique metric names"
  )
  expect_error(
    ni_ants_registration_qa(fixed_image = "f", moving_image = "m", transform = "t.h5",
      similarity = c(CC = 2, CC = 4), jacobian = FALSE),
    "unique metric names"
  )
})
