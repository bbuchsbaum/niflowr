test_that("dcm2niix.convert spec loads with expected metadata", {
  spec <- ni_spec_read("dcm2niix.convert")
  expect_s3_class(spec, "ni_spec")
  expect_equal(spec$id, "dcm2niix.convert")
  expect_equal(spec$command, "dcm2niix")
  expect_true(isTRUE(spec$inputs$in_folder$required))
  expect_equal(spec$runtime$profile, "dcm2niix")
  expect_equal(spec$origin$source, "manual")
})

test_that("dcm2niix.convert renders key CLI options and keeps input folder last", {
  dicom_dir <- tempfile("dicom_")
  dir.create(dicom_dir)

  call <- ni_call(
    "dcm2niix.convert",
    in_folder = dicom_dir,
    out_dir = "/tmp/niflowr/dcm2niix_out",
    filename = "%p_%t_%s",
    bids_sidecar = "y",
    anon_bids = "n",
    compression = "y",
    depth = 2L
  )
  cmd <- ni_cmd(call)

  expect_equal(cmd$command, "dcm2niix")
  expect_true(all(c("-b", "y", "-ba", "n") %in% cmd$args))
  expect_true(all(c("-f", "%p_%t_%s") %in% cmd$args))
  expect_true(all(c("-o", "/tmp/niflowr/dcm2niix_out") %in% cmd$args))
  expect_true(all(c("-z", "y") %in% cmd$args))
  expect_true(all(c("-d", "2") %in% cmd$args))
  expect_equal(tail(cmd$args, 1), dicom_dir)
})

test_that("dcm2niix.convert repeats -n for series_crc list values", {
  dicom_dir <- tempfile("dicom_")
  dir.create(dicom_dir)

  call <- ni_call(
    "dcm2niix.convert",
    in_folder = dicom_dir,
    series_crc = c("101", "202", "303")
  )
  cmd <- ni_cmd(call)
  n_pos <- which(cmd$args == "-n")

  expect_length(n_pos, 3)
  expect_equal(cmd$args[n_pos + 1], c("101", "202", "303"))
  expect_equal(tail(cmd$args, 1), dicom_dir)
})

test_that("dcm2niix.convert output_dir resolves from out_dir when provided", {
  dicom_dir <- tempfile("dicom_")
  dir.create(dicom_dir)

  call_default <- ni_call("dcm2niix.convert", in_folder = dicom_dir)
  expect_null(call_default$outputs$output_dir)

  call_out <- ni_call(
    "dcm2niix.convert",
    in_folder = dicom_dir,
    out_dir = "/tmp/niflowr/dcm2niix_custom_out"
  )
  expect_equal(call_out$outputs$output_dir, "/tmp/niflowr/dcm2niix_custom_out")
})

test_that("dcm2niix.convert validates enum and numeric inputs", {
  dicom_dir <- tempfile("dicom_")
  dir.create(dicom_dir)

  expect_error(
    ni_call("dcm2niix.convert", in_folder = dicom_dir, compression = "bad"),
    "must be one of"
  )

  expect_error(
    ni_call("dcm2niix.convert", in_folder = dicom_dir, compression_level = 10L),
    "must be <= 9"
  )
})

test_that("dcm2niix.convert coerces logical enum inputs to y/n", {
  dicom_dir <- tempfile("dicom_")
  dir.create(dicom_dir)

  call <- ni_call(
    "dcm2niix.convert",
    in_folder = dicom_dir,
    bids_sidecar = TRUE,
    anon_bids = FALSE,
    compression = TRUE
  )
  cmd <- ni_cmd(call)

  expect_true(all(c("-b", "y") %in% cmd$args))
  expect_true(all(c("-ba", "n") %in% cmd$args))
  expect_true(all(c("-z", "y") %in% cmd$args))
})

test_that("dcm2niix.convert enforces BIDS option dependencies and label format", {
  dicom_dir <- tempfile("dicom_")
  dir.create(dicom_dir)

  expect_error(
    ni_call("dcm2niix.convert", in_folder = dicom_dir, bids_subject = "01"),
    "requires"
  )

  expect_error(
    ni_call("dcm2niix.convert", in_folder = dicom_dir, anon_bids = "y"),
    "requires"
  )

  expect_error(
    ni_call(
      "dcm2niix.convert",
      in_folder = dicom_dir,
      bids_sidecar = "y",
      bids_session = "ses-01"
    ),
    "must match pattern"
  )
})

test_that("dcm2niix.convert validates in_folder existence", {
  expect_error(
    ni_call("dcm2niix.convert", in_folder = "/tmp/niflowr/path/that/does/not/exist"),
    "does not exist"
  )
})

test_that("ni_dcm2niix_convert wrapper exists and supports dry_run", {
  expect_true(is.function(ni_dcm2niix_convert))

  dicom_dir <- tempfile("dicom_")
  dir.create(dicom_dir)

  result <- ni_dcm2niix_convert(
    in_folder = dicom_dir,
    out_dir = tempfile("dcm2niix_out_"),
    .engine = "native",
    dry_run = TRUE
  )
  expect_null(result)
})

test_that("dcm2niix.convert appears in ni_spec_list", {
  specs <- ni_spec_list()
  expect_true("dcm2niix.convert" %in% specs)
})
