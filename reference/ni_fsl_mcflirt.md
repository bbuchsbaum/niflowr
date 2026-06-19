# FSL MCFLIRT

FSL MCFLIRT wrapper for within-modality motion correction

## Usage

``` r
ni_fsl_mcflirt(
  in_file,
  args = NULL,
  bins = NULL,
  cost = NULL,
  dof = NULL,
  init = NULL,
  interpolation = NULL,
  mean_vol = NULL,
  out_file = NULL,
  ref_file = NULL,
  ref_vol = NULL,
  rotation = NULL,
  save_mats = NULL,
  save_plots = NULL,
  save_rms = NULL,
  scaling = NULL,
  smooth = NULL,
  stages = NULL,
  stats_imgs = NULL,
  use_contour = NULL,
  use_gradient = NULL,
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

  Character; file path. timeseries to motion-correct **Required.**

- args:

  Character. Additional parameters to the command

- bins:

  Integer. number of histogram bins

- cost:

  Character; one of: "mutualinfo", "woods", "corratio", "normcorr",
  "normmi", "leastsquares". cost function to optimize

- dof:

  Integer. degrees of freedom for the transformation

- init:

  Character; file path. initial transformation matrix

- interpolation:

  Character; one of: "spline", "nn", "sinc". interpolation method for
  transformation

- mean_vol:

  Logical. register to mean volume

- out_file:

  Character; file path. file to write

- ref_file:

  Character; file path. target image for motion correction

- ref_vol:

  Integer. volume to align frames to

- rotation:

  Integer. scaling factor for rotation tolerances

- save_mats:

  Logical. save transformation matrices

- save_plots:

  Logical. save transformation parameters

- save_rms:

  Logical. save rms displacement parameters

- scaling:

  Numeric. scaling factor to use

- smooth:

  Numeric. smoothing factor for the cost function

- stages:

  Integer. stages (if 4, perform final search with sinc interpolation

- stats_imgs:

  Logical. produce variance and std. dev. images

- use_contour:

  Logical. run search on contour images

- use_gradient:

  Logical. run search on gradient images

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
