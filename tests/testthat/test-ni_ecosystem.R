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

test_that("ni_read_transform requires neurotransform package", {
  skip_if(requireNamespace("neurotransform", quietly = TRUE), "neurotransform is installed")
  result <- structure(list(
    spec_id = "fsl.flirt",
    outputs = list(out_matrix_file = "/tmp/out.mat"),
    runtime = list(), provenance = list(), call = list()
  ), class = "ni_result")
  expect_error(ni_read_transform(result), "neurotransform")
})

write_transform_test_image <- function(path, affine = diag(4), dims = c(7L, 8L, 9L)) {
  data <- array(0, dim = dims)
  space <- neuroim2::NeuroSpace(dims, trans = affine)
  neuroim2::write_vol(neuroim2::DenseNeuroVol(data, space), path, format = "nifti")
  invisible(path)
}

transform_test_result <- function(call) {
  structure(list(
    spec_id = call$spec$id,
    outputs = call$outputs,
    runtime = list(),
    provenance = list(),
    call = call
  ), class = "ni_result")
}

apply_test_affine <- function(mat, points) {
  (cbind(points, 1) %*% t(mat))[, 1:3, drop = FALSE]
}

fsl_test_scaled_vox <- function(affine, dims) {
  spacing <- sqrt(colSums(affine[1:3, 1:3, drop = FALSE]^2))
  out <- diag(c(spacing, 1))
  if (det(affine[1:3, 1:3]) > 0) {
    swap <- diag(4)
    swap[1, 1] <- -1
    swap[1, 4] <- (dims[1] - 1) * spacing[1]
    out <- swap %*% out
  }
  out
}

test_that("declared FSL affine output is read with both image geometries", {
  skip_if_not_installed("neurotransform")
  skip_if_not_installed("neuroim2")
  td <- withr::local_tempdir()
  source_path <- file.path(td, "moving.nii.gz")
  target_path <- file.path(td, "fixed.nii.gz")
  matrix_path <- file.path(td, "moving_to_fixed.mat")
  output_path <- file.path(td, "warped.nii.gz")
  source_dim <- c(7L, 8L, 9L)
  target_dim <- c(10L, 11L, 12L)
  source_affine <- diag(4)
  source_affine[1:3, 1:3] <- diag(c(2, 3, 4))
  source_affine[1:3, 4] <- c(10, -20, 5)
  target_affine <- diag(4)
  target_affine[1:3, 1:3] <- diag(c(-1.5, 2.5, 3.5))
  target_affine[1:3, 4] <- c(30, 40, -10)
  write_transform_test_image(source_path, source_affine, source_dim)
  write_transform_test_image(target_path, target_affine, target_dim)

  internal <- diag(4)
  internal[1:3, 1:3] <- matrix(c(
    1.0, 0.1, 0.0,
    0.0, 0.95, 0.1,
    0.0, 0.0, 1.05
  ), 3, byrow = TRUE)
  internal[1:3, 4] <- c(3, -4, 2)
  source_to_fsl <- fsl_test_scaled_vox(source_affine, source_dim)
  target_to_fsl <- fsl_test_scaled_vox(target_affine, target_dim)
  fsl_matrix <- target_to_fsl %*% solve(target_affine) %*%
    solve(internal) %*% source_affine %*% solve(source_to_fsl)
  write.table(fsl_matrix, matrix_path, row.names = FALSE, col.names = FALSE)

  call <- ni_call(
    "fsl.flirt", in_file = source_path, reference = target_path,
    out_file = output_path, out_matrix_file = matrix_path
  )
  morphism <- ni_read_transform(transform_test_result(call))
  points <- rbind(c(30, 40, -10), c(18, 52, 4))

  expect_true(methods::is(morphism, "Affine3DMorphism"))
  expect_equal(neurotransform::transform(morphism, points),
               apply_test_affine(internal, points), tolerance = 2e-6)
})

test_that("declared ITK, AFNI, and LTA outputs dispatch as affines", {
  skip_if_not_installed("neurotransform")
  skip_if_not_installed("neuroim2")
  td <- withr::local_tempdir()
  moving <- file.path(td, "moving.nii.gz")
  fixed <- file.path(td, "fixed.nii.gz")
  write_transform_test_image(moving)
  write_transform_test_image(fixed)

  itk_path <- file.path(td, "affine.mat")
  A_lps <- diag(3)
  translation_lps <- c(2, -3, 4)
  writeLines(c(
    "#Insight Transform File V1.0",
    "Transform: AffineTransform_double_3_3",
    paste("Parameters:", paste(c(as.numeric(t(A_lps)), translation_lps), collapse = " ")),
    "FixedParameters: 0 0 0"
  ), itk_path)
  itk_call <- ni_call(
    "ants.ai", fixed_image = fixed, moving_image = moving,
    output_transform = itk_path, .validate = FALSE
  )
  itk <- ni_read_transform(transform_test_result(itk_call))

  afni_path <- file.path(td, "affine.aff12.1D")
  afni_lps <- diag(4)
  afni_lps[1:3, 4] <- c(2, -3, 4)
  write.table(afni_lps[1:3, ], afni_path, row.names = FALSE, col.names = FALSE)
  afni_call <- ni_call(
    "afni.allineate", in_file = moving, reference = fixed,
    out_matrix = afni_path, .validate = FALSE
  )
  afni <- ni_read_transform(transform_test_result(afni_call))

  lta_path <- file.path(td, "affine.lta")
  forward_ras <- diag(4)
  forward_ras[1:3, 4] <- c(2, -3, 4)
  writeLines(c(
    "type = 1", "nxforms = 1", "mean = 0 0 0", "sigma = 1", "1 4 4",
    apply(forward_ras, 1, paste, collapse = " ")
  ), lta_path)
  lta_call <- ni_call(
    "freesurfer.mri_coreg", source_file = moving, reference_file = fixed,
    subject_id = "unused", out_lta_file = lta_path, .validate = FALSE
  )
  lta <- ni_read_transform(transform_test_result(lta_call))

  expect_true(all(vapply(list(itk, afni, lta), methods::is, logical(1), "Affine3DMorphism")))
  expect_equal(itk@matrix[1:3, 4], c(-2, 3, 4), tolerance = 1e-10)
  expect_equal(afni@matrix[1:3, 4], c(-2, 3, 4), tolerance = 1e-10)
  expect_equal(lta@matrix, solve(forward_ras), tolerance = 1e-10)
})

test_that("declared ANTs warp outputs preserve vector and domain direction", {
  skip_if_not_installed("neurotransform")
  skip_if_not_installed("neuroim2")
  td <- withr::local_tempdir()
  moving <- file.path(td, "moving.nii.gz")
  fixed <- file.path(td, "fixed.nii.gz")
  prefix <- file.path(td, "reg_")
  write_transform_test_image(moving, dims = c(5L, 5L, 5L))
  write_transform_test_image(fixed, dims = c(5L, 5L, 5L))

  call <- ni_call(
    "ants.registration_syn_quick", fixed_image = fixed,
    moving_image = moving, output_prefix = prefix, .validate = FALSE
  )
  field_lps <- array(0, dim = c(5, 5, 5, 3))
  field_lps[, , , 1] <- 1
  field_lps[, , , 2] <- 2
  field_lps[, , , 3] <- 3
  space <- neuroim2::NeuroSpace(dim(field_lps), trans = diag(4))
  for (name in c("forward_warp_field", "inverse_warp_field")) {
    neuroim2::write_vec(
      neuroim2::DenseNeuroVec(field_lps, space), call$outputs[[name]], format = "nifti"
    )
  }
  result <- transform_test_result(call)
  forward <- ni_read_transform(result, "forward_warp_field")
  inverse <- ni_read_transform(result, "inverse_warp_field")
  point <- matrix(c(2, 2, 2), nrow = 1)

  expect_true(methods::is(forward, "Warp3DMorphism"))
  expect_equal(neurotransform::transform(forward, point),
               point + matrix(c(-1, -2, 3), nrow = 1), tolerance = 1e-7)
  expect_equal(neurotransform::source_of(forward), moving)
  expect_equal(neurotransform::target_of(forward), fixed)
  expect_equal(neurotransform::source_of(inverse), fixed)
  expect_equal(neurotransform::target_of(inverse), moving)
})

test_that("ni_convert_transform preserves affine landmark mappings", {
  skip_if_not_installed("neurotransform")
  skip_if_not_installed("neuroim2")
  td <- withr::local_tempdir()
  moving <- file.path(td, "moving.nii.gz")
  fixed <- file.path(td, "fixed.nii.gz")
  source_affine <- diag(c(2, 2.5, 3, 1))
  target_affine <- diag(c(-1.5, 2, 2.5, 1))
  write_transform_test_image(moving, source_affine)
  write_transform_test_image(fixed, target_affine)

  itk_path <- file.path(td, "input.mat")
  internal <- diag(4)
  internal[1:3, 1:3] <- matrix(c(
    1.0, 0.1, 0.0,
    0.0, 0.9, 0.2,
    0.0, 0.0, 1.1
  ), 3, byrow = TRUE)
  internal[1:3, 4] <- c(2, -3, 4)
  flip <- diag(c(-1, -1, 1, 1))
  itk_lps <- flip %*% internal %*% flip
  writeLines(c(
    "#Insight Transform File V1.0",
    "Transform: AffineTransform_double_3_3",
    paste("Parameters:", paste(c(as.numeric(t(itk_lps[1:3, 1:3])), itk_lps[1:3, 4]), collapse = " ")),
    "FixedParameters: 0 0 0"
  ), itk_path)
  call <- ni_call(
    "ants.ai", fixed_image = fixed, moving_image = moving,
    output_transform = itk_path, .validate = FALSE
  )
  result <- transform_test_result(call)
  points <- rbind(c(0, 0, 0), c(8, -4, 6), c(-3, 7, 2))
  expected <- apply_test_affine(internal, points)
  formats <- c("generic", "fsl", "itk", "afni", "lta")
  if (requireNamespace("hdf5r", quietly = TRUE)) formats <- c(formats, "x5")

  for (format in formats) {
    extension <- switch(format, fsl = ".mat", itk = ".txt", afni = ".aff12.1D",
                        lta = ".lta", x5 = ".x5", ".txt")
    converted <- file.path(td, paste0("converted_", format, extension))
    expect_invisible(ni_convert_transform(result, converted, format = format))
    loaded <- neurotransform::read_linear_transform(
      converted, format = format,
      source_affine = source_affine, target_affine = target_affine,
      source_dim = c(7L, 8L, 9L), target_dim = c(7L, 8L, 9L)
    )
    expect_equal(neurotransform::transform(loaded, points), expected,
                 tolerance = 2e-6, info = format)
  }
  expect_error(
    ni_convert_transform(result, file.path(td, "wrong.nii.gz"), format = "ants"),
    "Use.*itk"
  )
})

test_that("transform selection is metadata-driven and fails on ambiguity", {
  skip_if_not_installed("neurotransform")
  td <- withr::local_tempdir()
  fixed <- file.path(td, "fixed.nii.gz")
  moving <- file.path(td, "moving.nii.gz")
  prefix <- file.path(td, "reg_")
  call <- ni_call(
    "ants.registration_syn_quick", fixed_image = fixed,
    moving_image = moving, output_prefix = prefix, .validate = FALSE
  )
  result <- transform_test_result(call)

  expect_error(ni_read_transform(result), "Multiple transform outputs")

  plain <- tempfile(fileext = ".txt")
  write.table(diag(4), plain, row.names = FALSE, col.names = FALSE)
  legacy <- structure(list(
    spec_id = "manual",
    outputs = list(matrix = plain),
    runtime = list(), provenance = list(),
    call = list(spec = list(outputs = list(matrix = list())), values = list())
  ), class = "ni_result")
  expect_error(ni_read_transform(legacy, "matrix"), "no transform metadata")
  expect_true(methods::is(
    ni_read_transform(legacy, "matrix", type = "linear"),
    "Affine3DMorphism"
  ))
})

test_that("FSL affine read reports missing geometry explicitly", {
  skip_if_not_installed("neurotransform")
  path <- tempfile(fileext = ".mat")
  write.table(diag(4), path, row.names = FALSE, col.names = FALSE)
  call <- ni_call(
    "fsl.flirt", in_file = "/missing/moving.nii.gz",
    reference = "/missing/fixed.nii.gz", out_matrix_file = path,
    .validate = FALSE
  )

  expect_error(
    ni_read_transform(transform_test_result(call)),
    "source image is required"
  )
})


test_that("FNIRT coefficient bridge passes both image geometries", {
  skip_if_not_installed("neurotransform")
  skip_if_not_installed("neuroim2")
  skip_if_not_installed("RNifti")
  fixture <- system.file("extdata", "fsl_coef_oracle", "srcright_refleft_aff",
                         package = "neurotransform")
  skip_if_not(nzchar(fixture), "neurotransform coefficient fixtures not installed")
  td <- withr::local_tempdir()
  for (name in c("source", "target", "coef", paste0("native_coord", 0:2), "native_support")) {
    file.copy(file.path(fixture, paste0(name, ".nii.gz")), td)
  }
  path <- function(name) file.path(td, paste0(name, ".nii.gz"))
  call <- ni_call("fsl.fnirt", in_file = path("source"), ref_file = path("target"),
                  fieldcoeff_file = path("coef"), .validate = FALSE)
  m <- ni_read_transform(transform_test_result(call), "fieldcoeff_file", type = "fsl_coef",
                         source_image = path("source"), target_image = path("target"))
  expect_equal(m@params$source_dim, dim(neuroim2::read_vol(path("source")))[1:3])
  expect_equal(m@params$target_dim, dim(neuroim2::read_vol(path("target")))[1:3])

  # Compare with FSL's own applywarp --warp=coef of the coordinate ramps.
  target <- neuroim2::read_vol(path("target"))
  dims <- dim(target)[1:3]
  ijk <- as.matrix(expand.grid(lapply(dims, function(n) 0:(n - 1))))
  world <- (cbind(ijk, 1) %*% t(neuroim2::trans(target)))[, 1:3]
  expected <- sapply(0:2, function(k) as.numeric(as.array(neuroim2::read_vol(path(paste0("native_coord", k))))))
  mask <- as.numeric(as.array(neuroim2::read_vol(path("native_support")))) > .999
  expect_lt(max(abs(neurotransform::transform(m, world[mask, ]) - expected[mask, ])), 1e-4)
})

test_that("dense FSL bridge passes image geometry for declared and legacy outputs", {
  skip_if_not_installed("neurotransform")
  skip_if_not_installed("neuroim2")
  td <- withr::local_tempdir()
  moving <- file.path(td, "moving.nii.gz")
  fixed <- file.path(td, "fixed.nii.gz")
  warp <- file.path(td, "warp.nii.gz")
  dims <- c(7L, 8L, 9L)
  affine <- diag(c(2, 2, 2, 1))
  write_transform_test_image(moving, affine, dims)
  write_transform_test_image(fixed, affine, dims)
  field <- array(0, c(dims, 3L))
  field[, , , 1] <- 1
  neuroim2::write_vec(neuroim2::DenseNeuroVec(
    field, neuroim2::NeuroSpace(dim(field), trans = affine)), warp, format = "nifti")
  call <- ni_call("fsl.fnirt", in_file = moving, ref_file = fixed,
                  field_file = warp, .validate = FALSE)
  result <- transform_test_result(call)
  legacy <- ni_read_transform(result, "field_file", type = "fsl",
                              source_image = moving, target_image = fixed)
  result$call$spec$outputs$field_file$transform <- list(
    kind = "warp", format = "fsl", source = "in_file", target = "ref_file")
  declared <- ni_read_transform(result, "field_file")
  point <- matrix(c(6, 6, 6), nrow = 1)
  for (m in list(legacy, declared)) {
    expect_equal(m@params$source_dim, dims)
    expect_equal(m@params$target_dim, dims)
    expect_equal(neurotransform::transform(m, point), matrix(c(5, 6, 6), nrow = 1),
                 tolerance = 1e-7)
  }
})
