#' Read fMRIPrep confounds timeseries
#'
#' Reads an fMRIPrep confounds TSV file for a given subject, task, and optional
#' session and run.
#'
#' fMRIPrep confounds files follow the pattern:
#' `{deriv_dir}/sub-{subid}/[ses-{session}/]func/sub-{subid}_[ses-{session}_]task-{task}_[run-{run}_]desc-confounds_timeseries.tsv`
#'
#' @param deriv_dir Path to the fMRIPrep derivatives directory.
#' @param subid Subject ID (without "sub-" prefix).
#' @param task Task name (without "task-" prefix).
#' @param session Session ID (without "ses-" prefix). Default: `NULL`.
#' @param run Run number (without "run-" prefix). Default: `NULL`.
#' @param select Character vector of column names to select. Default: `NULL` (all columns).
#' @return A data.frame with confound timeseries.
#' @export
#' @examples
#' \dontrun{
#' conf <- ni_fmriprep_confounds(
#'   deriv_dir = "derivatives/fmriprep",
#'   subid = "01",
#'   task = "rest"
#' )
#' }
ni_fmriprep_confounds <- function(deriv_dir, subid, task, session = NULL,
                                   run = NULL, select = NULL) {
  # Build path components
  parts <- c(paste0("sub-", subid))
  if (!is.null(session)) {
    parts <- c(parts, paste0("ses-", session))
  }
  parts <- c(parts, "func")

  # Build filename entities
  fname_parts <- paste0("sub-", subid)
  if (!is.null(session)) {
    fname_parts <- paste(fname_parts, paste0("ses-", session), sep = "_")
  }
  fname_parts <- paste(fname_parts, paste0("task-", task), sep = "_")
  if (!is.null(run)) {
    fname_parts <- paste(fname_parts, paste0("run-", run), sep = "_")
  }
  fname_parts <- paste(fname_parts, "desc-confounds_timeseries.tsv", sep = "_")

  # Build full path
  path <- file.path(deriv_dir, paste(parts, collapse = "/"), fname_parts)

  if (!file.exists(path)) {
    cli::cli_abort(c(
      "Confounds file not found:",
      "i" = "Expected path: {.path {path}}"
    ))
  }

  # Read confounds
  df <- utils::read.table(path, header = TRUE, sep = "\t", stringsAsFactors = FALSE)

  # Optionally subset columns
  if (!is.null(select)) {
    missing <- setdiff(select, names(df))
    if (length(missing) > 0) {
      cli::cli_abort(c(
        "Requested columns not found in confounds file:",
        "x" = "Missing: {.val {missing}}"
      ))
    }
    df <- df[, select, drop = FALSE]
  }

  df
}


#' Locate fMRIPrep preprocessed files
#'
#' Searches for preprocessed files in an fMRIPrep derivatives directory and
#' returns a data.frame with file paths and parsed BIDS entities.
#'
#' fMRIPrep outputs follow the pattern:
#' `{deriv_dir}/sub-{subid}/[ses-{session}/]{anat|func}/sub-{subid}_[entities]_{suffix}{ext}`
#'
#' @param deriv_dir Path to the fMRIPrep derivatives directory.
#' @param subid Subject ID (without "sub-" prefix). Default: `NULL` (all subjects).
#' @param task Task name filter (without "task-" prefix). Default: `NULL`.
#' @param session Session ID filter (without "ses-" prefix). Default: `NULL`.
#' @param run Run number filter (without "run-" prefix). Default: `NULL`.
#' @param space Space filter (without "space-" prefix, e.g. "MNI152NLin2009cAsym"). Default: `NULL`.
#' @param suffix Suffix filter (e.g. "bold", "T1w", "mask"). Default: `NULL`.
#' @param extension File extension filter. Default: `".nii.gz"`.
#' @return A data.frame with columns: `path`, `subject`, `session`, `task`, `run`,
#'   `space`, `desc`, `suffix`, `datatype`.
#' @export
#' @examples
#' \dontrun{
#' # Find all preprocessed bold files
#' bold <- ni_fmriprep_preproc(
#'   deriv_dir = "derivatives/fmriprep",
#'   suffix = "bold"
#' )
#'
#' # Find specific subject/task in MNI space
#' preproc <- ni_fmriprep_preproc(
#'   deriv_dir = "derivatives/fmriprep",
#'   subid = "01",
#'   task = "rest",
#'   space = "MNI152NLin2009cAsym"
#' )
#' }
ni_fmriprep_preproc <- function(deriv_dir, subid = NULL, task = NULL,
                                 session = NULL, run = NULL, space = NULL,
                                 suffix = NULL, extension = ".nii.gz") {
  if (!dir.exists(deriv_dir)) {
    cli::cli_abort("Derivatives directory not found: {.path {deriv_dir}}")
  }

  # Build search pattern
  search_dir <- deriv_dir
  if (!is.null(subid)) {
    search_dir <- file.path(deriv_dir, paste0("sub-", subid))
    if (!dir.exists(search_dir)) {
      cli::cli_abort("Subject directory not found: {.path {search_dir}}")
    }
  }

  # Find all files matching extension
  pattern <- paste0("\\", extension, "$")
  files <- list.files(search_dir, pattern = pattern, recursive = TRUE, full.names = TRUE)

  if (length(files) == 0) {
    cli::cli_warn("No files found matching extension {.val {extension}}")
    return(data.frame(
      path = character(0),
      subject = character(0),
      session = character(0),
      task = character(0),
      run = character(0),
      space = character(0),
      desc = character(0),
      suffix = character(0),
      datatype = character(0),
      stringsAsFactors = FALSE
    ))
  }

  # Parse entities from each file
  parse_entities <- function(path) {
    fname <- basename(path)
    dname <- dirname(path)
    datatype <- basename(dname)

    # Extract entities using regex
    sub_match <- regmatches(fname, regexpr("sub-[a-zA-Z0-9]+", fname))
    subject <- if (length(sub_match) > 0) sub("^sub-", "", sub_match) else NA_character_

    ses_match <- regmatches(fname, regexpr("ses-[a-zA-Z0-9]+", fname))
    session <- if (length(ses_match) > 0) sub("^ses-", "", ses_match) else NA_character_

    task_match <- regmatches(fname, regexpr("task-[a-zA-Z0-9]+", fname))
    task_val <- if (length(task_match) > 0) sub("^task-", "", task_match) else NA_character_

    run_match <- regmatches(fname, regexpr("run-[0-9]+", fname))
    run_val <- if (length(run_match) > 0) sub("^run-", "", run_match) else NA_character_

    space_match <- regmatches(fname, regexpr("space-[a-zA-Z0-9]+", fname))
    space_val <- if (length(space_match) > 0) sub("^space-", "", space_match) else NA_character_

    desc_match <- regmatches(fname, regexpr("desc-[a-zA-Z0-9]+", fname))
    desc_val <- if (length(desc_match) > 0) sub("^desc-", "", desc_match) else NA_character_

    # Extract suffix (last part before extension)
    fname_no_ext <- sub("\\.(nii\\.gz|nii|mgz|mgh|tsv|json)$", "", fname)
    parts <- strsplit(fname_no_ext, "_")[[1]]
    suffix_val <- if (length(parts) > 0) parts[length(parts)] else NA_character_

    data.frame(
      path = path,
      subject = subject,
      session = session,
      task = task_val,
      run = run_val,
      space = space_val,
      desc = desc_val,
      suffix = suffix_val,
      datatype = datatype,
      stringsAsFactors = FALSE
    )
  }

  # Parse all files
  results <- do.call(rbind, lapply(files, parse_entities))

  # Apply filters
  if (!is.null(task)) {
    results <- results[!is.na(results$task) & results$task == task, ]
  }
  if (!is.null(session)) {
    results <- results[!is.na(results$session) & results$session == session, ]
  }
  if (!is.null(run)) {
    results <- results[!is.na(results$run) & results$run == run, ]
  }
  if (!is.null(space)) {
    results <- results[!is.na(results$space) & results$space == space, ]
  }
  if (!is.null(suffix)) {
    results <- results[!is.na(results$suffix) & results$suffix == suffix, ]
  }

  rownames(results) <- NULL
  results
}


#' List fMRIPrep derivatives overview
#'
#' Summarizes what's available in an fMRIPrep derivatives directory by subject.
#'
#' @param deriv_dir Path to the fMRIPrep derivatives directory.
#' @param subid Subject ID filter (without "sub-" prefix). Default: `NULL` (all subjects).
#' @return A data.frame with columns: `subject`, `has_anat`, `has_func`,
#'   `n_anat_files`, `n_func_files`.
#' @export
#' @examples
#' \dontrun{
#' overview <- ni_fmriprep_derivatives("derivatives/fmriprep")
#' print(overview)
#' }
ni_fmriprep_derivatives <- function(deriv_dir, subid = NULL) {
  if (!dir.exists(deriv_dir)) {
    cli::cli_abort("Derivatives directory not found: {.path {deriv_dir}}")
  }

  # Find all subject directories
  all_dirs <- list.dirs(deriv_dir, recursive = FALSE, full.names = FALSE)
  sub_dirs <- grep("^sub-", all_dirs, value = TRUE)

  if (length(sub_dirs) == 0) {
    cli::cli_warn("No subject directories found in {.path {deriv_dir}}")
    return(data.frame(
      subject = character(0),
      has_anat = logical(0),
      has_func = logical(0),
      n_anat_files = integer(0),
      n_func_files = integer(0),
      stringsAsFactors = FALSE
    ))
  }

  # Filter by subid if provided
  if (!is.null(subid)) {
    target <- paste0("sub-", subid)
    sub_dirs <- sub_dirs[sub_dirs == target]
    if (length(sub_dirs) == 0) {
      cli::cli_abort("Subject not found: {.val {subid}}")
    }
  }

  # Summarize each subject
  summarize_subject <- function(sub_dir) {
    subject <- sub("^sub-", "", sub_dir)
    base_path <- file.path(deriv_dir, sub_dir)

    # Check for anat and func directories
    anat_dir <- file.path(base_path, "anat")
    func_dir <- file.path(base_path, "func")

    # Also check for session subdirectories
    ses_dirs <- list.dirs(base_path, recursive = FALSE, full.names = TRUE)
    ses_dirs <- grep("ses-", ses_dirs, value = TRUE)

    # Count files
    anat_files <- character(0)
    func_files <- character(0)

    if (dir.exists(anat_dir)) {
      anat_files <- list.files(anat_dir, pattern = "\\.(nii\\.gz|nii)$", full.names = FALSE)
    }

    if (dir.exists(func_dir)) {
      func_files <- list.files(func_dir, pattern = "\\.(nii\\.gz|nii)$", full.names = FALSE)
    }

    # Also check session directories
    for (ses_dir in ses_dirs) {
      ses_anat <- file.path(ses_dir, "anat")
      ses_func <- file.path(ses_dir, "func")

      if (dir.exists(ses_anat)) {
        anat_files <- c(anat_files, list.files(ses_anat, pattern = "\\.(nii\\.gz|nii)$"))
      }
      if (dir.exists(ses_func)) {
        func_files <- c(func_files, list.files(ses_func, pattern = "\\.(nii\\.gz|nii)$"))
      }
    }

    data.frame(
      subject = subject,
      has_anat = length(anat_files) > 0,
      has_func = length(func_files) > 0,
      n_anat_files = length(anat_files),
      n_func_files = length(func_files),
      stringsAsFactors = FALSE
    )
  }

  results <- do.call(rbind, lapply(sub_dirs, summarize_subject))
  rownames(results) <- NULL
  results
}
