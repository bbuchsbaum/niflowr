# Read fMRIPrep confounds timeseries

Reads an fMRIPrep confounds TSV file for a given subject, task, and
optional session and run.

## Usage

``` r
ni_fmriprep_confounds(
  deriv_dir,
  subid,
  task,
  session = NULL,
  run = NULL,
  select = NULL
)
```

## Arguments

- deriv_dir:

  Path to the fMRIPrep derivatives directory.

- subid:

  Subject ID (without "sub-" prefix).

- task:

  Task name (without "task-" prefix).

- session:

  Session ID (without "ses-" prefix). Default: `NULL`.

- run:

  Run number (without "run-" prefix). Default: `NULL`.

- select:

  Character vector of column names to select. Default: `NULL` (all
  columns).

## Value

A data.frame with confound timeseries.

## Details

fMRIPrep confounds files follow the pattern:
`{deriv_dir}/sub-{subid}/[ses-{session}/]func/sub-{subid}_[ses-{session}_]task-{task}_[run-{run}_]desc-confounds_timeseries.tsv`

## Examples

``` r
if (FALSE) { # \dontrun{
conf <- ni_fmriprep_confounds(
  deriv_dir = "derivatives/fmriprep",
  subid = "01",
  task = "rest"
)
} # }
```
