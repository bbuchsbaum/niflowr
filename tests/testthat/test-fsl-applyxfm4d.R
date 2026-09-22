applyxfm4d_fixture <- function(wd) {
  skip_if_not_installed("RNifti")
  dir.create(wd, recursive = TRUE, showWarnings = FALSE)
  input <- file.path(wd, "source series.nii.gz")
  reference <- file.path(wd, "reference.nii.gz")
  matrices <- file.path(wd, "motion matrices")
  dir.create(matrices)
  volume <- array(0, c(9L, 9L, 9L))
  volume[4:6, 4:6, 4:6] <- 100
  write_image <- function(data, path) {
    image <- RNifti::asNifti(data)
    transform <- diag(4)
    attr(transform, "code") <- 1L
    RNifti::qform(image) <- transform
    RNifti::sform(image) <- transform
    RNifti::writeNifti(image, path)
  }
  write_image(array(rep(volume, 2), c(dim(volume), 2L)), input)
  write_image(volume, reference)
  write_matrix <- function(x, name) utils::write.table(x, file.path(matrices, name),
    row.names = FALSE, col.names = FALSE, quote = FALSE)
  write_matrix(diag(4), "MAT_0000")
  translated <- diag(4)
  translated[1, 4] <- 2
  write_matrix(translated, "MAT_0001")
  list(input = input, reference = reference, matrices = matrices,
       output = file.path(wd, "applied.nii"), volume = volume)
}

applyxfm4d_call <- function(f, ...) ni_call("fsl.applyxfm4d", in_file = f$input,
  reference = f$reference, out_file = f$output, ...)

test_that("applyxfm4d has a persistent typed manual spec and exact previews", {
  spec <- ni_spec_read("fsl.applyxfm4d")
  expect_identical(spec$origin$source, "manual")
  expect_identical(spec$inputs$mat_dir$type, "dir")
  expect_identical(spec$inputs$single_matrix$type, "file")
  expect_false(any(grepl("interp", names(spec$inputs))))
  expect_true(exists("ni_fsl_applyxfm4d", envir = asNamespace("niflowr")))
  f <- applyxfm4d_fixture(withr::local_tempdir())
  call <- applyxfm4d_call(f, mat_dir = f$matrices)
  expect_identical(ni_cmd(call)$args, c(f$input, f$reference,
    sub("[.]nii$", "", f$output), f$matrices, "-fourdigit"))
  expect_identical(call$outputs$out_file, paste0(f$output, ".gz"))
  call <- applyxfm4d_call(f, single_matrix = file.path(f$matrices, "MAT_0000"),
    .env = c(FSLOUTPUTTYPE = "NIFTI"))
  expect_identical(call$outputs$out_file, f$output)
  expect_identical(tail(ni_cmd(call)$args, 2),
    c(file.path(f$matrices, "MAT_0000"), "-singlematrix"))
  expect_error(applyxfm4d_call(f), "exactly one", class = "niflowr_applyxfm4d_error")
  expect_error(applyxfm4d_call(f, mat_dir = f$matrices,
    single_matrix = file.path(f$matrices, "MAT_0000")), "mutually exclusive")
  expect_error(applyxfm4d_call(f, mat_dir = f$matrices, interpolation = "wsinc5"), "Unknown parameter")
  expect_error(applyxfm4d_call(f, mat_dir = f$matrices,
    .env = c(FSLOUTPUTTYPE = "ANALYZE")), "NIFTI and NIFTI_GZ")
})

test_that("applyxfm4d rejects missing, extra, malformed and misnumbered matrices", {
  f <- applyxfm4d_fixture(withr::local_tempdir())
  missing <- file.path(f$matrices, "MAT_0001")
  original <- readLines(missing)
  unlink(missing)
  expect_error(applyxfm4d_call(f, mat_dir = f$matrices), "Missing: MAT_0001",
    class = "niflowr_applyxfm4d_error")
  writeLines(original, file.path(f$matrices, "MAT_00001"))
  expect_error(applyxfm4d_call(f, mat_dir = f$matrices), "unexpected: MAT_00001")
  unlink(file.path(f$matrices, "MAT_00001"))
  writeLines(c("1 0 0 NaN", "0 1 0 0", "0 0 1 0", "0 0 0 1"), missing)
  expect_error(applyxfm4d_call(f, mat_dir = f$matrices), "Invalid finite")
  writeLines(c("1 0 0 0", "0 0 0 0", "0 0 1 0", "0 0 0 1"), missing)
  expect_error(applyxfm4d_call(f, mat_dir = f$matrices), "nonsingular")
  writeLines(original, missing)
  file.create(file.path(f$matrices, "MAT_0002"))
  expect_error(applyxfm4d_call(f, mat_dir = f$matrices), "unexpected: MAT_0002")
  unlink(file.path(f$matrices, "MAT_0002"))
  RNifti::writeNifti(f$volume, f$input)
  expect_error(applyxfm4d_call(f, mat_dir = f$matrices), "requires a 4D source")
})

test_that("applyxfm4d validates at execution even after preview or input mutation", {
  f <- applyxfm4d_fixture(withr::local_tempdir())
  call <- applyxfm4d_call(f, mat_dir = f$matrices, .engine = "native")
  unlink(file.path(f$matrices, "MAT_0001"))
  expect_error(ni_run(call), "Missing: MAT_0001")
  preview <- applyxfm4d_call(f, mat_dir = f$matrices, .engine = "native", .validate = FALSE)
  expect_error(ni_run(preview), "Missing: MAT_0001")
  expect_false(file.exists(paste0(f$output, ".gz")))
})

test_that("real applyxfm4d preserves volume ordering, mounts, and output formats", {
  image <- Sys.getenv("NIFLOWR_TEST_FSL_IMAGE")
  skip_if(!nzchar(image), "Set NIFLOWR_TEST_FSL_IMAGE to a pinned local FSL Docker image")
  f <- applyxfm4d_fixture(file.path(withr::local_tempdir(), "in"))
  root <- dirname(dirname(f$input))
  out <- file.path(root, "out")
  work <- file.path(root, "work")
  dir.create(out)
  dir.create(work)
  old <- ni_config()
  withr::defer(ni_config(config = old, .reset = TRUE))
  ni_config(.reset = TRUE, auto_read = FALSE, config = list(
    paths = list(in_root = dirname(f$input), out_root = out, work_root = work),
    env = list(PATH = "/usr/local/fsl/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
               FSLDIR = "/usr/local/fsl"),
    profiles = list(fsl = list(docker_image = image, platform = "linux/amd64", entrypoint = character()))))
  for (format in c("NIFTI_GZ", "NIFTI")) {
    f$output <- file.path(out, paste0("applied-", format, ".nii.gz"))
    call <- applyxfm4d_call(f, mat_dir = f$matrices, .engine = "docker",
      .env = c(FSLOUTPUTTYPE = format))
    plan <- ni_plan(call)
    expect_identical(plan$container_payload$args,
      c("/in/source series.nii.gz", "/in/reference.nii.gz",
        paste0("/out/applied-", format), "/in/motion matrices", "-fourdigit"))
    result <- ni_run(call, echo = FALSE)
    expect_s3_class(result, "ni_result")
    expect_true(file.exists(call$outputs$out_file))
    actual <- RNifti::readNifti(call$outputs$out_file)
    expect_identical(dim(actual), c(9L, 9L, 9L, 2L))
    expect_lt(max(abs(as.numeric(actual[,,,1]) - as.numeric(f$volume))), 1e-4)
    # A distinct +2mm FSL x translation shifts the object two voxels toward
    # smaller array x for this positive-determinant NIfTI grid.
    shifted <- array(0, dim(f$volume))
    shifted[1:7,,] <- f$volume[3:9,,]
    expect_lt(max(abs(as.numeric(actual[,,,2]) - as.numeric(shifted))), 1e-3)
    expect_identical(call$outputs$out_file,
      file.path(out, paste0("applied-", format, if (format == "NIFTI") ".nii" else ".nii.gz")))
  }
  f$output <- file.path(out, "single.nii.gz")
  call <- applyxfm4d_call(f, single_matrix = file.path(f$matrices, "MAT_0000"), .engine = "docker")
  ni_run(call, echo = FALSE)
  actual <- RNifti::readNifti(call$outputs$out_file)
  expect_lt(max(abs(as.numeric(actual[,,,1]) - as.numeric(actual[,,,2]))), 1e-4)
  f$output <- file.path(out, "missing.nii.gz")
  call <- applyxfm4d_call(f, mat_dir = f$matrices, .engine = "docker")
  unlink(file.path(f$matrices, "MAT_0001"))
  expect_error(ni_run(call), "Missing: MAT_0001")
  expect_false(file.exists(call$outputs$out_file))
})
