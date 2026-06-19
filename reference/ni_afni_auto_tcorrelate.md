# AFNI AutoTcorrelate

Computes the correlation coefficient between the time series of each

## Usage

``` r
ni_afni_auto_tcorrelate(
  in_file,
  args = NULL,
  eta2 = NULL,
  mask = NULL,
  mask_only_targets = NULL,
  mask_source = NULL,
  out_file = NULL,
  polort = NULL,
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

  Character; file path. timeseries x space (volume or surface) file
  **Required.**

- args:

  Character. Additional parameters to the command

- eta2:

  Logical. eta^2 similarity

- mask:

  Character; file path. mask of voxels

- mask_only_targets:

  Logical. use mask only on targets voxels

- mask_source:

  Character; file path. mask for source voxels

- out_file:

  Character; file path. output image file name

- polort:

  Integer. Remove polynomial trend of order m or -1 for no detrending

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
