# ANTS ApplyTransforms

ApplyTransforms, applied to an input image, transforms it according to a

## Usage

``` r
ni_ants_apply_transforms(
  input_image,
  reference_image,
  transforms,
  args = NULL,
  default_value = 0,
  dimension = NULL,
  float = FALSE,
  input_image_type = NULL,
  interpolation = "Linear",
  output_image = NULL,
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

- reference_image:

  Character; file path. reference image space that you wish to warp INTO
  **Required.**

- transforms:

  Character or numeric vector. transform files: will be applied in
  reverse order. For example, the last specified transform will be
  applied first. **Required.**

- args:

  Character. Additional parameters to the command

- default_value:

  Numeric

- dimension:

  Character; one of: "2", "3", "4". This option forces the image to be
  treated as a specified-dimensional image. If not specified, antsWarp
  tries to infer the dimensionality from the input image.

- float:

  Logical. Use float instead of double for computations.

- input_image_type:

  Character; one of: "0", "1", "2", "3". Option specifying the input
  image type of scalar (default), vector, tensor, or time series.

- interpolation:

  Character; one of: "Linear", "NearestNeighbor", "CosineWindowedSinc",
  "WelchWindowedSinc", "HammingWindowedSinc", "LanczosWindowedSinc",
  "MultiLabel", "Gaussian", "BSpline", "GenericLabel"

- output_image:

  Character. output file name

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
