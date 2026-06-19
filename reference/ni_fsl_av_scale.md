# FSL AvScale

Use FSL avscale command to extract info from mat file output of FLIRT

## Usage

``` r
ni_fsl_av_scale(
  all_param = NULL,
  args = NULL,
  mat_file = NULL,
  ref_file = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- all_param:

  Logical

- args:

  Character. Additional parameters to the command

- mat_file:

  Character; file path. mat file to read

- ref_file:

  Character; file path. reference file to get center of rotation

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
