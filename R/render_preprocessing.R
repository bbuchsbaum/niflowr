# Explicit output contracts for interfaces with collections or non-CLI behavior.
# Sources: ANTs N4BiasFieldCorrection --help; FSL FAST and epi_reg documentation,
# and the upstream Nipype FAST/EpiReg output definitions.
resolve_tool_outputs <- function(spec, values) {
  v <- apply_spec_defaults(spec, values)
  switch(spec$output_resolver,
    afni_volreg = {
      out <- list()
      if (!is.null(v[["oned_file"]])) out$oned_file <- v[["oned_file"]]
      if (!is.null(v[["oned_matrix_save"]])) {
        out$oned_matrix_save <- if (grepl("\\.1D$", v[["oned_matrix_save"]], ignore.case = TRUE)) {
          v[["oned_matrix_save"]]
        } else {
          paste0(v[["oned_matrix_save"]], ".aff12.1D")
        }
      }
      if (!is.null(v[["md1d_file"]])) {
        out$md1d_file <- v[["md1d_file"]]
        out$md1d_delta_file <- paste0(v[["md1d_file"]], "_delt")
      }
      if (!is.null(v[["out_file"]]) && !identical(v[["out_file"]], "NULL")) out$out_file <- v[["out_file"]]
      out
    },
    afni_allineate_estimate = {
      matrix <- v[["out_matrix"]]
      if (!grepl("\\.1D$", matrix, ignore.case = TRUE)) matrix <- paste0(matrix, ".aff12.1D")
      out <- list(out_matrix = matrix)
      if (!is.null(v[["out_file"]]) && !identical(v[["out_file"]], "NULL")) out$out_file <- v[["out_file"]]
      out
    },
    ants_n4 = {
      out <- list(output_image = v[["output_image"]])
      if (isTRUE(v[["save_bias"]])) out$bias_image <- v[["bias_image"]] %||%
        paste0(strip_known_extension(v[["output_image"]]), "_bias.nii.gz")
      out
    },
    fsl_fast = {
      if (!length(v[["in_files"]])) cli::cli_abort("FAST requires at least one input image.")
      base <- strip_known_extension(v[["out_basename"]] %||% utils::tail(v[["in_files"]], 1))
      n <- v[["number_classes"]] %||% 3L
      if (length(n) != 1L || !is.numeric(n) || is.na(n) || n < 1 || n > 10 || n != trunc(n))
        cli::cli_abort("FAST number_classes must be an integer from 1 to 10.")
      path <- function(suffix) paste0(base, suffix, ".nii.gz")
      out <- list(tissue_class_map = path("_seg"))
      if (!isTRUE(v[["no_pve"]])) {
        out$partial_volume_files <- path(paste0("_pve_", seq_len(n) - 1L))
        out$partial_volume_map <- path("_pveseg")
        out$mixeltype <- path("_mixeltype")
      }
      if (isTRUE(v[["segments"]])) out$tissue_class_files <- path(paste0("_seg_", seq_len(n) - 1L))
      if (isTRUE(v[["probability_maps"]])) out$probability_maps <- path(paste0("_prob_", seq_len(n) - 1L))
      channels <- if (length(v[["in_files"]]) == 1L) "" else paste0("_", seq_along(v[["in_files"]]))
      if (isTRUE(v[["output_biascorrected"]])) out$restored_image <- path(paste0("_restore", channels))
      if (isTRUE(v[["output_biasfield"]])) out$bias_field <- path(paste0("_bias", channels))
      out
    },
    fsl_epi_reg = {
      base <- strip_known_extension(v[["out_base"]])
      out <- list(out_file = paste0(base, ".nii.gz"), epi2str_mat = paste0(base, ".mat"))
      if (is.null(v[["wmseg"]])) {
        out$wmseg <- paste0(base, "_fast_wmseg.nii.gz")
        out$wmedge <- paste0(base, "_fast_wmedge.nii.gz")
        if (isTRUE(values$no_clean)) out$seg <- paste0(base, "_fast_seg.nii.gz")
      }
      out
    },
    cli::cli_abort("Unknown output resolver: {.val {spec$output_resolver}}")
  )
}

render_ants_n4 <- function(call) {
  v <- call$values
  if (isTRUE(v[["copy_header"]])) cli::cli_abort("N4 copy_header = TRUE is unsupported; header copying is not implemented.")
  if (!isTRUE(v[["save_bias"]]) && !is.null(v[["bias_image"]])) cli::cli_abort("bias_image requires save_bias = TRUE.")
  call$spec$render <- NULL
  if (isTRUE(v[["save_bias"]])) {
    outputs <- resolve_tool_outputs(call$spec, v)
    call$values$output_image <- paste0("[", outputs$output_image, ",", outputs$bias_image, "]")
  }
  if (!is.null(v[["n_iterations"]])) {
    call$values$n_iterations <- paste(v[["n_iterations"]], collapse = "x")
  }
  build_command(call)
}

render_fsl_fast <- function(call) {
  call$spec$render <- NULL
  # FAST requires the number of channels for multi-input segmentation.
  built <- build_command(call)
  if (length(call$values$in_files) > 1L) built$args <- c("-S", as.character(length(call$values$in_files)), built$args)
  built
}
