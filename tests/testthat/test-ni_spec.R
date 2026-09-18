test_that("ni_spec_read loads bundled spec", {
  spec <- ni_spec_read("fsl.bet")
  expect_s3_class(spec, "ni_spec")
  expect_equal(spec$id, "fsl.bet")
  expect_equal(spec$command, "bet")
  expect_true("in_file" %in% names(spec$inputs))
  expect_true("out_file" %in% names(spec$outputs))
})

test_that("ni_spec_read caches specs", {
  spec1 <- ni_spec_read("fsl.bet", cache = TRUE)
  spec2 <- ni_spec_read("fsl.bet", cache = TRUE)
  expect_identical(spec1, spec2)
})

test_that("ni_spec_read errors on missing spec", {
  expect_error(ni_spec_read("nonexistent.tool"), "No bundled spec")
})

test_that("ni_spec_list returns available specs", {
  specs <- ni_spec_list()
  expect_type(specs, "character")
  expect_true("fsl.bet" %in% specs)
})

test_that("print.ni_spec runs without error", {
  spec <- ni_spec_read("fsl.bet")
  expect_no_error(capture.output(print(spec), type = "message"))
})

test_that("ni_spec_validate catches invalid spec", {
  bad_spec <- list(id = "bad", command = "x")
  # Missing required fields: spec_version, inputs, outputs
  expect_error(ni_spec_validate(bad_spec, "test"), "validation failed")
})

test_that("transform metadata distinguishes format, payload, and domains", {
  cases <- list(
    c("fsl.flirt", "out_matrix_file", "affine", "fsl", "in_file", "reference"),
    c("ants.ai", "output_transform", "affine", "itk", "moving_image", "fixed_image"),
    c("afni.allineate", "out_matrix", "affine", "afni", "in_file", "reference"),
    c("freesurfer.mri_coreg", "out_lta_file", "affine", "lta", "source_file", "reference_file"),
    c("ants.transform_build", "composite_transform", "composite", "ants_h5", "moving_image", "fixed_image")
  )

  for (case in cases) {
    spec <- ni_spec_read(case[[1]], cache = FALSE)
    transform <- spec$outputs[[case[[2]]]]$transform
    expect_equal(
      unlist(transform, use.names = FALSE),
      unname(case[3:6]),
      info = paste(case[1:2], collapse = ":")
    )
  }

  transform_build <- ni_spec_read("ants.transform_build", cache = FALSE)
  inverse <- transform_build$outputs$inverse_composite_transform$transform
  expect_equal(inverse$source, "fixed_image")
  expect_equal(inverse$target, "moving_image")
})

test_that("spec schema rejects unsupported transform formats", {
  spec <- ni_spec_read("fsl.flirt", cache = FALSE)
  spec$outputs$out_matrix_file$transform$format <- "mystery_mat"
  expect_error(ni_spec_validate(spec, "bad transform"), "validation failed")
})
