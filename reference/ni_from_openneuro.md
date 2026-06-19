# Fetch and prepare OpenNeuro dataset

Downloads an OpenNeuro dataset and optionally queries it for BIDS inputs
matching a spec. This is a convenience wrapper around the openneuroR
workflow.

## Usage

``` r
ni_from_openneuro(
  dataset_id,
  tag = NULL,
  subjects = NULL,
  spec_id = NULL,
  modality = NULL,
  subid = NULL,
  task = NULL,
  session = NULL,
  run = NULL,
  derivatives = FALSE,
  prep_dir = "derivatives/fmriprep",
  quiet = FALSE,
  force = FALSE,
  ...
)
```

## Arguments

- dataset_id:

  OpenNeuro dataset identifier (e.g. `"ds000114"`).

- tag:

  Optional dataset version tag (e.g. `"1.0.0"`).

- subjects:

  Optional subject IDs to download (default: all subjects).

- spec_id:

  Spec ID or `ni_spec` object to match inputs against (optional).

- modality:

  Image modality to search for (e.g. `"T1w"`, `"bold"`).

- subid:

  Subject ID filter for input query.

- task:

  Task filter for input query.

- session:

  Session filter for input query.

- run:

  Run filter for input query.

- derivatives:

  Include derivatives in the BIDS project.

- prep_dir:

  Path to preprocessed derivatives directory.

- quiet:

  Suppress progress messages.

- force:

  Force re-download of cached data.

- ...:

  Additional arguments passed to `openneuroR::on_fetch()`.

## Value

If `spec_id` or `modality` is provided, returns a data.frame from
[`ni_bids_inputs()`](https://bbuchsbaum.github.io/niflowr/reference/ni_bids_inputs.md).
Otherwise, returns a `bids_project` object.

## Examples

``` r
if (FALSE) { # \dontrun{
# Get the full BIDS project
proj <- ni_from_openneuro("ds000114")

# Get specific inputs for a spec
inputs <- ni_from_openneuro("ds000114", spec_id = "fsl_feat", modality = "bold")
} # }
```
