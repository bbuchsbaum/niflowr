test_that("AFNI no-image sentinels remain literals in native plans", {
  wd <- withr::local_tempdir()
  input <- file.path(wd, "input.nii.gz")
  base <- file.path(wd, "base.nii.gz")
  file.create(input, base)

  call <- ni_call(
    "afni.volreg",
    in_file = input,
    basefile = base,
    oned_matrix_save = file.path(wd, "motion"),
    oned_file = file.path(wd, "motion.1D"),
    .cwd = wd,
    .engine = "native"
  )
  plan <- ni_plan(call)

  expect_identical(plan$call$values$out_file, "NULL")
  expect_true("NULL" %in% plan$host_payload$args)
  expect_false(any(grepl("/NULL$", plan$host_payload$args)))
  expect_false("out_file" %in% names(plan$outputs))
  expect_equal(niflowr:::ni_norm(plan$outputs$oned_matrix_save),
    niflowr:::ni_norm(file.path(wd, "motion.aff12.1D")))
  expect_false("out_file" %in% names(niflowr:::ni_input_identities(plan$call)))
})

test_that("AFNI no-image sentinels are not staged or container-rewritten", {
  wd <- withr::local_tempdir()
  roots <- file.path(wd, c("in", "out", "work"))
  lapply(roots, dir.create)
  input <- file.path(roots[[1]], "input.nii.gz")
  base <- file.path(roots[[1]], "base.nii.gz")
  file.create(input, base)

  cfg <- ni_config_defaults()
  cfg$paths$in_root <- roots[[1]]
  cfg$paths$out_root <- roots[[2]]
  cfg$paths$work_root <- roots[[3]]
  spec <- ni_spec_read("afni.volreg")
  values <- ni_call(
    spec,
    in_file = input,
    basefile = base,
    oned_matrix_save = file.path(roots[[2]], "motion.1D"),
    .validate = TRUE
  )$values
  mapped <- niflowr:::ni_rewrite_values_for_container(spec, values, cfg)

  expect_identical(mapped$out_file, "NULL")
  expect_identical(mapped$in_file, "/in/input.nii.gz")
  expect_identical(mapped$oned_matrix_save, "/out/motion.1D")
  expect_false(file.exists(file.path(roots[[3]], "_stage", "NULL")))
})

test_that("3dTshift uses one typed timing-file token and explicit seconds", {
  wd <- withr::local_tempdir()
  input <- file.path(wd, "input series.nii.gz")
  timing <- file.path(wd, "slice offsets.1D")
  output <- file.path(wd, "shifted series.nii.gz")
  file.create(input)
  writeLines("0 0.5 1 1.5", timing)

  call <- ni_call(
    "afni.t_shift",
    in_file = input,
    out_file = output,
    slice_timing = timing,
    tr = 2,
    tzero = 1,
    ignore = 0,
    interp = "Fourier",
    .cwd = wd,
    .engine = "native"
  )
  args <- ni_cmd(call)$args

  expect_true(paste0("@", call$values$slice_timing) %in% args)
  expect_equal(sum(startsWith(args, "@")), 1L)
  expect_equal(args[match("-TR", args) + 1L], "2s")
  expect_equal(niflowr:::ni_norm(call$outputs$out_file), niflowr:::ni_norm(output))
  expect_true(call$spec$outputs$out_file$must_exist)
  expect_true(call$spec$outputs$out_file$nonempty)

  roots <- file.path(wd, c("container in", "container out", "container work"))
  lapply(roots, dir.create)
  container_input <- file.path(roots[[1]], basename(input))
  container_timing <- file.path(roots[[1]], basename(timing))
  file.copy(input, container_input)
  file.copy(timing, container_timing)
  cfg <- ni_config_defaults()
  cfg$paths$in_root <- roots[[1]]
  cfg$paths$out_root <- roots[[2]]
  cfg$paths$work_root <- roots[[3]]
  container_call <- ni_call("afni.t_shift", in_file = container_input,
    out_file = file.path(roots[[2]], basename(output)),
    slice_timing = container_timing, tr = 2, tzero = 1, ignore = 0,
    interp = "Fourier")
  container_call$values <- niflowr:::ni_rewrite_values_for_container(
    container_call$spec, container_call$values, cfg)
  container_args <- niflowr:::build_command(container_call)$args
  expect_true("@/in/slice offsets.1D" %in% container_args)
  expect_true("/out/shifted series.nii.gz" %in% container_args)

  expect_error(ni_call("afni.t_shift", in_file = input, out_file = output,
    slice_timing = timing, tr = Inf), "finite")
  expect_error(ni_call("afni.t_shift", in_file = input, out_file = output,
    slice_timing = timing, tr = 2, tzero = 0, tslice = 0), "mutually exclusive")
  expect_error(ni_call("afni.t_shift", in_file = input, out_file = output,
    slice_timing = timing, tr = 2, rlt = TRUE, rltplus = TRUE), "mutually exclusive")
})

test_that("3dAllineate estimate and application are separate typed contracts", {
  wd <- withr::local_tempdir()
  source <- file.path(wd, "source.nii.gz")
  reference <- file.path(wd, "reference.nii.gz")
  matrix <- file.path(wd, "affine")
  output <- file.path(wd, "applied.nii.gz")
  file.create(source, reference)

  estimate <- ni_call(
    "afni.allineate_estimate",
    in_file = source,
    reference = reference,
    out_matrix = matrix,
    cost = "lpa+ZZ",
    .cwd = wd,
    .engine = "native"
  )
  est_args <- ni_cmd(estimate)$args
  expect_true(all(c("-cost", "lpa+ZZ", "-prefix", "NULL", "-float") %in% est_args))
  expect_equal(niflowr:::ni_norm(estimate$outputs$out_matrix),
    niflowr:::ni_norm(paste0(matrix, ".aff12.1D")))
  expect_false("out_file" %in% names(estimate$outputs))

  writeLines("1 0 0 0 0 1 0 0 0 0 1 0", paste0(matrix, ".aff12.1D"))
  apply <- ni_call(
    "afni.allineate_apply",
    in_file = source,
    in_matrix = paste0(matrix, ".aff12.1D"),
    master = reference,
    out_file = output,
    final_interpolation = "wsinc5",
    .cwd = wd,
    .engine = "native"
  )
  app_args <- ni_cmd(apply)$args
  expect_true(all(c("-1Dmatrix_apply", "-master", "-final", "wsinc5", "-float") %in% app_args))
  expect_false(any(c("-cost", "-warp", "-interp") %in% app_args))
  expect_equal(apply$spec$runtime$env$AFNI_WSINC5_SILENT, "YES")
  expect_error(ni_call("afni.allineate_apply", in_file = source,
    in_matrix = paste0(matrix, ".aff12.1D"), master = reference,
    out_file = output, cost = "lpa+ZZ"), "Unknown parameter")
  expect_error(ni_call("afni.allineate_apply", in_file = source,
    in_matrix = paste0(matrix, ".aff12.1D"), master = reference,
    out_file = output), "final_interpolation")
})

test_that("nonempty required artifacts fail after a zero-status command", {
  wd <- withr::local_tempdir()
  output <- file.path(wd, "empty.txt")
  spec <- structure(list(
    spec_version = "0.1.0",
    id = "test.empty_output",
    command = c(file.path(R.home("bin"), "Rscript"), "--vanilla", "-e",
      "file.create(commandArgs(TRUE)[1])"),
    inputs = list(out_file = list(type = "file", required = TRUE,
      role = "output", cli = list(argstr = "%s", position = -1L))),
    outputs = list(out_file = list(type = "file",
      path = list(from_input = "out_file"), must_exist = TRUE, nonempty = TRUE)),
    runtime = list()
  ), class = "ni_spec")

  error <- tryCatch(
    ni_run(ni_call(spec, out_file = output, .cwd = wd, .engine = "native"),
      echo = FALSE, provenance = FALSE),
    ni_execution_error = identity
  )
  expect_s3_class(error, "ni_execution_error")
  expect_equal(error$result$runtime$exit_status, 0L)
  expect_match(error$result$runtime$output_errors, "empty")
})

test_that("pinned AFNI executes motion, timing, and one-row 4D application", {
  afni_bin <- Sys.getenv("NIFLOWR_AFNI_BIN")
  skip_if(!nzchar(afni_bin), "Set NIFLOWR_AFNI_BIN for pinned AFNI integration")
  skip_if_not_installed("RNifti")
  for (exe in c("3dvolreg", "3dTshift", "3dAllineate")) {
    skip_if_not(file.exists(file.path(afni_bin, exe)), paste(exe, "not installed"))
  }

  wd <- withr::local_tempdir()
  grid <- array(0, c(20, 20, 12))
  grid[6:15, 6:15, 4:9] <- 4
  grid[9:12, 9:12, 6:8] <- -2
  series <- array(0, c(dim(grid), 3))
  series[,,,1] <- grid
  series[,,,2] <- grid[c(20, 1:19),,]
  series[,,,3] <- grid[,c(2:20, 1),]
  image <- RNifti::asNifti(series)
  RNifti::pixdim(image) <- c(2, 2, 2, 2)
  input <- file.path(wd, "signed-float.nii.gz")
  RNifti::writeNifti(image, input, datatype = "float")

  motion <- ni_spec_read("afni.volreg")
  motion$command <- file.path(afni_bin, "3dvolreg")
  motion_matrix <- file.path(wd, "motion.1D")
  motion_params <- file.path(wd, "motion-params.1D")
  result <- ni_run(ni_call(motion, in_file = input,
    oned_matrix_save = motion_matrix, oned_file = motion_params,
    .cwd = wd, .engine = "native"), echo = FALSE, provenance = FALSE)
  expect_true(result$runtime$success)
  expect_false(file.exists(file.path(wd, "NULL")))
  expect_gt(file.info(motion_matrix)$size, 0)
  matrix_rows <- readLines(motion_matrix)
  matrix_rows <- matrix_rows[nzchar(trimws(matrix_rows)) & !startsWith(trimws(matrix_rows), "#")]
  expect_equal(length(matrix_rows), 3)

  offsets <- c(0, 0.5, 1, 1.5)
  acquisition_times <- 2 * (0:63)
  periodic <- array(0, c(4, 4, 4, length(acquisition_times)))
  for (slice in seq_along(offsets)) {
    periodic[,,slice,] <- rep(cos(2 * pi * (acquisition_times + offsets[[slice]]) / 16),
      each = 16)
  }
  timing_image <- RNifti::asNifti(periodic)
  RNifti::pixdim(timing_image) <- c(2, 2, 2, 2)
  timing_input <- file.path(wd, "timing-input.nii.gz")
  timing_output <- file.path(wd, "timing-output.nii.gz")
  timing_file <- file.path(wd, "offsets.1D")
  RNifti::writeNifti(timing_image, timing_input, datatype = "float")
  writeLines(paste(offsets, collapse = " "), timing_file)
  tshift <- ni_spec_read("afni.t_shift")
  tshift$command <- file.path(afni_bin, "3dTshift")
  shifted <- ni_run(ni_call(tshift, in_file = timing_input,
    out_file = timing_output, slice_timing = timing_file, tr = 2,
    tzero = 0.5, ignore = 0, interp = "Fourier",
    .cwd = wd, .engine = "native"), echo = FALSE, provenance = FALSE)
  expect_true(shifted$runtime$success)
  shifted_data <- as.array(RNifti::readNifti(timing_output))
  slice_traces <- vapply(seq_along(offsets), function(slice) {
    apply(shifted_data[,,slice,,drop = FALSE], 4, mean)
  }, numeric(length(acquisition_times)))
  expected_trace <- cos(2 * pi * (acquisition_times + 0.5) / 16)
  interior <- 5:60
  expect_lt(max(apply(slice_traces[interior,,drop = FALSE], 1, stats::sd)), 0.04)
  expect_lt(max(abs(slice_traces[interior,,drop = FALSE] - expected_trace[interior])), 0.06)
  expect_equal(slice_traces[,2], periodic[1,1,2,], tolerance = 1e-6)

  reference <- file.path(wd, "reference.nii.gz")
  RNifti::writeNifti(RNifti::asNifti(grid), reference, datatype = "float")
  estimate <- ni_spec_read("afni.allineate_estimate")
  estimate$command <- file.path(afni_bin, "3dAllineate")
  estimated_matrix <- file.path(wd, "estimated.1D")
  estimated <- ni_run(ni_call(estimate, in_file = reference,
    reference = reference, out_matrix = estimated_matrix, cost = "lpa+ZZ",
    .cwd = wd, .engine = "native"), echo = FALSE, provenance = FALSE, timeout = 60)
  expect_true(estimated$runtime$success)
  estimate_rows <- readLines(estimated_matrix)
  estimate_rows <- estimate_rows[nzchar(trimws(estimate_rows)) &
    !startsWith(trimws(estimate_rows), "#")]
  expect_length(estimate_rows, 1)

  one_matrix <- file.path(wd, "one.1D")
  writeLines("1 0 0 0 0 1 0 0 0 0 1 0", one_matrix)
  applied <- file.path(wd, "applied.nii.gz")
  application <- ni_spec_read("afni.allineate_apply")
  application$command <- file.path(afni_bin, "3dAllineate")
  result <- ni_run(ni_call(application, in_file = input,
    in_matrix = one_matrix, master = input, out_file = applied,
    final_interpolation = "linear", .cwd = wd, .engine = "native"),
    echo = FALSE, provenance = FALSE)
  expect_true(result$runtime$success)
  expect_equal(dim(RNifti::readNifti(applied)), dim(series))
})
