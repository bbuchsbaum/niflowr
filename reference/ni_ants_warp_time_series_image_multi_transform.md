# ANTS WarpTimeSeriesImageMultiTransform

Warps a time-series from one space to another

## Usage

``` r
ni_ants_warp_time_series_image_multi_transform(
  input_image,
  transformation_series,
  args = NULL,
  dimension = 4,
  out_postfix = "_wtsimt",
  reference_image = NULL,
  reslice_by_header = NULL,
  tightest_box = NULL,
  use_bspline = NULL,
  use_nearest = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- input_image:

  Character; file path. image to apply transformation to (generally a
  coregistered functional) **Required.**

- transformation_series:

  Character or numeric vector. transformation file(s) to be applied
  **Required.**

- args:

  Character. Additional parameters to the command

- dimension:

  Character; one of: "4", "3". image dimension (3 or 4)

- out_postfix:

  Character. Postfix that is prepended to all output files (default =
  \_wtsimt)

- reference_image:

  Character; file path. reference image space that you wish to warp INTO

- reslice_by_header:

  Logical. Uses orientation matrix and origin encoded in reference image
  file header. Not typically used with additional transforms

- tightest_box:

  Logical. computes tightest bounding box (overridden by reference_image
  if given)

- use_bspline:

  Logical. Use 3rd order B-Spline interpolation

- use_nearest:

  Logical. Use nearest neighbor interpolation

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
