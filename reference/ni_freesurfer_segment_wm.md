# FREESURFER SegmentWM

This program segments white matter from the input volume. The input

## Usage

``` r
ni_freesurfer_segment_wm(
  in_file,
  out_file,
  args = NULL,
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

  Character; file path. Input file for SegmentWM **Required.**

- out_file:

  Character; file path. File to be written as output for SegmentWM
  **Required.**

- args:

  Character. Additional parameters to the command

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
