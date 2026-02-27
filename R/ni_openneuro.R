#' Fetch and prepare OpenNeuro dataset
#'
#' Downloads an OpenNeuro dataset and optionally queries it for BIDS inputs
#' matching a spec. This is a convenience wrapper around the openneuroR workflow.
#'
#' @param dataset_id OpenNeuro dataset identifier (e.g. `"ds000114"`).
#' @param tag Optional dataset version tag (e.g. `"1.0.0"`).
#' @param subjects Optional subject IDs to download (default: all subjects).
#' @param spec_id Spec ID or `ni_spec` object to match inputs against (optional).
#' @param modality Image modality to search for (e.g. `"T1w"`, `"bold"`).
#' @param subid Subject ID filter for input query.
#' @param task Task filter for input query.
#' @param session Session filter for input query.
#' @param run Run filter for input query.
#' @param derivatives Include derivatives in the BIDS project.
#' @param prep_dir Path to preprocessed derivatives directory.
#' @param quiet Suppress progress messages.
#' @param force Force re-download of cached data.
#' @param ... Additional arguments passed to `openneuroR::on_fetch()`.
#' @return If `spec_id` or `modality` is provided, returns a data.frame from
#'   `ni_bids_inputs()`. Otherwise, returns a `bids_project` object.
#' @export
#' @examples
#' \dontrun{
#' # Get the full BIDS project
#' proj <- ni_from_openneuro("ds000114")
#'
#' # Get specific inputs for a spec
#' inputs <- ni_from_openneuro("ds000114", spec_id = "fsl_feat", modality = "bold")
#' }
ni_from_openneuro <- function(dataset_id, tag = NULL, subjects = NULL,
                               spec_id = NULL, modality = NULL, subid = NULL,
                               task = NULL, session = NULL, run = NULL,
                               derivatives = FALSE, prep_dir = "derivatives/fmriprep",
                               quiet = FALSE, force = FALSE, ...) {
  if (!requireNamespace("openneuroR", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg openneuroR} is required. Install from: https://github.com/bbuchsbaum/openneuroR")
  }

  if (!requireNamespace("bidser", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg bidser} is required. Install from: ~/code/bidser")
  }

  # Create the OpenNeuro handle
  handle <- openneuroR::on_handle(dataset_id, tag)

  # Fetch the dataset
  openneuroR::on_fetch(handle, subjects = subjects, quiet = quiet, force = force, ...)

  # Get the BIDS project
  bids_proj <- openneuroR::on_bids(handle)

  # If spec_id or modality provided, query for inputs
  if (!is.null(spec_id) || !is.null(modality)) {
    return(ni_bids_inputs(
      project = bids_proj,
      spec_id = spec_id,
      subid = subid,
      task = task,
      session = session,
      run = run,
      modality = modality
    ))
  }

  # Otherwise return the BIDS project
  bids_proj
}
