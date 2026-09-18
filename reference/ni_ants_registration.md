# ANTS Registration

ANTs Registration command for registration of images

## Usage

``` r
ni_ants_registration(
  fixed_image,
  metric,
  metric_weight = 1,
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
  transform_parameters = NULL,
  number_of_iterations = NULL,
  convergence_threshold = NULL,
  convergence_window_size = NULL,
  radius_or_number_of_bins = NULL,
  sampling_strategy = NULL,
  sampling_percentage = NULL,
  use_histogram_matching = NULL,
  output_warped_image = NULL,
  output_inverse_warped_image = NULL,
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
  weights must sum to 1 per stage.

- moving_image:

  Character or numeric vector. Image that will be registered to the
  space of fixed_image. This is theimage on which the transformations
  will be applied to **Required.**

- shrink_factors:

  Character or numeric vector **Required.**

- smoothing_sigmas:

  Character or numeric vector **Required.**

- transforms:

  Character or numeric vector. Transform for each stage, in order: a
  bare name such as Rigid, Affine, or SyN (parameters from
  transform_parameters, else 0.1 for linear and 0.1,3,0 for deformable
  transforms), or a complete bracketed token such as SyN\[0.2,3,0\] that
  is passed through unchanged. **Required.**

- args:

  Character. Extra global antsRegistration arguments, appended once
  after all stages. Use the per-stage inputs for stage settings.

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

  Character; file path

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

  Numeric. Lower quantile for clipping image intensities before
  registration (0 disables the lower clip).

- winsorize_upper_quantile:

  Numeric. Upper quantile for clipping image intensities before
  registration (1 disables the upper clip).

- write_composite_transform:

  Logical

- transform_parameters:

  Character or numeric vector. Per-stage transform parameters as
  comma-separated strings, e.g. c("0.1", "0.1", "0.1,3,0") for Rigid,
  Affine, SyN (gradient step, update field variance, total field
  variance). One value per stage, or a single value applied to every
  stage.

- number_of_iterations:

  Character or numeric vector. Per-stage iterations for each resolution
  level, e.g. "1000x500x250x100"; the level count must match
  shrink_factors. Defaults to a 1000x500x250x100... ladder truncated to
  the stage's levels. One value per stage, or a single value applied to
  every stage.

- convergence_threshold:

  Character or numeric vector. Per-stage convergence threshold (default
  1e-6). One value per stage, or a single value applied to every stage.

- convergence_window_size:

  Character or numeric vector. Per-stage convergence window size
  (default 10). One value per stage, or a single value applied to every
  stage.

- radius_or_number_of_bins:

  Character or numeric vector. Per-stage number of histogram bins for MI
  and Mattes metrics, or neighbourhood radius for CC (defaults: 32 for
  MI/Mattes, 4 for CC, 1 for GC). One value per stage, or a single value
  applied to every stage.

- sampling_strategy:

  Character or numeric vector. Per-stage metric sampling strategy:
  "None", "Regular", or "Random". Omitted means antsRegistration's dense
  default. One value per stage, or a single value applied to every
  stage.

- sampling_percentage:

  Character or numeric vector. Per-stage fraction of voxels sampled by
  the metric, in (0, 1\]; requires sampling_strategy. One value per
  stage, or a single value applied to every stage.

- use_histogram_matching:

  Logical. Histogram-match the images before registration.
  antsRegistration applies a single setting to every stage. Omitted
  leaves antsRegistration's default.

- output_warped_image:

  Character; file path. Path for the moving image resampled into the
  fixed image space.

- output_inverse_warped_image:

  Character; file path. Path for the fixed image resampled into the
  moving image space; requires output_warped_image.

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
