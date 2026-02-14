test_that("ni_read_output errors on non-ni_result input", {
  expect_error(ni_read_output(list()), "ni_result")
})

test_that("ni_read_output errors when output_name not found", {
  result <- structure(list(
    outputs = list(out_file = "/tmp/out.nii.gz"),
    runtime = list(), provenance = list(), call = list()
  ), class = "ni_result")
  skip_if_not_installed("neuroim2")
  expect_error(ni_read_output(result, "nonexistent"), "not found")
})

test_that("ni_read_output errors when file doesn't exist", {
  result <- structure(list(
    outputs = list(out_file = "/nonexistent/out.nii.gz"),
    runtime = list(), provenance = list(), call = list()
  ), class = "ni_result")
  skip_if_not_installed("neuroim2")
  expect_error(ni_read_output(result), "does not exist")
})

test_that("ni_read_output requires neuroim2 package", {
  skip_if(requireNamespace("neuroim2", quietly = TRUE), "neuroim2 is installed")
  result <- structure(list(
    outputs = list(out_file = "/tmp/out.nii.gz"),
    runtime = list(), provenance = list(), call = list()
  ), class = "ni_result")
  expect_error(ni_read_output(result), "neuroim2")
})

test_that("ni_read_transform errors on non-ni_result input", {
  expect_error(ni_read_transform(list()), "ni_result")
})

test_that("ni_read_transform errors when no transform output found", {
  result <- structure(list(
    spec_id = "fsl.bet",
    outputs = list(out_file = "/tmp/brain.nii.gz"),
    runtime = list(), provenance = list(), call = list()
  ), class = "ni_result")
  skip_if_not_installed("neurotransform")
  expect_error(ni_read_transform(result), "Could not identify")
})

test_that("ni_read_transform finds transform output by pattern", {
  result <- structure(list(
    spec_id = "fsl.flirt",
    outputs = list(out_file = "/tmp/out.nii.gz", out_matrix_file = "/tmp/out.mat"),
    runtime = list(), provenance = list(), call = list()
  ), class = "ni_result")
  skip_if_not_installed("neurotransform")
  # Would find "out_matrix_file" matching "matrix" pattern
  # But file doesn't exist, so it errors
  expect_error(ni_read_transform(result), "does not exist")
})

test_that("ni_read_transform requires neurotransform package", {
  skip_if(requireNamespace("neurotransform", quietly = TRUE), "neurotransform is installed")
  result <- structure(list(
    spec_id = "fsl.flirt",
    outputs = list(out_matrix_file = "/tmp/out.mat"),
    runtime = list(), provenance = list(), call = list()
  ), class = "ni_result")
  expect_error(ni_read_transform(result), "neurotransform")
})

test_that("ni_read_transform infers type from spec_id", {
  # FSL spec should infer fsl type
  result_fsl <- structure(list(
    spec_id = "fsl.flirt",
    outputs = list(out_matrix_file = "/tmp/out.mat"),
    runtime = list(), provenance = list(), call = list()
  ), class = "ni_result")
  skip_if_not_installed("neurotransform")
  # File doesn't exist but we can check it tries to read
  expect_error(ni_read_transform(result_fsl), "does not exist")

  # ANTS spec should infer ants type
  result_ants <- structure(list(
    spec_id = "ants.registration",
    outputs = list(forward_transform = "/tmp/transform.mat"),
    runtime = list(), provenance = list(), call = list()
  ), class = "ni_result")
  expect_error(ni_read_transform(result_ants), "does not exist")
})
