# AFNI FWHMx

Unlike the older 3dFWHM, this program computes FWHMs for all sub-bricks

## Usage

``` r
ni_afni_fwh_mx(
  in_file,
  acf = FALSE,
  args = NULL,
  arith = NULL,
  automask = FALSE,
  combine = NULL,
  compat = NULL,
  demed = NULL,
  detrend = FALSE,
  geom = NULL,
  mask = NULL,
  out_detrend = NULL,
  out_file = NULL,
  out_subbricks = NULL,
  unif = NULL,
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

- acf:

  Character. computes the spatial autocorrelation

- args:

  Character. Additional parameters to the command

- arith:

  Logical. if in_file has more than one sub-brick, compute the final
  estimate as the arithmetic mean of the individual sub-brick FWHM
  estimates

- automask:

  Logical. compute a mask from THIS dataset, a la 3dAutomask

- combine:

  Logical. combine the final measurements along each axis

- compat:

  Logical. be compatible with the older 3dFWHM

- demed:

  Logical. If the input dataset has more than one sub-brick (e.g., has a
  time axis), then subtract the median of each voxel's time series
  before processing FWHM. This will tend to remove intrinsic spatial
  structure and leave behind the noise.

- detrend:

  Character. instead of demed (0th order detrending), detrend to the
  specified order. If order is not given, the program picks q=NT/30.
  -detrend disables -demed, and includes -unif.

- geom:

  Logical. if in_file has more than one sub-brick, compute the final
  estimate as the geometric mean of the individual sub-brick FWHM
  estimates

- mask:

  Character; file path. use only voxels that are nonzero in mask

- out_detrend:

  Character; file path. Save the detrended file into a dataset

- out_file:

  Character; file path. output file

- out_subbricks:

  Character; file path. output file listing the subbricks FWHM

- unif:

  Logical. If the input dataset has more than one sub-brick, then
  normalize each voxel's time series to have the same MAD before
  processing FWHM.

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
