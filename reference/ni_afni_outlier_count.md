# AFNI OutlierCount

Calculates number of 'outliers' at each time point of a

## Usage

``` r
ni_afni_outlier_count(
  in_file,
  args = NULL,
  autoclip = FALSE,
  automask = FALSE,
  fraction = FALSE,
  interval = FALSE,
  legendre = FALSE,
  mask = NULL,
  outliers_file = NULL,
  polort = NULL,
  qthr = 0.001,
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

  Character; file path. input dataset **Required.**

- args:

  Character. Additional parameters to the command

- autoclip:

  Logical. clip off small voxels

- automask:

  Logical. clip off small voxels

- fraction:

  Logical. write out the fraction of masked voxels which are outliers at
  each timepoint

- interval:

  Logical. write out the median + 3.5 MAD of outlier count with each
  timepoint

- legendre:

  Logical. use Legendre polynomials

- mask:

  Character; file path. only count voxels within the given mask

- outliers_file:

  Character; file path. output image file name

- polort:

  Integer. detrend each voxel timeseries with polynomials

- qthr:

  Character. indicate a value for q to compute alpha

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
