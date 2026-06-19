# AFNI BlurToFWHM

Blurs a 'master' dataset until it reaches a specified FWHM smoothness

## Usage

``` r
ni_afni_blur_to_fwhm(
  in_file,
  args = NULL,
  automask = NULL,
  blurmaster = NULL,
  fwhm = NULL,
  fwhmxy = NULL,
  mask = NULL,
  out_file = NULL,
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

  Character; file path. The dataset that will be smoothed **Required.**

- args:

  Character. Additional parameters to the command

- automask:

  Logical. Create an automask from the input dataset.

- blurmaster:

  Character; file path. The dataset whose smoothness controls the
  process.

- fwhm:

  Numeric. Blur until the 3D FWHM reaches this value (in mm)

- fwhmxy:

  Numeric. Blur until the 2D (x,y)-plane FWHM reaches this value (in mm)

- mask:

  Character; file path. Mask dataset, if desired. Voxels NOT in mask
  will be set to zero in output.

- out_file:

  Character; file path. output image file name

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
