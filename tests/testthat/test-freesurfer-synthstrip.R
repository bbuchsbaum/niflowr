# Tests for freesurfer.synthstrip spec and wrapper

test_that("freesurfer.synthstrip spec loads with expected fields", {
  spec <- ni_spec_read("freesurfer.synthstrip")
  expect_s3_class(spec, "ni_spec")
  expect_equal(spec$id, "freesurfer.synthstrip")
  expect_equal(spec$command, "mri_synthstrip")
  expect_equal(spec$runtime$profile, "freesurfer")
  expect_equal(spec$origin$source, "manual")
  expect_true(isTRUE(spec$inputs$in_file$required))
})

test_that("freesurfer.synthstrip renders core CLI args", {
  in_file <- withr::local_tempfile(fileext = ".nii.gz")
  file.create(in_file)
  call <- ni_call("freesurfer.synthstrip",
    in_file = in_file,
    out_file = "/tmp/T1_brain.nii.gz",
    mask_file = "/tmp/T1_mask.nii.gz",
    border = 2L,
    threads = 4L,
    gpu = TRUE,
    no_csf = TRUE
  )
  cmd <- ni_cmd(call)
  expect_equal(cmd$command, "mri_synthstrip")
  expect_true(all(c("-i", in_file) %in% cmd$args))
  expect_true(all(c("-o", "/tmp/T1_brain.nii.gz") %in% cmd$args))
  expect_true(all(c("-m", "/tmp/T1_mask.nii.gz") %in% cmd$args))
  expect_true(all(c("-b", "2") %in% cmd$args))
  expect_true(all(c("-t", "4") %in% cmd$args))
  expect_true("-g" %in% cmd$args)
  expect_true("--no-csf" %in% cmd$args)
})

test_that("freesurfer.synthstrip output paths come from inputs", {
  in_file <- withr::local_tempfile(fileext = ".nii.gz")
  file.create(in_file)
  call <- ni_call("freesurfer.synthstrip",
    in_file = in_file,
    out_file = "/tmp/T1_brain.nii.gz",
    mask_file = "/tmp/T1_mask.nii.gz",
    sdt_file = "/tmp/T1_sdt.nii.gz"
  )
  expect_equal(call$outputs$out_file, "/tmp/T1_brain.nii.gz")
  expect_equal(call$outputs$mask_file, "/tmp/T1_mask.nii.gz")
  expect_equal(call$outputs$sdt_file, "/tmp/T1_sdt.nii.gz")
})

test_that("ni_freesurfer_synthstrip wrapper exists and supports dry_run", {
  in_file <- withr::local_tempfile(fileext = ".nii.gz")
  file.create(in_file)
  expect_true(is.function(ni_freesurfer_synthstrip))
  result <- ni_freesurfer_synthstrip(
    in_file = in_file,
    out_file = "/tmp/T1_brain.nii.gz",
    .engine = "native",
    dry_run = TRUE
  )
  expect_null(result)
})

test_that("freesurfer.synthstrip is listed in ni_spec_list()", {
  expect_true("freesurfer.synthstrip" %in% ni_spec_list())
})
