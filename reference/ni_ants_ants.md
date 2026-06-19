# ANTS ANTS

ANTS wrapper for registration of images

## Usage

``` r
ni_ants_ants(
  fixed_image,
  metric,
  metric_weight,
  moving_image,
  output_transform_prefix,
  radius,
  transformation_model,
  affine_gradient_descent_option = NULL,
  args = NULL,
  dimension = NULL,
  mi_option = NULL,
  number_of_affine_iterations = NULL,
  number_of_iterations = NULL,
  regularization = NULL,
  smoothing_sigmas = NULL,
  subsampling_factors = NULL,
  use_histogram_matching = TRUE,
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

  Character or numeric vector. image to which the moving image is warped
  **Required.**

- metric:

  Character or numeric vector **Required.**

- metric_weight:

  Character or numeric vector. the metric weight(s) for each stage. The
  weights must sum to 1 per stage. **Required.**

- moving_image:

  Character or numeric vector. image to apply transformation to
  (generally a coregisteredfunctional) **Required.**

- output_transform_prefix:

  Character **Required.**

- radius:

  Character or numeric vector. radius of the region (i.e. number of
  layers around a voxel/pixel) that is used for computing cross
  correlation **Required.**

- transformation_model:

  Character; one of: "Diff", "Elast", "Exp", "Greedy Exp", "SyN"
  **Required.**

- affine_gradient_descent_option:

  Character or numeric vector

- args:

  Character. Additional parameters to the command

- dimension:

  Character; one of: "3", "2". image dimension (2 or 3)

- mi_option:

  Character or numeric vector

- number_of_affine_iterations:

  Character or numeric vector

- number_of_iterations:

  Character or numeric vector

- regularization:

  Character; one of: "Gauss", "DMFFD"

- smoothing_sigmas:

  Character or numeric vector

- subsampling_factors:

  Character or numeric vector

- use_histogram_matching:

  Logical

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
