test_that("applyxfm4D renders only its supported FSL matrix modes", {
  input <- "/tmp/niflowr/input.nii.gz"
  reference <- "/tmp/niflowr/reference.nii.gz"
  output <- "/tmp/niflowr/applied.nii.gz"
  matrices <- "/tmp/niflowr/matrices"
  matrix <- "/tmp/niflowr/one.mat"

  per_volume <- ni_call("fsl.applyxfm4d",
    in_file = input, reference = reference, out_file = output,
    mat_dir = matrices, .validate = FALSE)
  expect_identical(
    ni_cmd(per_volume)$args,
    c(input, reference, "/tmp/niflowr/applied", matrices, "-fourdigit")
  )
  expect_identical(per_volume$outputs$out_file, "/tmp/niflowr/applied.nii.gz")
  nii_requested <- ni_call("fsl.applyxfm4d",
    in_file = input, reference = reference, out_file = "/tmp/niflowr/applied.nii",
    mat_dir = matrices, .validate = FALSE)
  expect_identical(nii_requested$outputs$out_file, "/tmp/niflowr/applied.nii.gz")
  nifti_runtime <- ni_call("fsl.applyxfm4d",
    in_file = input, reference = reference, out_file = output,
    mat_dir = matrices, .env = c(FSLOUTPUTTYPE = "NIFTI"), .validate = FALSE)
  expect_identical(nifti_runtime$outputs$out_file, "/tmp/niflowr/applied.nii")
  expect_false(any(grepl("interp", names(per_volume$spec$inputs), ignore.case = TRUE)))

  single <- ni_call("fsl.applyxfm4d",
    in_file = input, reference = reference, out_file = output,
    single_matrix = matrix, .validate = FALSE)
  expect_identical(
    ni_cmd(single)$args,
    c(input, reference, "/tmp/niflowr/applied", matrix, "-singlematrix")
  )

  expect_error(
    ni_cmd(ni_call("fsl.applyxfm4d", in_file = input, reference = reference,
      out_file = output, mat_dir = matrices, single_matrix = matrix, .validate = FALSE)),
    "exactly one matrix source"
  )
  expect_error(
    ni_cmd(ni_call("fsl.applyxfm4d", in_file = input, reference = reference,
      out_file = output, .validate = FALSE)),
    "exactly one matrix source"
  )
})

test_that("applyxfm4D requires ordered four-digit matrices for every volume", {
  skip_if_not_installed("RNifti")
  wd <- withr::local_tempdir()
  input <- file.path(wd, "input.nii.gz")
  reference <- file.path(wd, "reference.nii.gz")
  matrices <- file.path(wd, "matrices")
  dir.create(matrices)

  series <- array(0, c(5, 5, 5, 2))
  series[2:4, 2:4, 2:4, 1] <- 1
  series[1:3, 2:4, 2:4, 2] <- 1
  RNifti::writeNifti(RNifti::asNifti(series), input, datatype = "float")
  RNifti::writeNifti(RNifti::asNifti(series[, , , 1]), reference, datatype = "float")
  affine <- c("1 0 0 0", "0 1 0 0", "0 0 1 0", "0 0 0 1")
  writeLines(affine, file.path(matrices, "MAT_0000"))

  call <- ni_call("fsl.applyxfm4d", in_file = input, reference = reference,
    out_file = file.path(wd, "applied.nii.gz"), mat_dir = matrices)
  expect_error(ni_cmd(call), "Missing: MAT_0001")

  writeLines(affine, file.path(matrices, "MAT_0001"))
  expect_identical(
    ni_cmd(call)$args,
    c(input, reference, file.path(wd, "applied"), matrices, "-fourdigit")
  )
})

test_that("applyxfm4D maps matrix directories and explicit output paths into containers", {
  wd <- withr::local_tempdir()
  roots <- file.path(wd, c("in", "out", "work"))
  lapply(roots, dir.create)
  input <- file.path(roots[[1]], "input.nii.gz")
  reference <- file.path(roots[[1]], "reference.nii.gz")
  matrices <- file.path(roots[[1]], "matrices")
  matrix <- file.path(roots[[1]], "one.mat")
  file.create(input, reference, matrix)
  dir.create(matrices)

  cfg <- ni_config_defaults()
  cfg$paths$in_root <- roots[[1]]
  cfg$paths$out_root <- roots[[2]]
  cfg$paths$work_root <- roots[[3]]
  output <- file.path(roots[[2]], "applied.nii.gz")
  call <- ni_call("fsl.applyxfm4d", in_file = input, reference = reference,
    out_file = output, mat_dir = matrices, .validate = FALSE)
  mapped <- niflowr:::ni_rewrite_values_for_container(call$spec, call$values, cfg)
  mapped_call <- call
  mapped_call$values <- mapped
  expect_identical(
    niflowr:::build_command(mapped_call)$args,
    c("/in/input.nii.gz", "/in/reference.nii.gz", "/out/applied", "/in/matrices", "-fourdigit")
  )

  single <- ni_call("fsl.applyxfm4d", in_file = input, reference = reference,
    out_file = output, single_matrix = matrix, .validate = FALSE)
  mapped_single <- single
  mapped_single$values <- niflowr:::ni_rewrite_values_for_container(single$spec, single$values, cfg)
  expect_identical(
    niflowr:::build_command(mapped_single)$args,
    c("/in/input.nii.gz", "/in/reference.nii.gz", "/out/applied", "/in/one.mat", "-singlematrix")
  )
})

test_that("pinned FSL applies a time-varying affine and honors NIFTI output naming", {
  image <- Sys.getenv("NIFLOWR_FSL_DOCKER_IMAGE")
  skip_if(!nzchar(image), "Set NIFLOWR_FSL_DOCKER_IMAGE for pinned FSL integration")
  skip_if_not_installed("RNifti")
  skip_if(!nzchar(Sys.which("docker")), "docker is required for FSL integration")

  wd <- withr::local_tempdir()
  roots <- file.path(wd, c("in", "out", "work"))
  lapply(roots, dir.create)
  input <- file.path(roots[[1]], "input.nii.gz")
  reference <- file.path(roots[[1]], "reference.nii.gz")
  matrices <- file.path(roots[[1]], "matrices")
  dir.create(matrices)
  output <- file.path(roots[[2]], "applied.nii.gz")

  series <- array(0, c(8, 8, 8, 2))
  series[4:6, 3:5, 3:5, 1] <- 1
  series[3:5, 3:5, 3:5, 2] <- 1
  RNifti::writeNifti(RNifti::asNifti(series), input, datatype = "float")
  RNifti::writeNifti(RNifti::asNifti(series[, , , 1]), reference, datatype = "float")
  identity <- c("1 0 0 0", "0 1 0 0", "0 0 1 0", "0 0 0 1")
  shift_right <- c("1 0 0 1", "0 1 0 0", "0 0 1 0", "0 0 0 1")
  writeLines(identity, file.path(matrices, "MAT_0000"))
  writeLines(shift_right, file.path(matrices, "MAT_0001"))

  on.exit(ni_config(.reset = TRUE, auto_read = FALSE), add = TRUE)
  ni_config(.reset = TRUE, auto_read = FALSE)
  ni_config(config = list(
    runtime = list(engine = "docker", prefer = "docker"),
    paths = list(in_root = roots[[1]], out_root = roots[[2]], work_root = roots[[3]]),
    docker = list(pull_policy = "never"),
    profiles = list(fsl = list(docker_image = image, platform = "linux/amd64"))
  ))

  result <- ni_run(ni_call("fsl.applyxfm4d", in_file = input, reference = reference,
    out_file = output, mat_dir = matrices, .engine = "docker", .profile = "fsl"),
    echo = FALSE, provenance = FALSE)
  expect_true(result$runtime$success)
  expect_true(file.exists(output))
  applied <- as.array(RNifti::readNifti(output))
  expect_equal(dim(applied), dim(series))
  expect_equal(applied[, , , 1], series[, , , 1], tolerance = 1e-6)
  expect_gt(max(abs(applied[, , , 2] - series[, , , 2])), 0.5)

  nifti_output <- file.path(roots[[2]], "single.nii.gz")
  single <- file.path(roots[[1]], "single.mat")
  writeLines(identity, single)
  result_nifti <- ni_run(ni_call("fsl.applyxfm4d", in_file = input, reference = reference,
    out_file = nifti_output, single_matrix = single, .engine = "docker", .profile = "fsl",
    .env = c(FSLOUTPUTTYPE = "NIFTI")), echo = FALSE, provenance = FALSE)
  expect_true(result_nifti$runtime$success)
  expect_true(file.exists(file.path(roots[[2]], "single.nii")))
  expect_false(file.exists(nifti_output))
})
