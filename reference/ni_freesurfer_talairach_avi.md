# FREESURFER TalairachAVI

Front-end for Avi Snyders image registration tool. Computes the

## Usage

``` r
ni_freesurfer_talairach_avi(
  in_file,
  out_file,
  args = NULL,
  atlas = NULL,
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

  Character; file path. input volume **Required.**

- out_file:

  Character; file path. output xfm file **Required.**

- args:

  Character. Additional parameters to the command

- atlas:

  Character. alternate target atlas (in freesurfer/average dir)

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
