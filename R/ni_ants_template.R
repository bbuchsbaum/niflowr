# Documented T1w-to-template registration presets and registration QA.
#
# Presets are pinned JSON in inst/presets/ants_registration/ so their schedule,
# provenance, and cost are inspectable data rather than code.

#' Read a pinned T1w-to-template registration preset
#'
#' Presets are complete `ants.registration` schedules stored with their
#' provenance and cost.
#'
#' * `"precise"`: the schedule measured in niflowr issue #29 against fMRIPrep
#'   25.x's T1w-to-MNI152NLin2009cAsym transform, which it matched within noise
#'   on two participants (about 17 min with 8 threads at 1 mm). Tuned for a
#'   brain-extracted T1w to a brain-extracted T1w template at about 1 mm; not
#'   for EPI-to-T1w, low-resolution, or non-brain data.
#' * `"testing"`: the same stage structure with a handful of iterations, for
#'   exercising pipelines. Deliberately under-converged; never analyse its
#'   transforms.
#'
#' @param preset Preset name: `"precise"` or `"testing"`.
#' @return A list with `name`, `title`, `intended_for`, `provenance`, `cost`,
#'   and `values` (the `ants.registration` inputs, without images or output
#'   paths).
#' @seealso [ni_ants_register_to_template()], [ni_ants_registration_qa()]
#' @export
#' @examples
#' preset <- ni_ants_template_preset("precise")
#' preset$cost
#' preset$values$number_of_iterations
ni_ants_template_preset <- function(preset = c("precise", "testing")) {
  preset <- match.arg(preset)
  path <- system.file(
    "presets", "ants_registration", paste0("t1w-template_", preset, ".json"),
    package = "niflowr"
  )
  if (!nzchar(path)) {
    cli::cli_abort("Registration preset {.val {preset}} is not installed.")
  }
  jsonlite::read_json(path, simplifyVector = FALSE)
}

#' Register a T1w image to a T1w template with a pinned preset
#'
#' Runs `antsRegistration` (Rigid, Affine, then SyN) with a schedule from
#' [ni_ants_template_preset()], writing the moving image resampled into the
#' template and the ITK composite transforms (`<prefix>Composite.h5` and
#' `<prefix>InverseComposite.h5`), the form fMRIPrep writes.
#'
#' This is a named preset, not the default of [ni_ants_registration()]: the
#' `"precise"` schedule is tuned for about 1 mm T1w-to-template registration
#' and is the wrong schedule for other modalities or resolutions. A
#' registration can run, write a transform, and not fold while still stopping
#' at a poor optimum, so check it with [ni_ants_registration_qa()].
#'
#' @param fixed_image The template (reference) image, usually brain-extracted.
#' @param moving_image The T1w image to register, brain-extracted like the
#'   template.
#' @param output_prefix Path prefix for the transforms and the warped image
#'   (`<prefix>Warped.nii.gz`).
#' @param preset Preset name; see [ni_ants_template_preset()].
#' @param ... Named `ants.registration` inputs that replace preset values
#'   whole, e.g. `random_seed = 1` or `fixed_image_mask = "mask.nii.gz"`.
#'   `NULL` removes a preset value. Related values are not adjusted: replacing
#'   `metric` keeps the preset's `radius_or_number_of_bins`. Giving
#'   `initial_moving_transform` drops the preset's
#'   `initial_moving_transform_com`, since only one initialisation applies.
#' @param timeout Seconds before the registration is stopped.
#' @inheritParams ni_ants_registration
#' @return An `ni_result` (or an execution plan when `dry_run = TRUE`).
#' @seealso [ni_ants_registration_qa()]
#' @export
#' @examples
#' \dontrun{
#' reg <- ni_ants_register_to_template(
#'   fixed_image = "/data/tpl-MNI152NLin2009cAsym_res-01_desc-brain_T1w.nii.gz",
#'   moving_image = "/data/sub-01_desc-brain_T1w.nii.gz",
#'   output_prefix = "/data/out/sub-01_from-T1w_to-MNI_"
#' )
#' ni_ants_registration_qa(reg,
#'   fixed_mask = "/data/tpl-MNI152NLin2009cAsym_res-01_desc-brain_mask.nii.gz",
#'   moving_mask = "/data/sub-01_desc-brain_mask.nii.gz"
#' )
#' }
ni_ants_register_to_template <- function(fixed_image, moving_image, output_prefix,
                                         preset = c("precise", "testing"), ...,
                                         .cwd = NULL, .env = NULL, .engine = NULL,
                                         .profile = NULL, timeout = Inf,
                                         dry_run = FALSE, echo = interactive()) {
  preset <- match.arg(preset)
  overrides <- list(...)
  if (length(overrides) > 0L && (is.null(names(overrides)) || any(!nzchar(names(overrides))))) {
    cli::cli_abort("Preset overrides in {.arg ...} must be named {.val ants.registration} inputs.")
  }
  owned <- c("fixed_image", "moving_image", "output_transform_prefix", "output_warped_image")
  if (any(names(overrides) %in% owned)) {
    cli::cli_abort(c(
      "{.arg {intersect(names(overrides), owned)}} {?is/are} set by the images and {.arg output_prefix}.",
      "i" = "Use {.fn ni_ants_registration} for other layouts."
    ))
  }
  # Replace whole values: modifyList() would recurse into the unnamed
  # per-stage lists and silently keep the preset's entries.
  values <- ni_ants_template_preset(preset)$values
  if ("initial_moving_transform" %in% names(overrides) &&
      !"initial_moving_transform_com" %in% names(overrides)) {
    values["initial_moving_transform_com"] <- list(NULL)
  }
  for (nm in names(overrides)) values[nm] <- list(overrides[[nm]])

  call <- do.call(ni_call, c(
    list(
      "ants.registration",
      fixed_image = fixed_image,
      moving_image = moving_image,
      output_transform_prefix = output_prefix,
      output_warped_image = paste0(output_prefix, "Warped.nii.gz")
    ),
    values,
    list(.cwd = .cwd, .env = .env, .engine = .engine, .profile = .profile)
  ))
  ni_run(call, dry_run = dry_run, echo = echo, timeout = timeout)
}

#' Measure how well a registration aligned
#'
#' A registration can run, write a transform, and not fold while stopping at a
#' poor optimum. This reports the evidence that separates the two: image
#' similarity between the template and the moving image warped into it,
#' overlap of warped masks or labels, and the Jacobian determinant of the
#' transform. All image work runs through ANTs (`antsApplyTransforms`,
#' `MeasureImageSimilarity`, `CreateJacobianDeterminantImage`) on the same
#' engine as the registration.
#'
#' The moving image is always re-warped here with `interpolation`, so scores
#' are comparable between registrations (for example niflowr's and fMRIPrep's
#' transforms) only with the same images, mask, interpolation, and metric
#' parameters. Similarity values are ANTs metric costs, so **lower is better**;
#' they are computed densely (no sampling), so they are deterministic. Dice is
#' overlap, so higher is better. A non-positive Jacobian determinant marks
#' folding.
#'
#' Each call writes its images to a new directory inside `out_dir`, so QA can
#' be re-run. Relative paths are resolved against the R working directory.
#'
#' @param registration An `ni_result` from [ni_ants_register_to_template()] or
#'   [ni_ants_registration()] run with `write_composite_transform = TRUE`.
#'   Supplies the images, transform, engine, and profile not given explicitly.
#' @param fixed_image,moving_image The template and the registered image. For
#'   multi-channel registrations the first channel is used.
#' @param transform The transform that resamples the moving image into template
#'   space: a composite `.h5`, or several files in `antsApplyTransforms` order
#'   (e.g. `c("x_1Warp.nii.gz", "x_0GenericAffine.mat")`).
#' @param fixed_mask,moving_mask Brain masks. `fixed_mask` limits the
#'   similarity metrics and the Jacobian summary; with both, the warped moving
#'   mask's Dice with `fixed_mask` is reported.
#' @param fixed_labels,moving_labels Label images; with both, per-label Dice
#'   after warping `moving_labels` with `GenericLabel` interpolation.
#' @param similarity Named numeric vector of metrics to compute, each with its
#'   bins (MI, Mattes) or radius (CC, others).
#' @param interpolation Interpolation for the warped moving image.
#' @param jacobian Whether to compute the Jacobian determinant summary.
#' @param keep_field Whether to keep the composed displacement field (large at
#'   1 mm) after computing the Jacobian.
#' @param out_dir Directory in which each call creates its QA directory.
#'   Defaults to the transform's directory; set it to keep QA files out of a
#'   derivatives tree. Must be reachable by the engine (a mapped root for
#'   containers).
#' @param .engine,.profile Execution engine and runtime profile; default to
#'   the registration's.
#' @param timeout Seconds before each ANTs step is stopped.
#' @param echo Whether to echo tool output.
#' @return An `ni_registration_qa` object: a list with `similarity` (data
#'   frame), `mask_dice` (`NA` without both masks), `label_dice` (data frame,
#'   or `NULL` without both label images), `jacobian` (summary list, or `NULL`
#'   when `jacobian = FALSE`), and `files`.
#' @seealso [ni_ants_register_to_template()]
#' @export
ni_ants_registration_qa <- function(registration = NULL, fixed_image = NULL,
                                    moving_image = NULL, transform = NULL,
                                    fixed_mask = NULL, moving_mask = NULL,
                                    fixed_labels = NULL, moving_labels = NULL,
                                    similarity = c(MI = 32, CC = 4),
                                    interpolation = "Linear", jacobian = TRUE,
                                    keep_field = FALSE, out_dir = NULL,
                                    .engine = NULL, .profile = NULL,
                                    timeout = Inf, echo = FALSE) {
  if (!is.null(registration)) {
    if (!inherits(registration, "ni_result")) {
      cli::cli_abort("{.arg registration} must be an {.cls ni_result} (not a dry-run plan).")
    }
    values <- registration$call$values
    fixed_image <- fixed_image %||% ants_as_vec(values[["fixed_image"]])[1]
    moving_image <- moving_image %||% ants_as_vec(values[["moving_image"]])[1]
    transform <- transform %||% registration$outputs[["composite_transform"]]
    .engine <- .engine %||% registration$runtime$engine
    .profile <- .profile %||% registration$runtime$profile
  }
  if (is.null(transform)) {
    cli::cli_abort(c(
      "{.arg transform} is required.",
      "i" = "Pass it, or a {.arg registration} run with {.code write_composite_transform = TRUE}."
    ))
  }
  if (length(similarity) > 0L &&
      (is.null(names(similarity)) || any(!nzchar(names(similarity))) || anyDuplicated(names(similarity)))) {
    cli::cli_abort("{.arg similarity} must have unique metric names, e.g. {.code c(MI = 32, CC = 4)}.")
  }
  needs_images <- isTRUE(jacobian) || !is.null(moving_mask) || !is.null(moving_labels)
  if (needs_images && !requireNamespace("RNifti", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg RNifti} is required for Dice and Jacobian summaries.")
  }

  # Resolve every path here: engines resolve relative paths against their own
  # working directory, and a mask ANTs cannot find is silently ignored.
  existing <- function(x, name, required = TRUE) {
    if (is.null(x)) {
      if (required) cli::cli_abort("{.arg {name}} is required.")
      return(NULL)
    }
    x <- as.character(fs::path_abs(as.character(x)))
    missing <- x[!file.exists(x)]
    if (length(missing)) cli::cli_abort("{.arg {name}} does not exist: {.path {missing}}")
    x
  }
  fixed_image <- existing(fixed_image, "fixed_image")
  moving_image <- existing(moving_image, "moving_image")
  transform <- existing(transform, "transform")
  fixed_mask <- existing(fixed_mask, "fixed_mask", FALSE)
  moving_mask <- existing(moving_mask, "moving_mask", FALSE)
  fixed_labels <- existing(fixed_labels, "fixed_labels", FALSE)
  moving_labels <- existing(moving_labels, "moving_labels", FALSE)
  for (nm in c("fixed_image", "moving_image", "fixed_mask", "moving_mask", "fixed_labels", "moving_labels")) {
    if (length(get(nm)) > 1L) cli::cli_abort("{.arg {nm}} must be a single image.")
  }

  stem <- sub("Composite\\.h5$", "", basename(transform[[1]]))
  if (identical(stem, basename(transform[[1]]))) stem <- paste0(sub("\\.[^.]*(\\.gz)?$", "", stem), "_")
  out_dir <- as.character(fs::path_abs(out_dir %||% dirname(transform[[1]])))
  fs::dir_create(out_dir)
  # A new directory per call: ANTs rewrites identical bytes on a re-run, which
  # ni_run() rejects as an unchanged pre-existing output.
  qa_dir <- tempfile(pattern = paste0(stem, "qa-"), tmpdir = out_dir)
  fs::dir_create(qa_dir)
  qa_path <- function(what) file.path(qa_dir, what)
  run <- function(spec_id, ...) {
    ni_run(ni_call(spec_id, ..., .engine = .engine, .profile = .profile),
      echo = echo, timeout = timeout)
  }
  warp <- function(input, output, interp) {
    run("ants.apply_transforms", dimension = 3, input_image = input,
      reference_image = fixed_image, transforms = transform,
      interpolation = interp, output_image = output)
    output
  }
  files <- list(qa_dir = qa_dir)

  files$warped_image <- warp(moving_image, qa_path("warped.nii.gz"), interpolation)
  values <- vapply(names(similarity), function(metric) {
    res <- run("ants.measure_image_similarity", dimension = 3,
      fixed_image = fixed_image, moving_image = files$warped_image, metric = metric,
      radius_or_number_of_bins = as.integer(similarity[[metric]]),
      fixed_image_mask = fixed_mask)
    ni_parse_similarity(res$runtime$stdout, metric)
  }, numeric(1))
  similarity_table <- data.frame(
    metric = names(similarity),
    parameter = unname(as.numeric(similarity)),
    value = unname(values),
    better = rep("lower", length(similarity)),
    masked = rep(!is.null(fixed_mask), length(similarity)),
    interpolation = rep(interpolation, length(similarity)),
    stringsAsFactors = FALSE
  )

  mask_dice <- NA_real_
  if (!is.null(fixed_mask) && !is.null(moving_mask)) {
    files$warped_mask <- warp(moving_mask, qa_path("mask.nii.gz"), "NearestNeighbor")
    mask_dice <- ni_dice(ni_read_nifti(fixed_mask) > 0, ni_read_nifti(files$warped_mask) > 0)
  }

  label_dice <- NULL
  if (!is.null(fixed_labels) && !is.null(moving_labels)) {
    files$warped_labels <- warp(moving_labels, qa_path("labels.nii.gz"), "GenericLabel")
    label_dice <- ni_label_dice(ni_read_nifti(fixed_labels), ni_read_nifti(files$warped_labels))
  }

  jacobian_summary <- NULL
  if (isTRUE(jacobian)) {
    field <- qa_path("field.nii.gz")
    run("ants.apply_transforms", dimension = 3, reference_image = fixed_image,
      transforms = transform, print_out_composite_warp_file = TRUE, output_image = field)
    files$jacobian <- qa_path("jacobian.nii.gz")
    run("ants.create_jacobian_determinant_image", imageDimension = 3,
      deformationField = field, outputImage = files$jacobian,
      doLogJacobian = 0, useGeometric = 0)
    if (isTRUE(keep_field)) files$displacement_field <- field else unlink(field)
    region <- if (!is.null(fixed_mask)) ni_read_nifti(fixed_mask) > 0
    jacobian_summary <- ni_jacobian_summary(ni_read_nifti(files$jacobian), region)
  }

  structure(list(
    similarity = similarity_table,
    mask_dice = mask_dice,
    label_dice = label_dice,
    jacobian = jacobian_summary,
    files = files
  ), class = "ni_registration_qa")
}

#' @export
print.ni_registration_qa <- function(x, ...) {
  cli::cli_text("{.strong Registration QA}")
  if (nrow(x$similarity) > 0L) {
    where <- if (any(x$similarity$masked)) " inside the fixed mask" else ""
    cli::cli_text(
      "Similarity (ANTs cost, lower is better{where}; {x$similarity$interpolation[1]} warp):"
    )
    for (i in seq_len(nrow(x$similarity))) {
      s <- x$similarity[i, ]
      cli::cli_text("  {s$metric} ({s$parameter}): {format(s$value, digits = 6)}")
    }
  }
  if (!is.na(x$mask_dice)) {
    cli::cli_text("Brain-mask Dice: {format(x$mask_dice, digits = 5)}")
  }
  if (!is.null(x$label_dice)) {
    cli::cli_text(
      "Label Dice: mean {format(mean(x$label_dice$dice), digits = 4)} over {nrow(x$label_dice)} label{?s}"
    )
  }
  if (!is.null(j <- x$jacobian)) {
    cli::cli_text(
      "Jacobian determinant ({j$region}): min {format(j$min, digits = 4)}, \\
       max {format(j$max, digits = 4)}; {j$n_nonpositive} non-positive, \\
       {j$n_nonfinite} non-finite of {j$n_voxels} voxel{?s}"
    )
  }
  invisible(x)
}

#' Parse MeasureImageSimilarity's value from stdout
#' @keywords internal
ni_parse_similarity <- function(stdout, metric) {
  lines <- trimws(strsplit(paste(stdout, collapse = "\n"), "\n", fixed = TRUE)[[1]])
  lines <- lines[nzchar(lines)]
  value <- if (length(lines) > 0L) suppressWarnings(as.numeric(lines[[length(lines)]])) else NA_real_
  if (length(value) != 1L || !is.finite(value)) {
    cli::cli_abort(c(
      "Could not read the {metric} value from MeasureImageSimilarity.",
      "i" = "Output was: {.val {paste(lines, collapse = ' ')}}"
    ))
  }
  value
}

#' Read a NIfTI image as an array that keeps its voxel-to-world transform
#' @keywords internal
ni_read_nifti <- function(path) {
  img <- RNifti::readNifti(path)
  out <- as.array(img)
  attr(out, "xform") <- unclass(RNifti::xform(img))
  out
}

#' Stop unless two images share dimensions and voxel-to-world transform
#' @keywords internal
ni_check_same_grid <- function(a, b, what = "Images") {
  same_dim <- identical(dim(a)[1:3], dim(b)[1:3])
  xa <- attr(a, "xform")
  xb <- attr(b, "xform")
  same_xform <- is.null(xa) || is.null(xb) ||
    isTRUE(all.equal(as.vector(xa), as.vector(xb), tolerance = 1e-4, check.attributes = FALSE))
  if (!same_dim || !same_xform) {
    cli::cli_abort(c(
      "{what} are on different grids.",
      "i" = "Dimensions {.val {dim(a)}} vs {.val {dim(b)}}; resample onto the fixed image first."
    ))
  }
  invisible(TRUE)
}

#' Dice overlap of two logical masks on the same grid
#' @keywords internal
ni_dice <- function(a, b) {
  ni_check_same_grid(a, b, "Masks")
  total <- sum(a) + sum(b)
  if (total == 0) return(NA_real_)
  2 * sum(a & b) / total
}

#' Per-label Dice for two label images on the same grid (label 0 is background)
#' @keywords internal
ni_label_dice <- function(fixed, moving) {
  ni_check_same_grid(fixed, moving, "Label images")
  labels <- sort(setdiff(union(unique(as.vector(fixed)), unique(as.vector(moving))), 0))
  data.frame(
    label = labels,
    dice = vapply(labels, function(l) ni_dice(fixed == l, moving == l), numeric(1)),
    stringsAsFactors = FALSE
  )
}

#' Summarise a Jacobian determinant image, optionally inside a region
#' @keywords internal
ni_jacobian_summary <- function(jac, region = NULL) {
  if (!is.null(region)) ni_check_same_grid(jac, region, "The Jacobian and the fixed mask")
  values <- if (is.null(region)) as.vector(jac) else as.vector(jac[region])
  finite <- values[is.finite(values)]
  list(
    region = if (is.null(region)) "whole image" else "fixed mask",
    n_voxels = length(values),
    min = if (length(finite)) min(finite) else NA_real_,
    max = if (length(finite)) max(finite) else NA_real_,
    median = if (length(finite)) stats::median(finite) else NA_real_,
    n_nonpositive = sum(finite <= 0),
    n_nonfinite = sum(!is.finite(values))
  )
}
