# ANTS Registration

ANTs Registration command for registration of images

## Usage

``` r
ni_ants_registration(
  fixed_image,
  metric,
  metric_weight,
  moving_image,
  shrink_factors,
  smoothing_sigmas,
  transforms,
  args = NULL,
  collapse_output_transforms = TRUE,
  dimension = 3,
  fixed_image_mask = NULL,
  float = NULL,
  initial_moving_transform = NULL,
  initial_moving_transform_com = NULL,
  initialize_transforms_per_stage = FALSE,
  interpolation = "Linear",
  output_transform_prefix = "transform",
  random_seed = NULL,
  restore_state = NULL,
  save_state = NULL,
  verbose = FALSE,
  winsorize_lower_quantile = 0,
  winsorize_upper_quantile = 1,
  write_composite_transform = FALSE,
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

  Character or numeric vector. Image to which the moving_image should be
  transformed(usually a structural image) **Required.**

- metric:

  Character or numeric vector. the metric(s) to use for each stage. Note
  that multiple metrics per stage are not supported in ANTS 1.9.1 and
  earlier. **Required.**

- metric_weight:

  Character or numeric vector. the metric weight(s) for each stage. The
  weights must sum to 1 per stage. **Required.**

- moving_image:

  Character or numeric vector. Image that will be registered to the
  space of fixed_image. This is theimage on which the transformations
  will be applied to **Required.**

- shrink_factors:

  Character or numeric vector **Required.**

- smoothing_sigmas:

  Character or numeric vector **Required.**

- transforms:

  Character or numeric vector **Required.**

- args:

  Character. Additional parameters to the command

- collapse_output_transforms:

  Logical. Collapse output transforms. Specifically, enabling this
  option combines all adjacent linear transforms and composes all
  adjacent displacement field transforms before writing the results to
  disk.

- dimension:

  Character; one of: "3", "2". image dimension (2 or 3)

- fixed_image_mask:

  Character; file path. Mask used to limit metric sampling region of the
  fixed imagein all stages

- float:

  Logical. Use float instead of double for computations.

- initial_moving_transform:

  Character or numeric vector. A transform or a list of transforms that
  should be applied before the registration begins. Note that, when a
  list is given, the transformations are applied in reverse order.

- initial_moving_transform_com:

  Character; one of: "0", "1", "2". Align the moving_image and
  fixed_image before registration using the geometric center of the
  images (=0), the image intensities (=1), or the origin of the images
  (=2).

- initialize_transforms_per_stage:

  Logical. Initialize linear transforms from the previous stage. By
  enabling this option, the current linear stage transform is directly
  initialized from the previous stages linear transform; this allows
  multiple linear stages to be run where each stage directly updates the
  estimated linear transform from the previous stage. (e.g. Translation
  -\> Rigid -\> Affine).

- interpolation:

  Character; one of: "Linear", "NearestNeighbor", "CosineWindowedSinc",
  "WelchWindowedSinc", "HammingWindowedSinc", "LanczosWindowedSinc",
  "BSpline", "MultiLabel", "Gaussian", "GenericLabel"

- output_transform_prefix:

  Character

- random_seed:

  Integer. Fixed seed for random number generation

- restore_state:

  Character; file path. Filename for restoring the internal restorable
  state of the registration

- save_state:

  Character; file path. Filename for saving the internal restorable
  state of the registration

- verbose:

  Logical

- winsorize_lower_quantile:

  Character. The Lower quantile to clip image ranges

- winsorize_upper_quantile:

  Character. The Upper quantile to clip image ranges

- write_composite_transform:

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
