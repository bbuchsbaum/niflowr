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
  if (!inherits(result, "ni_result")) {
    cli::cli_abort("{.arg result} must be an {.cls ni_result}.")
  }

  if (!requireNamespace("neuroim2", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg neuroim2} is required. Install from: ~/code/neuroim2")
  }

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
#' Loads a spatial transform file using the output's declarative transform
#' metadata. The metadata records the payload kind, on-disk convention, and the
#' inputs that define its source and target image domains. This avoids guessing
#' from a `.mat` suffix or tool name, both of which are ambiguous across FSL,
#' ANTs/ITK, AFNI, and FreeSurfer.
#'
#' @param result An `ni_result` object.
#' @param output_name Name of the transform output. May be omitted when exactly
#'   one resolved output is declared as a transform.
#' @param type Optional explicit `neurotransform` type for an undeclared legacy
#'   output. Requires `output_name`; declared outputs use their spec metadata.
#' @param source_image,target_image Optional image paths overriding the source
#'   and target images named in the spec metadata. These are mainly useful for
#'   FSL matrices, whose interpretation depends on both image geometries.
#' @param source,target Optional source and target domain identifiers stored on
#'   the returned morphism. By default the corresponding image paths are used.
#' @param ... Additional arguments passed to the selected `neurotransform`
#'   reader.
#' @return A neurotransform morphism object.
#' @export
ni_read_transform <- function(result, output_name = NULL, type = NULL,
                              source_image = NULL, target_image = NULL,
                              source = NULL, target = NULL, ...) {
  if (!inherits(result, "ni_result")) {
    cli::cli_abort("{.arg result} must be an {.cls ni_result}.")
  }

  if (!requireNamespace("neurotransform", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg neurotransform} is required. Install from: ~/code/neurotransform")
  }

  context <- ni_transform_context(
    result, output_name = output_name, type = type,
    source_image = source_image, target_image = target_image
  )
  source_id <- source %||% context$source_image %||% "source"
  target_id <- target %||% context$target_image %||% "target"
  extra <- list(...)

  if (is.null(context$transform)) {
    # Dense FSL fields and FNIRT coefficient files both need image geometry.
    if (isTRUE(type %in% c("fsl", "fsl_coef"))) {
      extra <- utils::modifyList(ni_transform_geometries(context, required = TRUE), extra)
    }
    args <- c(list(
      path = context$path,
      type = type,
      source = source_id,
      target = target_id
    ), extra)
    return(do.call(neurotransform::read_transform, args))
  }

  transform <- context$transform
  if (identical(transform$kind, "affine") || identical(transform$kind, "affine_array")) {
    args <- list(
      path = context$path,
      format = transform$format,
      source = source_id,
      target = target_id
    )
    if (transform$format %in% c("fsl", "afni")) {
      geometry <- ni_transform_geometries(context, required = identical(transform$format, "fsl"))
      args <- c(args, geometry)
    }
    args <- utils::modifyList(args, extra)
    reader <- if (identical(transform$kind, "affine_array")) {
      neurotransform::read_linear_transform_array
    } else {
      neurotransform::read_linear_transform
    }
    return(do.call(reader, args))
  }

  if (transform$format %in% c("fsl", "fsl_coef")) {
    extra <- utils::modifyList(ni_transform_geometries(context, required = TRUE), extra)
  }
  args <- utils::modifyList(list(
    path = context$path,
    type = transform$format,
    source = source_id,
    target = target_id
  ), extra)
  do.call(neurotransform::read_transform, args)
}

#' Convert a declared transform output to another format
#'
#' Reads a transform with [ni_read_transform()] and writes the same geometric
#' mapping in another supported convention. Affine transforms can be converted
#' among generic text, FSL FLIRT, ITK/ANTs, AFNI, FreeSurfer LTA, and X5. Warp
#' and composite transforms can be written as X5; a single warp can also be
#' written as an ANTs-compatible NIfTI vector field.
#'
#' @inheritParams ni_read_transform
#' @param path Destination file path.
#' @param format Destination format.
#' @return `path`, invisibly.
#' @export
ni_convert_transform <- function(result, path,
                                 format = c("generic", "fsl", "itk", "afni", "lta", "x5", "ants"),
                                 output_name = NULL,
                                 source_image = NULL, target_image = NULL,
                                 source = NULL, target = NULL, ...) {
  if (!inherits(result, "ni_result")) {
    cli::cli_abort("{.arg result} must be an {.cls ni_result}.")
  }
  if (!requireNamespace("neurotransform", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg neurotransform} is required. Install from: ~/code/neurotransform")
  }
  format <- match.arg(format)

  context <- ni_transform_context(
    result, output_name = output_name,
    source_image = source_image, target_image = target_image
  )
  morphism <- ni_read_transform(
    result,
    output_name = context$output_name,
    source_image = source_image,
    target_image = target_image,
    source = source,
    target = target
  )
  extra <- list(...)

  if (inherits(morphism, "Affine3DMorphism") ||
      inherits(morphism, "LinearTransformArray")) {
    if (identical(format, "ants")) {
      cli::cli_abort(
        "Use {.val itk} to write an ANTs affine transform; {.val ants} denotes an ANTs NIfTI warp."
      )
    }
    args <- list(x = morphism, path = path, format = format)
    if (format %in% c("fsl", "afni")) {
      geometry <- ni_transform_geometries(context, required = identical(format, "fsl"))
      args <- c(args, geometry)
    }
    args <- utils::modifyList(args, extra)
    writer <- if (inherits(morphism, "LinearTransformArray")) {
      neurotransform::write_linear_transform_array
    } else {
      neurotransform::write_linear_transform
    }
    do.call(writer, args)
    return(invisible(path))
  }

  if (identical(format, "x5")) {
    do.call(neurotransform::write_transform,
            utils::modifyList(list(x = morphism, path = path, type = "x5"), extra))
    return(invisible(path))
  }
  if (identical(format, "ants") && inherits(morphism, "Warp3DMorphism")) {
    do.call(neurotransform::write_transform,
            utils::modifyList(list(x = morphism, path = path, type = "nifti"), extra))
    return(invisible(path))
  }

  cli::cli_abort(
    "Format {.val {format}} cannot represent this transform payload; use {.val x5}."
  )
}

#' Resolve transform metadata and domain images from an ni_result
#' @keywords internal
ni_transform_context <- function(result, output_name = NULL, type = NULL,
                                 source_image = NULL, target_image = NULL) {
  outputs <- ni_outputs(result)
  spec_outputs <- result$call$spec$outputs %||% list()
  declared <- intersect(
    names(outputs),
    names(Filter(function(x) !is.null(x$transform), spec_outputs))
  )

  if (is.null(output_name)) {
    if (length(declared) == 1L) {
      output_name <- declared[[1L]]
    } else if (length(declared) > 1L) {
      cli::cli_abort(c(
        "Multiple transform outputs are available; specify {.arg output_name}.",
        "i" = "Declared transforms: {.val {declared}}"
      ))
    } else {
      cli::cli_abort("No resolved output is declared as a transform in this result.")
    }
  }

  path <- outputs[[output_name]]
  if (!is.character(path) || length(path) != 1L || is.na(path) || !nzchar(path)) {
    cli::cli_abort("Output {.val {output_name}} is not a single transform file path.")
  }
  if (!file.exists(path)) {
    cli::cli_abort("Transform file does not exist: {.path {path}}")
  }

  transform <- spec_outputs[[output_name]]$transform
  if (is.null(transform) && is.null(type)) {
    cli::cli_abort(c(
      "Output {.val {output_name}} has no transform metadata.",
      "i" = "Declare output.transform in the spec or supply an explicit {.arg type}."
    ))
  }
  if (is.null(transform) && is.null(output_name)) {
    cli::cli_abort("An explicit {.arg output_name} is required for legacy transform reads.")
  }

  values <- result$call$values %||% list()
  resolve_domain <- function(override, ref) {
    if (!is.null(override)) return(ni_transform_domain_path(override, ref))
    if (is.null(ref)) return(NULL)
    ni_transform_domain_path(values[[ref]], ref)
  }
  source_ref <- transform$source %||% NULL
  target_ref <- transform$target %||% NULL

  list(
    output_name = output_name,
    path = path,
    transform = transform,
    source_image = resolve_domain(source_image, source_ref %||% "source_image"),
    target_image = resolve_domain(target_image, target_ref %||% "target_image")
  )
}

#' @keywords internal
ni_transform_domain_path <- function(value, name) {
  if (is.null(value)) return(NULL)
  value <- unlist(value, use.names = FALSE)
  value <- as.character(value)
  value <- value[!is.na(value) & nzchar(value)]
  if (!length(value)) return(NULL)
  value[[1L]]
}

#' @keywords internal
ni_transform_geometries <- function(context, required = FALSE) {
  source <- ni_transform_image_geometry(context$source_image, "source", required)
  target <- ni_transform_image_geometry(context$target_image, "target", required)
  if (is.null(source) || is.null(target)) return(list())
  list(
    source_affine = source$affine,
    target_affine = target$affine,
    source_dim = source$dim,
    target_dim = target$dim
  )
}

#' @keywords internal
ni_transform_image_geometry <- function(path, domain, required) {
  if (is.null(path) || !file.exists(path)) {
    if (isTRUE(required)) {
      cli::cli_abort(c(
        "The {domain} image is required to interpret this transform format.",
        "i" = "Resolved image: {.path {path %||% 'NULL'}}"
      ))
    }
    return(NULL)
  }
  if (!requireNamespace("neuroim2", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg neuroim2} is required to read transform image geometry.")
  }
  header <- neuroim2::read_header(path)
  dims <- dim(header)
  if (length(dims) < 3L) {
    cli::cli_abort("Image geometry has fewer than three dimensions: {.path {path}}")
  }
  list(
    affine = neuroim2::trans(header),
    dim = as.integer(dims[1:3])
  )
}
