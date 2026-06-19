# FSL Smooth

Use fslmaths to smooth the image

## Usage

``` r
ni_fsl_smooth(
  fwhm,
  in_file,
  sigma,
  args = NULL,
  smoothed_file = NULL,
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

  Numeric. gaussian kernel fwhm, will be converted to sigma in mm (not
  voxels) **Required.**

- in_file:

  Character; file path **Required.**

- sigma:

  Numeric. gaussian kernel sigma in mm (not voxels) **Required.**

- args:

  Character. Additional parameters to the command

- smoothed_file:

  Character; file path

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
