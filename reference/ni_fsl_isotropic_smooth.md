# FSL IsotropicSmooth

Use fslmaths to spatially smooth an image with a gaussian kernel.

## Usage

``` r
ni_fsl_isotropic_smooth(
  fwhm = NULL,
  in_file,
  sigma = NULL,
  args = NULL,
  internal_datatype = NULL,
  nan2zeros = NULL,
  out_file = NULL,
  output_datatype = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- fwhm:

  Numeric. fwhm of smoothing kernel \[mm\] **Required unless an
  alternative is supplied:** `sigma`.

- in_file:

  Character; file path. image to operate on **Required.**

- sigma:

  Numeric. sigma of smoothing kernel \[mm\] **Required unless an
  alternative is supplied:** `fwhm`.

- args:

  Character. Additional parameters to the command

- internal_datatype:

  Character; one of: "float", "char", "int", "short", "double", "input".
  datatype to use for calculations (default is float)

- nan2zeros:

  Logical. change NaNs to zeros before doing anything

- out_file:

  Character; file path. image to write

- output_datatype:

  Character; one of: "float", "char", "int", "short", "double", "input".
  datatype to use for output (default uses input type)

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
