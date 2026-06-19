# FSL ImageMeants

Use fslmeants for printing the average timeseries (intensities) to

## Usage

``` r
ni_fsl_image_meants(
  in_file,
  args = NULL,
  eig = NULL,
  mask = NULL,
  nobin = NULL,
  order = 1,
  out_file = NULL,
  show_all = NULL,
  spatial_coord = NULL,
  transpose = NULL,
  use_mm = NULL,
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

  Character; file path. input file for computing the average timeseries
  **Required.**

- args:

  Character. Additional parameters to the command

- eig:

  Logical. calculate Eigenvariate(s) instead of mean (output will have 0
  mean)

- mask:

  Character; file path. input 3D mask

- nobin:

  Logical. do not binarise the mask for calculation of Eigenvariates

- order:

  Integer. select number of Eigenvariates

- out_file:

  Character; file path. name of output text matrix

- show_all:

  Logical. show all voxel time series (within mask) instead of averaging

- spatial_coord:

  Character or numeric vector. requested spatial coordinate (instead of
  mask)

- transpose:

  Logical. output results in transpose format (one row per voxel/mean)

- use_mm:

  Logical. use mm instead of voxel coordinates (for -c option)

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
