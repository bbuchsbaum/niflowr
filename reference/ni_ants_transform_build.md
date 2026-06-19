# ANTs Composite Transform Build

High-level transform-build surface: registers a moving image to a fixed
image with a preset staged antsRegistration pipeline and writes a
composite .h5 transform (plus its inverse and a warped QC image) with
deterministic, prefix-derived output paths.

## Usage

``` r
ni_ants_transform_build(
  fixed_image,
  moving_image,
  output_prefix,
  preset = "rigid_affine_syn",
  fixed_mask = NULL,
  moving_mask = NULL,
  random_seed = NULL,
  precision = "double",
  dimension = 3,
  interpolation = "Linear",
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- fixed_image:

  Character; file path. Fixed (target / reference) image the moving
  image is registered into. **Required.**

- moving_image:

  Character; file path. Moving (source) image to register into the fixed
  image space. **Required.**

- output_prefix:

  Character. Prefix prepended to all generated artifacts (e.g.
  'Composite.h5'). **Required.**

- preset:

  Character; one of: "rigid_affine_syn", "rigid_affine", "rigid",
  "affine". Registration preset expanded into staged antsRegistration
  transforms.

- fixed_mask:

  Character; file path. Optional mask restricting metric sampling in the
  fixed image.

- moving_mask:

  Character; file path. Optional mask restricting metric sampling in the
  moving image.

- random_seed:

  Integer. Fixed seed for deterministic, reproducible registration.

- precision:

  Character; one of: "double", "float". Computation precision; 'float'
  is faster and lower-memory.

- dimension:

  Character; one of: "3", "2". Image dimensionality.

- interpolation:

  Character; one of: "Linear", "NearestNeighbor", "BSpline",
  "CosineWindowedSinc", "WelchWindowedSinc", "HammingWindowedSinc",
  "LanczosWindowedSinc", "Gaussian", "GenericLabel". Interpolation used
  when resampling the warped QC image.

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
