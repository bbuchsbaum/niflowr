# FREESURFER MakeAverageSubject

Make an average freesurfer subject

## Usage

``` r
ni_freesurfer_make_average_subject(
  subjects_ids,
  args = NULL,
  out_name = "average",
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- subjects_ids:

  Character or numeric vector. freesurfer subjects ids to average
  **Required.**

- args:

  Character. Additional parameters to the command

- out_name:

  Character; file path. name for the average subject

- .cwd:

  Working directory override.

- .env:

  Named character vector of environment variables.

- .engine:

  Execution engine override.

- .profile:

  Runtime profile override.

- dry_run:

  Logical; preview command without executing.

- echo:

  Logical; echo stdout/stderr in real time.

## Value

An `ni_result` object.
