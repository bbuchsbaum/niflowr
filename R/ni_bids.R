#' Generate a BIDS-derivatives output path
#'
#' Constructs an output path following BIDS-derivatives conventions.
#'
#' @param input_path The input file path (a BIDS-formatted path).
#' @param derivatives_dir Base derivatives directory. Default: `"derivatives/niflowr"`.
#' @param desc Description entity (e.g. `"brain"`, `"preproc"`).
#' @param space Space entity (e.g. `"MNI152NLin2009cAsym"`).
#' @param suffix Override the BIDS suffix (e.g. `"T1w"`, `"bold"`).
#' @param extension File extension. Default: `".nii.gz"`.
#' @return A character string with the derivatives output path.
#' @export
ni_deriv_path <- function(input_path, derivatives_dir = "derivatives/niflowr",
                          desc = NULL, space = NULL, suffix = NULL,
                          extension = ".nii.gz") {
  # Extract filename components
  fname <- basename(input_path)
  fname_no_ext <- sub("\\.(nii\\.gz|nii|mgz|mgh)$", "", fname)

  # Parse BIDS entities from filename
  parts <- strsplit(fname_no_ext, "_")[[1]]

  # Find sub- entity for directory structure
  sub_part <- grep("^sub-", parts, value = TRUE)
  ses_part <- grep("^ses-", parts, value = TRUE)

  # Rebuild filename with modifications
  # Remove existing desc- and space- if we're replacing them
  filtered <- parts
  if (!is.null(desc)) {
    filtered <- filtered[!grepl("^desc-", filtered)]
  }
  if (!is.null(space)) {
    filtered <- filtered[!grepl("^space-", filtered)]
  }
  if (!is.null(suffix)) {
    # The last part (without entity prefix) is usually the suffix
    # Replace it
    is_entity <- grepl("^[a-z]+-", filtered)
    if (any(!is_entity)) {
      filtered <- filtered[is_entity]
    }
  }

  # Insert new entities before the suffix
  new_parts <- filtered[grepl("^[a-z]+-", filtered)]
  if (!is.null(desc)) {
    new_parts <- c(new_parts, paste0("desc-", desc))
  }
  if (!is.null(space)) {
    new_parts <- c(new_parts, paste0("space-", space))
  }

  # Add suffix
  final_suffix <- suffix %||% parts[length(parts)]
  if (grepl("^[a-z]+-", final_suffix)) {
    # If the last part was an entity, we need a suffix
    final_suffix <- "T1w"
  }
  new_parts <- c(new_parts, final_suffix)

  new_fname <- paste0(paste(new_parts, collapse = "_"), extension)

  # Build directory structure
  dir_parts <- derivatives_dir
  if (length(sub_part) > 0) dir_parts <- c(dir_parts, sub_part)
  if (length(ses_part) > 0) dir_parts <- c(dir_parts, ses_part)

  # Detect modality from suffix
  modality <- if (final_suffix %in% c("T1w", "T2w", "FLAIR")) {
    "anat"
  } else if (final_suffix %in% c("bold", "sbref")) {
    "func"
  } else {
    "anat"
  }
  dir_parts <- c(dir_parts, modality)

  file.path(paste(dir_parts, collapse = "/"), new_fname)
}

#' Query a BIDS project for inputs matching a spec
#'
#' Uses `bidser::bids_project` to discover files matching a spec's input
#' requirements.
#'
#' @param project A `bids_project` object (from `bidser::bids_project()`).
#' @param spec_id Spec ID or `ni_spec` object.
#' @param subid Subject ID filter.
#' @param task Task filter.
#' @param session Session filter.
#' @param run Run filter.
#' @param modality Image modality to search for (e.g. `"T1w"`, `"bold"`).
#' @return A data.frame with a `path` column containing matched file paths.
#' @export
ni_bids_inputs <- function(project, spec_id, subid = NULL, task = NULL,
                           session = NULL, run = NULL, modality = NULL) {
  if (!requireNamespace("bidser", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg bidser} is required. Install from: ~/code/bidser")
  }

  # Use bidser search_files with entity filters
  args <- list(x = project, full_path = TRUE)
  if (!is.null(subid)) args$subid <- subid
  if (!is.null(task)) args$task <- task
  if (!is.null(session)) args$session <- session
  if (!is.null(run)) args$run <- run

  # Build a regex from modality
  if (!is.null(modality)) {
    args$regex <- paste0("_", modality, "\\.")
  }

  files <- do.call(bidser::search_files, args)

  if (length(files) == 0) {
    cli::cli_warn("No matching files found in BIDS project.")
    return(data.frame(path = character(0), stringsAsFactors = FALSE))
  }

  data.frame(path = files, stringsAsFactors = FALSE)
}
