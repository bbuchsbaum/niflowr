# FREESURFER FitMSParams

Estimate tissue parameters from a set of FLASH images.

## Usage

``` r
ni_freesurfer_fit_ms_params(
  in_files,
  args = NULL,
  out_dir = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- in_files:

  Character or numeric vector. list of FLASH images (must be in mgh
  format) **Required.**

- args:

  Character. Additional parameters to the command

- out_dir:

  Character; directory path. directory to store output in

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
