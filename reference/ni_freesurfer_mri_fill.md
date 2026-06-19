# FREESURFER MRIFill

This program creates hemispheric cutting planes and fills white matter

## Usage

``` r
ni_freesurfer_mri_fill(
  in_file,
  out_file,
  args = NULL,
  log_file = NULL,
  segmentation = NULL,
  transform = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- in_file:

  Character; file path. Input white matter file **Required.**

- out_file:

  Character; file path. Output filled volume file name for MRIFill
  **Required.**

- args:

  Character. Additional parameters to the command

- log_file:

  Character; file path. Output log file for MRIFill

- segmentation:

  Character; file path. Input segmentation file for MRIFill

- transform:

  Character; file path. Input transform file for MRIFill

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
