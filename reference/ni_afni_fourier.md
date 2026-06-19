# AFNI Fourier

Program to lowpass and/or highpass each voxel time series in a

## Usage

``` r
ni_afni_fourier(
  highpass,
  in_file,
  lowpass,
  args = NULL,
  out_file = NULL,
  retrend = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- highpass:

  Numeric. highpass **Required.**

- in_file:

  Character; file path. input file to 3dFourier **Required.**

- lowpass:

  Numeric. lowpass **Required.**

- args:

  Character. Additional parameters to the command

- out_file:

  Character; file path. output image file name

- retrend:

  Logical. Any mean and linear trend are removed before filtering. This
  will restore the trend after filtering.

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
