# AFNI TNorm

Shifts voxel time series from input so that separate slices are aligned

## Usage

``` r
ni_afni_t_norm(
  in_file,
  L1fit = NULL,
  args = NULL,
  norm1 = NULL,
  norm2 = NULL,
  normR = NULL,
  normx = NULL,
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

  Character; file path. input file to 3dTNorm **Required.**

- L1fit:

  Logical. Detrend with L1 regression (L2 is the default) This option is
  here just for the hell of it

- args:

  Character. Additional parameters to the command

- norm1:

  Logical. L1 normalize (sum of absolute values = 1)

- norm2:

  Logical. L2 normalize (sum of squares = 1) \[DEFAULT\]

- normR:

  Logical. normalize so sum of squares = number of time points \\ e.g.,
  so RMS = 1.

- normx:

  Logical. Scale so max absolute value = 1 (L_infinity norm)

- out_file:

  Character; file path. output image file name

- polort:

  Integer. Detrend with polynomials of order p before normalizing
  \[DEFAULT = don't do this\]. Use '-polort 0' to remove the mean, for
  example

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
