#' Read an output from an ni_result as a neuroim2 object
#'
#' Loads an output file using `neuroim2::read_vol()` or `neuroim2::read_vec()`
#' based on file dimensionality.
#'
#' @param result An `ni_result` object.
#' @param output_name Name of the output to read. If `NULL`, reads the first output.
#' @param ... Additional arguments passed to the neuroim2 reader.
#' @return A neuroim2 object (`NeuroVol` or `NeuroVec`).
#' @export
ni_read_output <- function(result, output_name = NULL, ...) {
  if (!requireNamespace("neuroim2", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg neuroim2} is required. Install from: ~/code/neuroim2")
  }

  stopifnot(inherits(result, "ni_result"))

  outs <- ni_outputs(result)
  if (is.null(output_name)) {
    output_name <- names(outs)[1]
  }
  path <- outs[[output_name]]
  if (is.null(path)) {
    cli::cli_abort("Output {.val {output_name}} not found in result.")
  }
  if (!file.exists(path)) {
    cli::cli_abort("Output file does not exist: {.path {path}}")
  }

  # Try reading as a volume first; if 4D, use read_vec
  hdr <- neuroim2::read_header(path)
  ndim <- length(dim(hdr))

  if (ndim <= 3) {
    neuroim2::read_vol(path, ...)
  } else {
    neuroim2::read_vec(path, ...)
  }
}

#' Read a transform output using neurotransform
#'
#' Loads a spatial transform file from an ni_result using
#' `neurotransform::read_transform()`.
#'
#' @param result An `ni_result` object.
#' @param output_name Name of the transform output. If `NULL`, guesses from
#'   output names (looks for "warp", "affine", "matrix", "transform").
#' @param type Transform type (e.g. `"ants"`, `"fsl"`, `"freesurfer"`).
#'   If `NULL`, inferred from the spec id.
#' @param ... Additional arguments passed to `neurotransform::read_transform()`.
#' @return A neurotransform morphism object.
#' @export
ni_read_transform <- function(result, output_name = NULL, type = NULL, ...) {
  if (!requireNamespace("neurotransform", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg neurotransform} is required. Install from: ~/code/neurotransform")
  }

  stopifnot(inherits(result, "ni_result"))

  outs <- ni_outputs(result)

  if (is.null(output_name)) {
    # Try to find a transform-like output
    transform_patterns <- c("warp", "affine", "matrix", "transform", "mat")
    for (pat in transform_patterns) {
      matches <- grep(pat, names(outs), ignore.case = TRUE, value = TRUE)
      if (length(matches) > 0) {
        output_name <- matches[1]
        break
      }
    }
    if (is.null(output_name)) {
      cli::cli_abort("Could not identify a transform output. Specify {.arg output_name}.")
    }
  }

  path <- outs[[output_name]]
  if (is.null(path) || !file.exists(path)) {
    cli::cli_abort("Transform file does not exist: {.path {path %||% 'NULL'}}")
  }

  # Infer type from spec id if not provided
  if (is.null(type)) {
    spec_id <- result$spec_id
    type <- if (grepl("^fsl\\.", spec_id)) {
      "fsl"
    } else if (grepl("^ants\\.", spec_id)) {
      "ants"
    } else if (grepl("^freesurfer\\.", spec_id)) {
      "freesurfer"
    } else {
      NULL
    }
  }

  neurotransform::read_transform(path, type = type, ...)
}
