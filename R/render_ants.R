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
#' Element `i` is stage `i`'s value and a single value applies to every stage.
#' Any other length is a mis-specified stage list, so it is an error rather
#' than silently wrapped around onto the wrong stages.
#' @keywords internal
ants_stage_values <- function(x, name, n_stages) {
  x <- ants_as_vec(x)
  if (length(x) == 0L) return(NULL)
  if (anyNA(x)) {
    cli::cli_abort("{.arg {name}} contains missing values.")
  }
  if (length(x) == 1L) return(rep(x, n_stages))
  if (length(x) != n_stages) {
    cli::cli_abort(c(
      "{.arg {name}} has {length(x)} values but there {?is/are} {n_stages} stage{?s}.",
      "i" = "Give one value per stage, or a single value for all stages.",
      "i" = "Nested lists are flattened, so write multi-value stages as one string \\
             (e.g. {.val 0.1,3,0} or {.val 100x70x50x20})."
    ))
  }
  x
}

#' Format a CLI number without scientific notation (ANTs reads "1e+05" as 1)
#' @keywords internal
ants_num <- function(x) {
  if (is.null(x)) return(NULL)
  if (is.numeric(x)) return(format(x, scientific = FALSE, trim = TRUE, digits = 15))
  as.character(x)
}

#' @keywords internal
ants_given <- function(x) {
  !is.null(x) && !(length(x) == 1L && (is.na(x) || !nzchar(as.character(x))))
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
      "--metric", s$metric,
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

  transforms <- as.character(ants_as_vec(v$transforms))
  n_stages <- length(transforms)
  if (n_stages == 0L) {
    cli::cli_abort("{.arg transforms} must name at least one registration stage.")
  }
  stage <- function(name, value = v[[name]]) ants_stage_values(value, name, n_stages)
  metrics <- stage("metric")
  weights <- stage("metric_weight", v$metric_weight %||% vd$metric_weight)
  fixed <- stage("fixed_image")
  moving <- stage("moving_image")
  shrink <- stage("shrink_factors")
  smooth <- stage("smoothing_sigmas")
  params <- stage("transform_parameters")
  iterations <- stage("number_of_iterations")
  thresholds <- stage("convergence_threshold")
  windows <- stage("convergence_window_size")
  bins <- stage("radius_or_number_of_bins")
  sampling <- stage("sampling_strategy")
  percentages <- stage("sampling_percentage")

  # ---- global flags before stages ----
  prefix <- vd$output_transform_prefix %||% "transform"
  output <- prefix
  if (ants_given(v$output_warped_image)) {
    inverse <- if (ants_given(v$output_inverse_warped_image)) v$output_inverse_warped_image
    output <- sprintf("[%s]", paste(c(prefix, v$output_warped_image, inverse), collapse = ","))
  } else if (ants_given(v$output_inverse_warped_image)) {
    cli::cli_abort("{.arg output_inverse_warped_image} requires {.arg output_warped_image}.")
  }
  pre <- c("--dimensionality", as.character(vd$dimension %||% 3))
  pre <- c(pre, "--output", output)
  pre <- c(pre, "--interpolation", as.character(vd$interpolation %||% "Linear"))

  # [0,1] is antsRegistration's own no-op default, so only emit a real clip.
  lo <- as.numeric(vd$winsorize_lower_quantile %||% 0)
  hi <- as.numeric(vd$winsorize_upper_quantile %||% 1)
  if (!(lo >= 0 && hi <= 1 && lo < hi)) {
    cli::cli_abort(
      "Winsorize quantiles must satisfy 0 <= lower < upper <= 1, got [{lo}, {hi}]."
    )
  }
  if (lo > 0 || hi < 1) {
    pre <- c(pre, "--winsorize-image-intensities", sprintf("[%s,%s]", ants_num(lo), ants_num(hi)))
  }

  collapse <- ants_bool01(vd$collapse_output_transforms)
  if (!is.null(collapse)) pre <- c(pre, "--collapse-output-transforms", collapse)

  # antsRegistration honours only the last --use-histogram-matching and applies
  # it to every stage, so this is one global setting, not a per-stage one.
  histogram <- ants_bool01(v$use_histogram_matching)
  if (!is.null(histogram)) pre <- c(pre, "--use-histogram-matching", histogram)

  if (isTRUE(vd$initialize_transforms_per_stage)) {
    pre <- c(pre, "--initialize-transforms-per-stage", "1")
  }

  imt <- ants_as_vec(v$initial_moving_transform)
  if (length(imt) > 0) {
    for (t in imt) pre <- c(pre, "--initial-moving-transform", t)
  } else if (!is.null(v$initial_moving_transform_com) && length(fixed) > 0 && length(moving) > 0) {
    pre <- c(pre, "--initial-moving-transform",
      sprintf("[%s,%s,%s]", fixed[[1]], moving[[1]],
        as.character(v$initial_moving_transform_com)))
  }

  if (!is.null(v$fixed_image_mask)) {
    pre <- c(pre, "--masks", sprintf("[%s]", v$fixed_image_mask))
  }

  if (!is.null(v$restore_state)) {
    pre <- c(pre, "--restore-state", as.character(v$restore_state))
  }
  if (!is.null(v$save_state)) {
    pre <- c(pre, "--save-state", as.character(v$save_state))
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
        ants_num(tparams %||% ants_default_transform_params(tname)))
    }

    mname <- as.character(pick(metrics, i) %||% "MI")
    strategy <- pick(sampling, i)
    if (!is.null(strategy) && !strategy %in% c("None", "Regular", "Random")) {
      cli::cli_abort(
        "Stage {i}: {.arg sampling_strategy} must be None, Regular, or Random, got {.val {strategy}}."
      )
    }
    percentage <- pick(percentages, i)
    if (!is.null(percentage)) {
      if (is.null(strategy)) {
        cli::cli_abort("Stage {i}: {.arg sampling_percentage} requires {.arg sampling_strategy}.")
      }
      pct <- suppressWarnings(as.numeric(percentage))
      if (is.na(pct) || pct <= 0 || pct > 1) {
        cli::cli_abort("Stage {i}: {.arg sampling_percentage} must be in (0, 1], got {.val {percentage}}.")
      }
    }

    sh <- as.character(shrink[[i]])
    sm <- as.character(smooth[[i]])

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
    iters <- as.character(pick(iterations, i) %||% ants_default_convergence_iters(nl_sh))
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
      metric = ants_metric_token(
        mname, as.character(fixed[[i]]), as.character(moving[[i]]),
        ants_num(pick(weights, i) %||% "1"),
        ants_num(pick(bins, i) %||% ants_default_metric_bins(mname)),
        strategy, ants_num(percentage)
      ),
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
  wc <- ants_bool01(vd$write_composite_transform)
  if (!is.null(wc)) post <- c(post, "--write-composite-transform", wc)
  if (!is.null(v$random_seed)) {
    post <- c(post, "--random-seed", as.character(as.integer(v$random_seed)))
  }
  if (isTRUE(v$float)) post <- c(post, "--float", "1")
  if (isTRUE(v$verbose)) post <- c(post, "-v")

  # Raw passthrough of extra global antsRegistration arguments, appended once
  # after every stage. Per-stage settings have dedicated inputs above.
  if (!is.null(v$args) && nzchar(as.character(v$args))) {
    post <- c(post, strsplit(trimws(as.character(v$args)), "\\s+")[[1]])
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

  fixed <- as.character(v$fixed_image)
  moving <- as.character(v$moving_image)
  prefix <- as.character(v$output_prefix)
  preset <- as.character(vd$preset %||% "rigid_affine_syn")
  warped <- paste0(prefix, "Warped.nii.gz")

  # ---- global flags ----
  pre <- c("--dimensionality", as.character(vd$dimension %||% 3))
  pre <- c(pre, "--output", sprintf("[%s,%s]", prefix, warped))
  pre <- c(pre, "--interpolation", as.character(vd$interpolation %||% "Linear"))
  pre <- c(pre, "--winsorize-image-intensities", "[0.005,0.995]")
  pre <- c(pre, "--use-histogram-matching", "1")
  pre <- c(pre, "--collapse-output-transforms", "1")
  pre <- c(pre, "--initial-moving-transform",
    sprintf("[%s,%s,1]", fixed, moving))

  # ANTs --masks takes [fixedMask,movingMask]. Emit only the masks actually
  # provided rather than a literal "NULL" path. A fixed-only mask is the common
  # case; moving-only uses ANTs' positional NULL placeholder.
  if (!is.null(v$fixed_mask) && !is.null(v$moving_mask)) {
    pre <- c(pre, "--masks", sprintf("[%s,%s]", v$fixed_mask, v$moving_mask))
  } else if (!is.null(v$fixed_mask)) {
    pre <- c(pre, "--masks", sprintf("[%s]", v$fixed_mask))
  } else if (!is.null(v$moving_mask)) {
    pre <- c(pre, "--masks", sprintf("[NULL,%s]", v$moving_mask))
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
  if (!is.null(v$random_seed)) {
    post <- c(post, "--random-seed", as.character(as.integer(v$random_seed)))
  }
  if (identical(as.character(vd$precision %||% "double"), "float")) {
    post <- c(post, "--float", "1")
  }

  render_ants_registration_core(command, pre, stages, post)
}
