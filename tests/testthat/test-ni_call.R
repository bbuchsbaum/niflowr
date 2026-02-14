test_that("ni_call creates a valid call object", {
  spec <- ni_spec_read("fsl.bet")
  withr::with_tempfile("tf", fileext = ".nii.gz", {
    file.create(tf)
    call <- ni_call(spec, in_file = tf, out_file = "/tmp/brain.nii.gz")
    expect_s3_class(call, "ni_call")
    expect_equal(call$values$in_file, tf)
    expect_equal(call$values$out_file, "/tmp/brain.nii.gz")
  })
})

test_that("ni_call resolves output paths", {
  spec <- ni_spec_read("fsl.bet")
  withr::with_tempfile("tf", fileext = ".nii.gz", {
    file.create(tf)
    call <- ni_call(spec, in_file = tf, out_file = "/tmp/brain.nii.gz")
    expect_equal(call$outputs$out_file, "/tmp/brain.nii.gz")
  })
})

test_that("ni_call accepts spec ID string", {
  withr::with_tempfile("tf", fileext = ".nii.gz", {
    file.create(tf)
    call <- ni_call("fsl.bet", in_file = tf, out_file = "/tmp/brain.nii.gz")
    expect_s3_class(call, "ni_call")
    expect_equal(call$spec$id, "fsl.bet")
  })
})

test_that("ni_cmd returns command components", {
  spec <- ni_spec_read("fsl.bet")
  call <- ni_call(spec, in_file = "/tmp/t1.nii.gz", out_file = "/tmp/brain.nii.gz",
                  .validate = FALSE)
  cmd <- ni_cmd(call)
  expect_type(cmd, "list")
  expect_equal(cmd$command, "bet")
  expect_type(cmd$args, "character")
  expect_true(length(cmd$args) >= 2)
})

test_that("print.ni_call runs without error", {
  spec <- ni_spec_read("fsl.bet")
  call <- ni_call(spec, in_file = "/tmp/t1.nii.gz", out_file = "/tmp/brain.nii.gz",
                  .validate = FALSE)
  expect_no_error(capture.output(print(call), type = "message"))
})

test_that("ni_call with .validate = FALSE skips validation", {
  spec <- ni_spec_read("fsl.bet")
  # This would normally fail validation (file doesn't exist)
  call <- ni_call(spec, in_file = "/nonexistent.nii.gz", out_file = "/tmp/out.nii.gz",
                  .validate = FALSE)
  expect_s3_class(call, "ni_call")
})

# ---- Internal function tests ----

test_that("coerce_input_value extracts path from ni_result", {
  result <- structure(list(
    outputs = list(out_file = "/tmp/brain.nii.gz")
  ), class = "ni_result")
  def <- list(type = "file")
  coerced <- niflowr:::coerce_input_value(result, def, "in_file")
  expect_equal(coerced, "/tmp/brain.nii.gz")
})

test_that("coerce_input_value extracts path from ni_call", {
  call_obj <- structure(list(
    outputs = list(out_file = "/tmp/brain.nii.gz")
  ), class = "ni_call")
  def <- list(type = "file")
  coerced <- niflowr:::coerce_input_value(call_obj, def, "in_file")
  expect_equal(coerced, "/tmp/brain.nii.gz")
})

test_that("coerce_input_value handles list of ni_results", {
  r1 <- structure(list(outputs = list(out_file = "/tmp/a.nii.gz")), class = "ni_result")
  r2 <- structure(list(outputs = list(out_file = "/tmp/b.nii.gz")), class = "ni_result")
  def <- list(type = "list")
  coerced <- niflowr:::coerce_input_value(list(r1, r2), def, "in_files")
  expect_equal(coerced, c("/tmp/a.nii.gz", "/tmp/b.nii.gz"))
})

test_that("extract_pipeline_path prefers preferred_name match", {
  outputs <- list(mask = "/tmp/mask.nii.gz", out_file = "/tmp/brain.nii.gz")
  path <- niflowr:::extract_pipeline_path(outputs, preferred_name = "mask")
  expect_equal(path, "/tmp/mask.nii.gz")
})

test_that("extract_pipeline_path falls back to out_file", {
  outputs <- list(out_file = "/tmp/brain.nii.gz", mask = "/tmp/mask.nii.gz")
  path <- niflowr:::extract_pipeline_path(outputs, preferred_name = "nonexistent")
  expect_equal(path, "/tmp/brain.nii.gz")
})

test_that("extract_pipeline_path uses first string when no match", {
  outputs <- list(matrix = "/tmp/transform.mat", warped = "/tmp/warped.nii.gz")
  path <- niflowr:::extract_pipeline_path(outputs)
  expect_true(path %in% c("/tmp/transform.mat", "/tmp/warped.nii.gz"))
})

test_that("extract_pipeline_path errors on empty outputs", {
  expect_error(
    niflowr:::extract_pipeline_path(list()),
    "no outputs"
  )
})

test_that("infer_output_desc detects mask", {
  desc <- niflowr:::infer_output_desc("fsl.bet", "brain_mask")
  expect_equal(desc, "mask")
})

test_that("infer_output_desc detects matrix/xfm", {
  desc <- niflowr:::infer_output_desc("fsl.flirt", "out_matrix_file")
  expect_equal(desc, "xfm")
})

test_that("infer_output_desc uses tool name for fsl.bet", {
  desc <- niflowr:::infer_output_desc("fsl.bet", "out_file")
  expect_equal(desc, "brain")
})

test_that("infer_output_desc uses tool name for fsl.flirt", {
  desc <- niflowr:::infer_output_desc("fsl.flirt", "out_file")
  expect_equal(desc, "reg")
})

test_that("infer_output_desc falls back to tool name for out_file", {
  # mcflirt contains "flirt" so it matches the flirt pattern first
  desc <- niflowr:::infer_output_desc("fsl.mcflirt", "out_file")
  expect_equal(desc, "reg")

  # Use a tool without pattern matches to test the fallback
  desc2 <- niflowr:::infer_output_desc("fsl.fast", "out_file")
  expect_equal(desc2, "fast")
})

test_that("detect_known_extension recognizes .nii.gz", {
  ext <- niflowr:::detect_known_extension("foo.nii.gz")
  expect_equal(ext, ".nii.gz")
})

test_that("detect_known_extension recognizes .mat", {
  ext <- niflowr:::detect_known_extension("transform.mat")
  expect_equal(ext, ".mat")
})

test_that("detect_known_extension returns NULL for unknown", {
  ext <- niflowr:::detect_known_extension("foo.unknown")
  expect_null(ext)
})

test_that("strip_known_extension removes .nii.gz", {
  stem <- niflowr:::strip_known_extension("brain.nii.gz")
  expect_equal(stem, "brain")
})

test_that("strip_known_extension removes .mat", {
  stem <- niflowr:::strip_known_extension("transform.mat")
  expect_equal(stem, "transform")
})

test_that("is_bids_like_path detects BIDS paths", {
  expect_true(niflowr:::is_bids_like_path("sub-01_T1w.nii.gz"))
  expect_true(niflowr:::is_bids_like_path("/data/sub-01_ses-1_T1w.nii.gz"))
})

test_that("is_bids_like_path rejects non-BIDS paths", {
  expect_false(niflowr:::is_bids_like_path("random_file.nii.gz"))
  expect_false(niflowr:::is_bids_like_path("brain.nii.gz"))
})

test_that("resolve_outputs handles template output", {
  spec <- structure(list(
    outputs = list(
      out_file = list(
        path = list(template = "{base_dir}/output_{suffix}.nii.gz")
      )
    )
  ), class = "ni_spec")
  values <- list(base_dir = "/tmp", suffix = "brain")
  outputs <- niflowr:::resolve_outputs(spec, values)
  expect_equal(outputs$out_file, "/tmp/output_brain.nii.gz")
})
