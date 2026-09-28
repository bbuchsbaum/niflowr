test_that("slicetimer declares trackable NIFTI_GZ and NIFTI outputs", {
  input <- tempfile(fileext = ".nii.gz")
  file.create(input)

  gz <- ni_call(
    "fsl.slice_timer", in_file = input, out_file = tempfile(fileext = ".nii.gz"),
    time_repetition = 2, slice_direction = 3,
    .env = c(FSLOUTPUTTYPE = "NIFTI_GZ")
  )
  expect_named(gz$outputs, "out_file")
  expect_match(gz$outputs$out_file, "[.]nii[.]gz$")
  expect_true(gz$spec$outputs$out_file$must_exist)
  expect_true(gz$spec$outputs$out_file$nonempty)

  nii <- ni_call(
    "fsl.slice_timer", in_file = input, out_file = tempfile(fileext = ".nii.gz"),
    time_repetition = 2, slice_direction = 3,
    .env = c(FSLOUTPUTTYPE = "NIFTI")
  )
  expect_match(nii$outputs$out_file, "[.]nii$")
  expect_false(grepl("[.]nii[.]gz$", nii$outputs$out_file))

  inferred <- ni_call("fsl.slice_timer", in_file = input)
  expect_named(inferred$outputs, "out_file")
  expect_match(inferred$outputs$out_file, "[.]nii[.]gz$")
})

test_that("slicetimer renders TR, global shift, direction, and custom timing explicitly", {
  input <- tempfile(fileext = ".nii.gz")
  timings <- tempfile(fileext = ".txt")
  output <- tempfile(fileext = ".nii.gz")
  file.create(input)
  writeLines(c("0", "-0.5"), timings)

  call <- ni_call(
    "fsl.slice_timer",
    in_file = input,
    out_file = output,
    custom_timings = timings,
    custom_timing_units = "fraction_of_tr",
    timing_reference = "forward_shift_to_reference",
    global_shift = 0.25,
    time_repetition = 2,
    slice_direction = 2
  )
  args <- niflowr:::build_command(call)$args
  expect_true("--repeat=2.000000" %in% args)
  expect_true("--tglobal=0.250000" %in% args)
  expect_true("--direction=2" %in% args)
  expect_true(any(startsWith(args, "--tcustom=")))
  expect_false(any(args %in% c("fraction_of_tr", "forward_shift_to_reference")))
})

test_that("custom timing files enforce units, reference, numeric shape, and range", {
  input <- tempfile(fileext = ".nii.gz")
  file.create(input)
  good <- tempfile(fileext = ".txt")
  writeLines(c("0", "-0.5"), good)

  expect_error(
    ni_call("fsl.slice_timer", in_file = input, custom_timings = good),
    "requires.*custom_timing_units"
  )
  expect_error(
    ni_call(
      "fsl.slice_timer", in_file = input, custom_timings = good,
      custom_timing_units = "seconds",
      timing_reference = "forward_shift_to_reference"
    ),
    "fraction_of_tr"
  )

  malformed <- tempfile(fileext = ".txt")
  writeLines(c("0 0.5", "text"), malformed)
  expect_error(
    ni_call(
      "fsl.slice_timer", in_file = input, custom_timings = malformed,
      custom_timing_units = "fraction_of_tr",
      timing_reference = "forward_shift_to_reference"
    ),
    "exactly 1 column"
  )
  outside <- tempfile(fileext = ".txt")
  writeLines(c("0", "1.25"), outside)
  expect_error(
    ni_call(
      "fsl.slice_timer", in_file = input, custom_timings = outside,
      custom_timing_units = "fraction_of_tr",
      timing_reference = "forward_shift_to_reference"
    ),
    "must be <= 1"
  )
})

test_that("slice timing conversion makes reference and sign explicit", {
  path <- tempfile(fileext = ".txt")
  timing <- ni_fsl_slice_timing_file(
    slice_timing = c(0, 1), repetition_time = 2,
    reference_time = 0, path = path
  )
  expect_s3_class(timing, "ni_fsl_slice_timing")
  expect_equal(timing$shifts, c(0, -0.5))
  expect_equal(scan(path, quiet = TRUE), c(0, -0.5))
  expect_identical(timing$units, "fraction_of_tr")
  expect_identical(timing$timing_reference, "forward_shift_to_reference")

  middle <- ni_fsl_slice_timing_file(c(0, 1), 2, 1, tempfile())
  expect_equal(middle$shifts, c(0.5, 0))
  expect_error(ni_fsl_slice_timing_file(c(0, 1), 2, 0, tempfile(), units = "ms"), "seconds")
  expect_error(ni_fsl_slice_timing_file(c(0, 2), 2, 0, tempfile()), "within")
})

test_that("slicetimer input and output paths map for native and container execution", {
  withr::with_tempdir({
    in_root <- file.path(getwd(), "in")
    out_root <- file.path(getwd(), "out")
    work_root <- file.path(getwd(), "work")
    dir.create(in_root)
    dir.create(out_root)
    dir.create(work_root)
    input <- file.path(in_root, "bold.nii.gz")
    timings <- file.path(in_root, "timings.txt")
    output <- file.path(out_root, "corrected.nii.gz")
    file.create(input)
    writeLines(c("0", "-0.5"), timings)
    call <- ni_call(
      "fsl.slice_timer", in_file = input, out_file = output,
      custom_timings = timings, custom_timing_units = "fraction_of_tr",
      timing_reference = "forward_shift_to_reference", .engine = "docker"
    )
    cfg <- ni_config_defaults()
    cfg$paths$in_root <- in_root
    cfg$paths$out_root <- out_root
    cfg$paths$work_root <- work_root
    mapped <- niflowr:::ni_rewrite_values_for_container(call$spec, call$values, cfg)
    expect_equal(mapped$in_file, "/in/bold.nii.gz")
    expect_equal(mapped$custom_timings, "/in/timings.txt")
    expect_equal(mapped$out_file, "/out/corrected.nii.gz")
    expect_equal(call$outputs$out_file, output)
  })
})

test_that("slicetimer regeneration overlay retains contract fixes", {
  overlay_path <- testthat::test_path("../../tools/spec_overrides/fsl.slice_timer.json")
  if (!file.exists(overlay_path)) skip("source regeneration overlay is not installed")
  overlay <- jsonlite::read_json(
    overlay_path,
    simplifyVector = FALSE
  )
  spec <- ni_spec_read("fsl.slice_timer")
  expect_identical(overlay$outputs, unclass(spec$outputs))
  expect_identical(overlay$inputs$global_shift$cli$argstr, "--tglobal=%f")
  expect_identical(
    overlay$inputs$custom_timings$constraints$requires,
    list("custom_timing_units", "timing_reference")
  )
})

test_that("committed FSL qualification covers every axis and two references", {
  report_path <- system.file("qualification", "fsl-slicetimer.json", package = "niflowr")
  if (!nzchar(report_path)) {
    report_path <- testthat::test_path("../../inst/qualification/fsl-slicetimer.json")
  }
  report <- jsonlite::read_json(
    report_path,
    simplifyVector = TRUE
  )
  expect_true(report$passed)
  expect_match(report$backend$version_line, "FSL")
  expect_setequal(report$cases$direction, 1:3)
  expect_setequal(report$cases$reference_time_seconds, c(0, 1))
  expect_true(all(report$cases$corrected_slice_rmse < report$thresholds$max_corrected_rmse))
  expect_true(all(report$cases$improvement_ratio > report$thresholds$min_improvement_ratio))
})
