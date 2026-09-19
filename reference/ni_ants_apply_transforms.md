# ANTS ApplyTransforms

ApplyTransforms, applied to an input image, transforms it according to a

## Usage

``` r
ni_ants_apply_transforms(
  output_image,
  reference_image,
  transforms,
  args = NULL,
  default_value = 0,
  dimension = NULL,
  float = FALSE,
  input_image = NULL,
  input_image_type = NULL,
  interpolation = "Linear",
  invert_transform_flags = NULL,
  print_out_composite_warp_file = FALSE,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- output_image:

  Character; file path. Output image, or the composed displacement field
  when print_out_composite_warp_file is TRUE. **Required.**

- reference_image:

  Character; file path. reference image space that you wish to warp INTO
  **Required.**

- transforms:

  Character or numeric vector. Transform files, applied in reverse order
  (the last is applied first), as antsApplyTransforms expects.
  **Required.**

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

- input_image:

  Character; file path. Image to transform. Not needed when
  print_out_composite_warp_file writes the composed displacement field
  instead.

- input_image_type:

  Character; one of: "0", "1", "2", "3". Option specifying the input
  image type of scalar (default), vector, tensor, or time series.

- interpolation:

  Character; one of: "Linear", "NearestNeighbor", "CosineWindowedSinc",
  "WelchWindowedSinc", "HammingWindowedSinc", "LanczosWindowedSinc",
  "MultiLabel", "Gaussian", "BSpline", "GenericLabel". Interpolation for
  the output image; use NearestNeighbor or GenericLabel for masks and
  label images.

- invert_transform_flags:

  Logical vector. Whether to invert each transform, one logical per
  transform (linear transforms only).

- print_out_composite_warp_file:

  Logical. Write the composition of transforms as a displacement field
  on the reference grid instead of a transformed image.

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
