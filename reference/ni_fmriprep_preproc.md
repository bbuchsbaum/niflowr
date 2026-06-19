# Locate fMRIPrep preprocessed files

Searches for preprocessed files in an fMRIPrep derivatives directory and
returns a data.frame with file paths and parsed BIDS entities.

## Usage

``` r
ni_fmriprep_preproc(
  deriv_dir,
  subid = NULL,
  task = NULL,
  session = NULL,
  run = NULL,
  space = NULL,
  suffix = NULL,
  extension = ".nii.gz"
)
```

## Arguments

- deriv_dir:

  Path to the fMRIPrep derivatives directory.

- subid:

  Subject ID (without "sub-" prefix). Default: `NULL` (all subjects).

- task:

  Task name filter (without "task-" prefix). Default: `NULL`.

- session:

  Session ID filter (without "ses-" prefix). Default: `NULL`.

- run:

  Run number filter (without "run-" prefix). Default: `NULL`.

- space:

  Space filter (without "space-" prefix, e.g. "MNI152NLin2009cAsym").
  Default: `NULL`.

- suffix:

  Suffix filter (e.g. "bold", "T1w", "mask"). Default: `NULL`.

- extension:

  File extension filter. Default: `".nii.gz"`.

## Value

A data.frame with columns: `path`, `subject`, `session`, `task`, `run`,
`space`, `desc`, `suffix`, `datatype`.

## Details

fMRIPrep outputs follow the pattern:
`{deriv_dir}/sub-{subid}/[ses-{session}/]{anat|func}/sub-{subid}_[entities]_{suffix}{ext}`

## Examples

``` r
if (FALSE) { # \dontrun{
# Find all preprocessed bold files
bold <- ni_fmriprep_preproc(
  deriv_dir = "derivatives/fmriprep",
  suffix = "bold"
)

# Find specific subject/task in MNI space
preproc <- ni_fmriprep_preproc(
  deriv_dir = "derivatives/fmriprep",
  subid = "01",
  task = "rest",
  space = "MNI152NLin2009cAsym"
)
} # }
```
