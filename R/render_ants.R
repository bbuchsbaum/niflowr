# Custom argument-vector renderers for ANTs commands whose CLI grammar cannot
# be expressed by the generic per-input argstr loop in build_command().
#
# antsRegistration takes repeated, order-sensitive stage groups
# (--transform / --metric[fixed,moving,...] / --convergence / --shrink-factors /
# --smoothing-sigmas), which the flat Nipype-imported spec cannot describe. These
# renderers build a runnable, canonical argument vector instead.

#' Dispatch a spec's declared custom renderer
#'
#' @param name Renderer name from `spec$render`.
#' @param call An `ni_call` object.
#' @return A list with `command`, `args`, `stdout`, `stderr`.
#' @keywords internal
dispatch_custom_render <- function(name, call) {
  fn <- switch(name,
    ants_registration_staged = render_ants_registration,
    ants_transform_build = render_ants_transform_build,
    ants_apply_transforms = render_ants_apply_transforms,
    ants_measure_image_similarity = render_ants_measure_image_similarity,
    ants_n4 = render_ants_n4,
    fsl_fast = render_fsl_fast,
    NULL
  )
  if (is.null(fn)) {
    cli::cli_abort(c(
      "Unknown custom renderer {.val {name}}.",
      "i" = "Declared in spec {.val {call$spec$id}}."
    ))
  }
  fn(call)
}

# ---- shared helpers ---------------------------------------------------------

#' @keywords internal
ants_as_vec <- function(x) {
  if (is.null(x)) return(character(0))
  unlist(x, use.names = FALSE)
}

#' Per-stage values for a staged antsRegistration input
#'
#' Returns a list with one element per stage. Each element is an atomic
#' vector: a single value, or several (the metrics of a multi-metric stage, or
#' the levels of an iteration ladder). A single element applies to every stage.
#' Any other length is a mis-specified stage list, so it is an error rather
#' than silently wrapped around onto the wrong stages.
#' @param allow_missing Whether `NULL`/`NA` entries are allowed (they mean
#'   "omit" for optional per-metric settings such as sampling).
#' @keywords internal
ants_stage_values <- function(x, name, n_stages, allow_missing = FALSE) {
  if (is.null(x)) return(NULL)
  items <- ni_nested_items(x)
  if (length(items) == 0L) return(NULL)
  if (!allow_missing &&
      any(vapply(items, function(e) length(e) == 0L || anyNA(e), logical(1)))) {
    cli::cli_abort("{.arg {name}} contains missing values.")
  }
  if (length(items) == 1L) return(rep(items, n_stages))
  if (length(items) != n_stages) {
    cli::cli_abort(c(
      "{.arg {name}} has {length(items)} value{?s}, but the call has {n_stages} stage{?s}.",
      "i" = "Give one value per stage, or a single value for all stages.",
      "i" = "Pass a list with one element per stage; a stage with several values \\
             is a vector inside it, e.g. {.code list(0.1, 0.1, c(0.1, 3, 0))}."
    ))
  }
  items
}

#' Recycle a stage's per-metric setting across its `k` metrics
#' @keywords internal
ants_per_metric <- function(x, name, k, stage) {
  if (length(x) == 0L) return(rep(NA, k))
  if (length(x) == 1L) return(rep(x, k))
  if (length(x) != k) {
    cli::cli_abort(
      "Stage {stage}: {.arg {name}} has {length(x)} values for {k} metric{?s}."
    )
  }
  x
}

#' Format CLI numbers without scientific notation (ANTs reads "1e+05" as 1)
#' @keywords internal
ants_num <- function(x) {
  if (is.null(x)) return(NULL)
  if (!is.numeric(x)) return(as.character(x))
  vapply(x, function(e) format(e, scientific = FALSE, trim = TRUE, digits = 15), character(1),
    USE.NAMES = FALSE)
}

#' Join a stage's values into one ANTs token ("100x70x50", "0.1,3,0")
#' @keywords internal
ants_join <- function(x, sep) {
  if (is.null(x)) return(NULL)
  paste(ants_num(x), collapse = sep)
}

#' @keywords internal
ants_given <- function(x) {
  !is.null(x) && !(length(x) == 1L && (is.na(x) || !nzchar(as.character(x))))
}

#' Image for metric `j` of a stage: images pair with the metrics within a
#' stage (as in nipype), with a single image shared by every metric
#' @keywords internal
ants_channel_images <- function(x, name, max_metrics) {
  x <- as.character(ants_as_vec(x))
  if (length(x) > 1L && length(x) != max_metrics) {
    cli::cli_abort(c(
      "{.arg {name}} has {length(x)} images but the stage with the most metrics has {max_metrics}.",
      "i" = "Images pair with the metrics within a stage (image j serves metric j), \\
             not with stages. Give one image, or one per metric."
    ))
  }
  x
}

#' Default gradient step parameters for an ANTs transform
#' @keywords internal
ants_default_transform_params <- function(transform) {
  deformable <- c(
    "SyN", "BSplineSyN", "TimeVaryingVelocityField",
    "TimeVaryingBSplineVelocityField", "GaussianDisplacementField",
    "BSplineDisplacementField", "Exponential", "BSplineExponential"
  )
  if (transform %in% deformable) "0.1,3,0" else "0.1"
}

#' Default metric radius / number-of-bins for an ANTs metric
#' @keywords internal
ants_default_metric_bins <- function(metric) {
  switch(metric,
    CC = "4",
    GC = "1",
    "32"
  )
}

#' Build a per-level iteration ladder matching a stage's level count
#' @keywords internal
ants_default_convergence_iters <- function(n_levels) {
  if (is.na(n_levels) || n_levels < 1) n_levels <- 1L
  ladder <- c(1000, 500, 250, 100, 50, 25)
  idx <- pmin(seq_len(n_levels), length(ladder))
  paste(ladder[idx], collapse = "x")
}

#' Number of multiresolution levels encoded in an "8x4x2x1"-style string
#' @keywords internal
ants_n_levels <- function(factor_string) {
  if (is.null(factor_string) || is.na(factor_string)) return(1L)
  length(strsplit(as.character(factor_string), "x", fixed = TRUE)[[1]])
}

#' @keywords internal
ants_metric_token <- function(metric, fixed, moving, weight, bins,
                              sampling = NULL, percentage = NULL) {
  parts <- c(fixed, moving, weight, bins)
  if (!is.null(sampling)) parts <- c(parts, sampling)
  if (!is.null(percentage)) parts <- c(parts, percentage)
  sprintf("%s[%s]", metric, paste(parts, collapse = ","))
}

#' @keywords internal
ants_convergence_token <- function(iters, threshold = "1e-6", window = "10") {
  sprintf("[%s,%s,%s]", iters, threshold, window)
}

#' Assemble the final argument vector from global + ordered stage groups
#' @keywords internal
render_ants_registration_core <- function(command, pre_stage, stages, post_stage) {
  stage_args <- character(0)
  for (s in stages) {
    stage_args <- c(
      stage_args,
      "--transform", s$transform,
      as.vector(rbind("--metric", s$metric)),
      "--convergence", s$convergence,
      "--shrink-factors", s$shrink,
      "--smoothing-sigmas", s$smoothing
    )
  }
  args <- c(pre_stage, stage_args, post_stage)
  args <- args[!is.na(args)]
  list(
    command = command,
    args = unname(args),
    stdout = NULL,
    stderr = NULL
  )
}

#' @keywords internal
ants_bool01 <- function(x) {
  if (is.null(x)) return(NULL)
  if (is.logical(x)) return(if (isTRUE(x)) "1" else "0")
  as.character(as.integer(as.numeric(x)))
}

# ---- #3: staged antsRegistration -------------------------------------------

#' Render a staged antsRegistration command (renderer: ants_registration_staged)
#' @keywords internal
render_ants_registration <- function(call) {
  spec <- call$spec
  v <- call$values
  vd <- apply_spec_defaults(spec, v)

  command <- spec$command
  if (is.list(command)) command <- unlist(command)
  command <- command[[1]]

  transforms <- as.character(ants_as_vec(v[["transforms"]]))
  n_stages <- length(transforms)
  if (n_stages == 0L) {
    cli::cli_abort("{.arg transforms} must name at least one registration stage.")
  }
  stage <- function(name, value = v[[name]], allow_missing = FALSE) {
    ants_stage_values(value, name, n_stages, allow_missing)
  }
  metrics <- stage("metric", v[["metric"]] %||% "MI")
  if (is.null(metrics)) {
    cli::cli_abort("{.arg metric} must name at least one metric per stage.")
  }
  weights <- stage("metric_weight", v[["metric_weight"]] %||% vd[["metric_weight"]])
  bins <- stage("radius_or_number_of_bins")
  sampling <- stage("sampling_strategy", allow_missing = TRUE)
  percentages <- stage("sampling_percentage", allow_missing = TRUE)
  shrink <- stage("shrink_factors")
  smooth <- stage("smoothing_sigmas")
  units <- stage("sigma_units")
  params <- stage("transform_parameters")
  iterations <- stage("number_of_iterations")
  thresholds <- stage("convergence_threshold")
  windows <- stage("convergence_window_size")

  max_metrics <- max(lengths(metrics))
  fixed <- ants_channel_images(v[["fixed_image"]], "fixed_image", max_metrics)
  moving <- ants_channel_images(v[["moving_image"]], "moving_image", max_metrics)
  channel <- function(images, j) images[[if (length(images) == 1L) 1L else j]]

  # ---- global flags before stages ----
  prefix <- vd[["output_transform_prefix"]] %||% "transform"
  output <- prefix
  if (ants_given(v[["output_warped_image"]])) {
    inverse <- if (ants_given(v[["output_inverse_warped_image"]])) v[["output_inverse_warped_image"]]
    output <- sprintf("[%s]", paste(c(prefix, v[["output_warped_image"]], inverse), collapse = ","))
  } else if (ants_given(v[["output_inverse_warped_image"]])) {
    cli::cli_abort("{.arg output_inverse_warped_image} requires {.arg output_warped_image}.")
  }
  pre <- c("--dimensionality", as.character(vd[["dimension"]] %||% 3))
  pre <- c(pre, "--output", output)
  pre <- c(pre, "--interpolation", as.character(vd[["interpolation"]] %||% "Linear"))

  # [0,1] is antsRegistration's own no-op default, so only emit a real clip.
  lo <- as.numeric(vd[["winsorize_lower_quantile"]] %||% 0)
  hi <- as.numeric(vd[["winsorize_upper_quantile"]] %||% 1)
  if (!(lo >= 0 && hi <= 1 && lo < hi)) {
    cli::cli_abort(
      "Winsorize quantiles must satisfy 0 <= lower < upper <= 1, got [{lo}, {hi}]."
    )
  }
  if (lo > 0 || hi < 1) {
    pre <- c(pre, "--winsorize-image-intensities", sprintf("[%s,%s]", ants_num(lo), ants_num(hi)))
  }

  collapse <- ants_bool01(vd[["collapse_output_transforms"]])
  if (!is.null(collapse)) pre <- c(pre, "--collapse-output-transforms", collapse)

  # antsRegistration honours only the last --use-histogram-matching and applies
  # it to every stage, so this is one global setting, not a per-stage one.
  histogram <- ants_bool01(v[["use_histogram_matching"]])
  if (!is.null(histogram)) pre <- c(pre, "--use-histogram-matching", histogram)

  if (isTRUE(vd[["initialize_transforms_per_stage"]])) {
    pre <- c(pre, "--initialize-transforms-per-stage", "1")
  }

  imt <- ants_as_vec(v[["initial_moving_transform"]])
  if (length(imt) > 0) {
    for (t in imt) pre <- c(pre, "--initial-moving-transform", t)
  } else if (!is.null(v[["initial_moving_transform_com"]]) && length(fixed) > 0 && length(moving) > 0) {
    pre <- c(pre, "--initial-moving-transform",
      sprintf("[%s,%s,%s]", fixed[[1]], moving[[1]],
        as.character(v[["initial_moving_transform_com"]])))
  }

  if (!is.null(v[["fixed_image_mask"]])) {
    pre <- c(pre, "--masks", sprintf("[%s]", v[["fixed_image_mask"]]))
  }

  if (!is.null(v[["restore_state"]])) {
    pre <- c(pre, "--restore-state", as.character(v[["restore_state"]]))
  }
  if (!is.null(v[["save_state"]])) {
    pre <- c(pre, "--save-state", as.character(v[["save_state"]]))
  }

  # ---- per-stage groups ----
  pick <- function(x, i) if (is.null(x)) NULL else x[[i]]
  stages <- vector("list", n_stages)
  for (i in seq_len(n_stages)) {
    tname <- transforms[[i]]
    tparams <- pick(params, i)
    if (grepl("[", tname, fixed = TRUE)) {
      if (!is.null(tparams)) {
        cli::cli_abort(c(
          "Stage {i}: transform {.val {tname}} already carries its parameters.",
          "i" = "Use a bare transform name with {.arg transform_parameters}, or bracketed parameters alone."
        ))
      }
      transform <- tname
    } else {
      transform <- sprintf("%s[%s]", tname,
        ants_join(tparams %||% ants_default_transform_params(tname), ","))
    }

    # One --metric per metric of the stage; the stage's images, weights, bins,
    # and sampling pair with its metrics position by position.
    mnames <- as.character(metrics[[i]])
    k <- length(mnames)
    w <- ants_per_metric(pick(weights, i) %||% 1, "metric_weight", k, i)
    bi <- pick(bins, i)
    # Bins (MI/Mattes) and radius (CC) mean different things, so one value is
    # only shared across metrics of one type.
    if (length(bi) == 1L && k > 1L && length(unique(mnames)) > 1L) {
      cli::cli_abort(c(
        "Stage {i}: one {.arg radius_or_number_of_bins} value cannot serve metrics {.val {mnames}}.",
        "i" = "Give one value per metric, e.g. {.code c(56, 4)} for Mattes and CC."
      ))
    }
    b <- ants_per_metric(bi, "radius_or_number_of_bins", k, i)
    strategy <- ants_per_metric(pick(sampling, i), "sampling_strategy", k, i)
    percentage <- ants_per_metric(pick(percentages, i), "sampling_percentage", k, i)
    # antsRegistration applies the first metric's sampling to the whole stage,
    # so differing per-metric sampling would silently not happen.
    if (length(unique(as.character(strategy))) > 1L ||
        length(unique(as.character(percentage))) > 1L) {
      cli::cli_abort(c(
        "Stage {i}: the metrics' sampling settings differ.",
        "i" = "antsRegistration samples every metric of a stage the way the first metric says; \\
               give each metric the same sampling_strategy and sampling_percentage."
      ))
    }
    metric_tokens <- character(k)
    for (j in seq_len(k)) {
      st <- if (is.na(strategy[[j]])) NULL else as.character(strategy[[j]])
      if (!is.null(st) && !st %in% c("None", "Regular", "Random")) {
        cli::cli_abort(
          "Stage {i}: {.arg sampling_strategy} must be None, Regular, or Random, got {.val {st}}."
        )
      }
      pc <- if (is.na(percentage[[j]])) NULL else percentage[[j]]
      if (!is.null(pc)) {
        if (is.null(st)) {
          cli::cli_abort("Stage {i}: {.arg sampling_percentage} requires {.arg sampling_strategy}.")
        }
        pct <- suppressWarnings(as.numeric(pc))
        if (is.na(pct) || pct <= 0 || pct > 1) {
          cli::cli_abort("Stage {i}: {.arg sampling_percentage} must be in (0, 1], got {.val {pc}}.")
        }
      }
      bj <- if (is.na(b[[j]])) ants_default_metric_bins(mnames[[j]]) else b[[j]]
      metric_tokens[[j]] <- ants_metric_token(
        mnames[[j]], channel(fixed, j), channel(moving, j),
        ants_num(w[[j]]), ants_num(bj), st, ants_num(pc)
      )
    }

    sh <- ants_join(shrink[[i]], "x")
    sm <- ants_join(smooth[[i]], "x")
    unit <- pick(units, i)
    if (!is.null(unit)) {
      if (!unit %in% c("vox", "mm")) {
        cli::cli_abort("Stage {i}: {.arg sigma_units} must be vox or mm, got {.val {unit}}.")
      }
      has_unit <- regmatches(sm, regexpr("(vox|mm)$", sm))
      if (length(has_unit) == 0L) {
        sm <- paste0(sm, unit)
      } else if (!identical(has_unit, unit)) {
        cli::cli_abort(
          "Stage {i}: smoothing_sigmas {.val {sm}} already says {.val {has_unit}}, but sigma_units is {.val {unit}}."
        )
      }
    }

    # antsRegistration requires equal multiresolution level counts per stage;
    # a mismatch is a fatal CLI error, so fail early with a clear message.
    nl_sh <- ants_n_levels(sh)
    nl_sm <- ants_n_levels(sm)
    if (nl_sh != nl_sm) {
      cli::cli_abort(c(
        "Stage {i}: mismatched multiresolution level counts.",
        "x" = "shrink_factors {.val {sh}} has {nl_sh} level{?s}; \\
               smoothing_sigmas {.val {sm}} has {nl_sm} level{?s}.",
        "i" = "antsRegistration requires equal level counts per stage."
      ))
    }
    iters <- ants_join(pick(iterations, i), "x") %||% ants_default_convergence_iters(nl_sh)
    nl_it <- ants_n_levels(iters)
    if (nl_it != nl_sh) {
      cli::cli_abort(c(
        "Stage {i}: mismatched multiresolution level counts.",
        "x" = "number_of_iterations {.val {iters}} has {nl_it} level{?s}; \\
               shrink_factors {.val {sh}} has {nl_sh} level{?s}."
      ))
    }

    stages[[i]] <- list(
      transform = transform,
      metric = metric_tokens,
      convergence = ants_convergence_token(
        iters,
        ants_num(pick(thresholds, i) %||% "1e-6"),
        ants_num(pick(windows, i) %||% "10")
      ),
      shrink = sh,
      smoothing = sm
    )
  }

  # ---- trailing global flags ----
  post <- character(0)
  wc <- ants_bool01(vd[["write_composite_transform"]])
  if (!is.null(wc)) post <- c(post, "--write-composite-transform", wc)
  if (!is.null(v[["random_seed"]])) {
    post <- c(post, "--random-seed", as.character(as.integer(v[["random_seed"]])))
  }
  if (isTRUE(v[["float"]])) post <- c(post, "--float", "1")
  if (isTRUE(v[["verbose"]])) post <- c(post, "-v")

  # Raw passthrough of extra global antsRegistration arguments, appended once
  # after every stage. Per-stage settings have dedicated inputs above.
  if (!is.null(v[["args"]]) && nzchar(as.character(v[["args"]]))) {
    post <- c(post, strsplit(trimws(as.character(v[["args"]])), "\\s+")[[1]])
  }

  render_ants_registration_core(command, pre, stages, post)
}

# ---- #5: high-level transform build ----------------------------------------

#' Stage definitions for transform-build presets
#' @keywords internal
ants_preset_stages <- function(preset) {
  rigid <- list(transform = "Rigid", metric = "MI",
    shrink = "8x4x2x1", smoothing = "3x2x1x0vox", iters = "1000x500x250x0")
  affine <- list(transform = "Affine", metric = "MI",
    shrink = "8x4x2x1", smoothing = "3x2x1x0vox", iters = "1000x500x250x0")
  syn <- list(transform = "SyN", metric = "CC",
    shrink = "8x4x2x1", smoothing = "3x2x1x0vox", iters = "100x70x50x20")

  switch(preset,
    rigid = list(rigid),
    affine = list(affine),
    rigid_affine = list(rigid, affine),
    rigid_affine_syn = list(rigid, affine, syn),
    list(rigid, affine, syn)
  )
}

#' Render a high-level transform-build command (renderer: ants_transform_build)
#' @keywords internal
render_ants_transform_build <- function(call) {
  spec <- call$spec
  v <- call$values
  vd <- apply_spec_defaults(spec, v)

  command <- spec$command
  if (is.list(command)) command <- unlist(command)
  command <- command[[1]]

  fixed <- as.character(v[["fixed_image"]])
  moving <- as.character(v[["moving_image"]])
  prefix <- as.character(v[["output_prefix"]])
  preset <- as.character(vd[["preset"]] %||% "rigid_affine_syn")
  warped <- paste0(prefix, "Warped.nii.gz")

  # ---- global flags ----
  pre <- c("--dimensionality", as.character(vd[["dimension"]] %||% 3))
  pre <- c(pre, "--output", sprintf("[%s,%s]", prefix, warped))
  pre <- c(pre, "--interpolation", as.character(vd[["interpolation"]] %||% "Linear"))
  pre <- c(pre, "--winsorize-image-intensities", "[0.005,0.995]")
  pre <- c(pre, "--use-histogram-matching", "1")
  pre <- c(pre, "--collapse-output-transforms", "1")
  pre <- c(pre, "--initial-moving-transform",
    sprintf("[%s,%s,1]", fixed, moving))

  # ANTs --masks takes [fixedMask,movingMask]. Emit only the masks actually
  # provided rather than a literal "NULL" path. A fixed-only mask is the common
  # case; moving-only uses ANTs' positional NULL placeholder.
  if (!is.null(v[["fixed_mask"]]) && !is.null(v[["moving_mask"]])) {
    pre <- c(pre, "--masks", sprintf("[%s,%s]", v[["fixed_mask"]], v[["moving_mask"]]))
  } else if (!is.null(v[["fixed_mask"]])) {
    pre <- c(pre, "--masks", sprintf("[%s]", v[["fixed_mask"]]))
  } else if (!is.null(v[["moving_mask"]])) {
    pre <- c(pre, "--masks", sprintf("[NULL,%s]", v[["moving_mask"]]))
  }

  # ---- stages ----
  preset_stages <- ants_preset_stages(preset)
  stages <- lapply(preset_stages, function(s) {
    list(
      transform = sprintf("%s[%s]", s$transform,
        ants_default_transform_params(s$transform)),
      metric = ants_metric_token(s$metric, fixed, moving, "1",
        ants_default_metric_bins(s$metric)),
      convergence = ants_convergence_token(s$iters),
      shrink = s$shrink,
      smoothing = s$smoothing
    )
  })

  # ---- trailing flags ----
  post <- c("--write-composite-transform", "1")
  if (!is.null(v[["random_seed"]])) {
    post <- c(post, "--random-seed", as.character(as.integer(v[["random_seed"]])))
  }
  if (identical(as.character(vd[["precision"]] %||% "double"), "float")) {
    post <- c(post, "--float", "1")
  }

  render_ants_registration_core(command, pre, stages, post)
}

# ---- antsApplyTransforms ----------------------------------------------------

#' Render antsApplyTransforms (renderer: ants_apply_transforms)
#'
#' Each transform is its own `--transform` (wrapped as `[file,1]` when
#' inverted), and `print_out_composite_warp_file` writes the composed
#' displacement field as `--output [field,1]`.
#' @keywords internal
render_ants_apply_transforms <- function(call) {
  spec <- call$spec
  v <- call$values
  vd <- apply_spec_defaults(spec, v)

  transforms <- as.character(ants_as_vec(v[["transforms"]]))
  if (length(transforms) == 0L) {
    cli::cli_abort("{.arg transforms} must list at least one transform.")
  }
  invert <- ants_as_vec(v[["invert_transform_flags"]])
  if (length(invert) == 0L) invert <- rep(FALSE, length(transforms))
  if (length(invert) != length(transforms)) {
    cli::cli_abort(
      "{.arg invert_transform_flags} has {length(invert)} value{?s} for {length(transforms)} transform{?s}."
    )
  }
  composite <- isTRUE(vd[["print_out_composite_warp_file"]])
  if (!composite && !ants_given(v[["input_image"]])) {
    cli::cli_abort("{.arg input_image} is required unless {.arg print_out_composite_warp_file} is TRUE.")
  }
  if (!ants_given(v[["output_image"]])) {
    cli::cli_abort("{.arg output_image} is required.")
  }

  args <- character(0)
  if (!is.null(v[["dimension"]])) args <- c(args, "--dimensionality", as.character(v[["dimension"]]))
  if (!is.null(v[["input_image_type"]])) {
    args <- c(args, "--input-image-type", as.character(v[["input_image_type"]]))
  }
  if (ants_given(v[["input_image"]])) args <- c(args, "--input", v[["input_image"]])
  args <- c(args, "--reference-image", v[["reference_image"]])
  args <- c(args, "--output",
    if (composite) sprintf("[%s,1]", v[["output_image"]]) else v[["output_image"]])
  args <- c(args, "--interpolation", as.character(vd[["interpolation"]] %||% "Linear"))
  args <- c(args, "--default-value", ants_num(vd[["default_value"]] %||% 0))
  if (isTRUE(v[["float"]])) args <- c(args, "--float", "1")
  for (i in seq_along(transforms)) {
    args <- c(args, "--transform",
      if (isTRUE(as.logical(invert[[i]]))) sprintf("[%s,1]", transforms[[i]]) else transforms[[i]])
  }
  if (!is.null(v[["args"]]) && nzchar(as.character(v[["args"]]))) {
    args <- c(args, strsplit(trimws(as.character(v[["args"]])), "\\s+")[[1]])
  }

  command <- spec$command
  if (is.list(command)) command <- unlist(command)
  list(command = command[[1]], args = unname(args), stdout = NULL, stderr = NULL)
}

# ---- MeasureImageSimilarity -------------------------------------------------

#' Render MeasureImageSimilarity (renderer: ants_measure_image_similarity)
#'
#' The metric value is printed on stdout.
#' @keywords internal
render_ants_measure_image_similarity <- function(call) {
  spec <- call$spec
  v <- call$values
  vd <- apply_spec_defaults(spec, v)

  strategy <- v[["sampling_strategy"]]
  percentage <- v[["sampling_percentage"]]
  if (!is.null(percentage)) {
    if (is.null(strategy)) {
      cli::cli_abort("{.arg sampling_percentage} requires {.arg sampling_strategy}.")
    }
    if (!(percentage > 0 && percentage <= 1)) {
      cli::cli_abort("{.arg sampling_percentage} must be in (0, 1], got {.val {percentage}}.")
    }
  }
  metric <- ants_metric_token(
    as.character(v[["metric"]]), v[["fixed_image"]], v[["moving_image"]],
    ants_num(vd[["metric_weight"]] %||% 1), ants_num(v[["radius_or_number_of_bins"]]),
    strategy, ants_num(percentage)
  )
  args <- c("--dimensionality", as.character(vd[["dimension"]] %||% 3), "--metric", metric)

  fixed_mask <- v[["fixed_image_mask"]]
  moving_mask <- v[["moving_image_mask"]]
  # MeasureImageSimilarity documents fixedMask and [fixedMask,movingMask] only.
  if (!is.null(moving_mask) && is.null(fixed_mask)) {
    cli::cli_abort("{.arg moving_image_mask} requires {.arg fixed_image_mask}.")
  }
  if (!is.null(moving_mask)) {
    args <- c(args, "--masks", sprintf("[%s,%s]", fixed_mask, moving_mask))
  } else if (!is.null(fixed_mask)) {
    args <- c(args, "--masks", fixed_mask)
  }
  if (!is.null(v[["args"]]) && nzchar(as.character(v[["args"]]))) {
    args <- c(args, strsplit(trimws(as.character(v[["args"]])), "\\s+")[[1]])
  }

  command <- spec$command
  if (is.list(command)) command <- unlist(command)
  list(command = command[[1]], args = unname(args), stdout = NULL, stderr = NULL)
}
