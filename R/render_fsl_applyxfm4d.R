# Manual adapter: FSL applyxfm4D positional grammar and strict matrix inventory.
fsl_applyxfm4d_mode <- function(values) {
  directory <- !is.null(values$mat_dir)
  single <- !is.null(values$single_matrix)
  if (directory == single) {
    cli::cli_abort("Supply exactly one of mat_dir or single_matrix.",
                   class = "niflowr_applyxfm4d_error")
  }
  if (directory) "directory" else "single"
}

render_fsl_applyxfm4d <- function(call) {
  v <- call$values
  mode <- fsl_applyxfm4d_mode(v)
  list(command = call$spec$command,
       args = c(v$in_file, v$reference, strip_known_extension(v$out_file),
                if (mode == "directory") v$mat_dir else v$single_matrix,
                if (mode == "directory") "-fourdigit" else "-singlematrix"),
       stdout = NULL, stderr = NULL)
}

validate_fsl_applyxfm4d <- function(values) {
  mode <- fsl_applyxfm4d_mode(values)
  fail <- function(message) cli::cli_abort(message, class = "niflowr_applyxfm4d_error")
  if (!requireNamespace("RNifti", quietly = TRUE)) {
    fail("Install RNifti to validate the applyxfm4D source volume count.")
  }
  dims <- tryCatch(RNifti::niftiHeader(values$in_file)$dim,
    error = function(e) fail("Cannot read the applyxfm4D source NIfTI header."))
  if (length(dims) < 5L || anyNA(dims[1:5]) || dims[1] != 4L ||
      any(dims[2:5] < 1L) || dims[5] > 10000L) {
    fail("applyxfm4D requires a 4D source with 1 to 10000 volumes.")
  }
  if (mode == "directory") {
    if (!dir.exists(values$mat_dir)) fail("mat_dir must be a directory.")
    expected <- sprintf("MAT_%04d", seq_len(dims[5]) - 1L)
    actual <- list.files(values$mat_dir, all.files = TRUE, no.. = TRUE)
    missing <- setdiff(expected, actual)
    extra <- setdiff(actual, expected)
    if (length(missing) || length(extra)) {
      fail(paste0("Matrix directory must contain exactly one MAT_0000-style file per volume. ",
                  "Missing: ", paste(missing, collapse = ", "),
                  "; unexpected: ", paste(extra, collapse = ", "), "."))
    }
    matrices <- file.path(values$mat_dir, expected)
  } else {
    matrices <- values$single_matrix
  }
  for (path in matrices) {
    if (!file.exists(path) || dir.exists(path)) {
      fail(paste0("Matrix must be a regular file: ", path))
    }
    matrix <- tryCatch(as.matrix(utils::read.table(path, header = FALSE,
      colClasses = "numeric", comment.char = "", quote = "")), error = function(e) NULL)
    if (is.null(matrix) || !identical(dim(matrix), c(4L, 4L)) ||
        any(!is.finite(matrix)) || any(abs(matrix[4, ] - c(0, 0, 0, 1)) > 1e-8) ||
        abs(det(matrix[1:3, 1:3])) < .Machine$double.eps) {
      fail(paste0("Invalid finite, nonsingular 4x4 affine matrix: ", path))
    }
  }
  invisible(TRUE)
}
