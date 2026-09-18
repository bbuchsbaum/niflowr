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
  sigma_units = NULL,
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

  Character or numeric vector. Fixed (reference) image. Images pair with
  the metrics within a stage, as in nipype: give one image for every
  metric, or one per metric of the stage with the most metrics (image j
  serves metric j, e.g. an intensity image and its Laplacian).
  **Required.**

- metric:

  Vector, or list with one element per stage (an element may itself be a
  vector). Metric for each stage (MI, Mattes, CC, MeanSquares, Demons,
  GC). A stage with several metrics is a vector inside a list, e.g.
  list("Mattes", "Mattes", c("Mattes", "CC")); ANTs combines them by
  metric_weight. **Required.**

- metric_weight:

  Vector, or list with one element per stage (an element may itself be a
  vector). Relative weight of each metric; antsRegistration normalises a
  stage's weights. One element per stage, or a single element for every
  stage. A multi-metric stage takes one weight per metric, e.g. list(1,
  1, c(0.5, 0.5)); a single value weights them equally.

- moving_image:

  Character or numeric vector. Moving image, registered into the fixed
  image's space. Pairs with metrics like fixed_image: one image, or one
  per metric. **Required.**

- shrink_factors:

  Vector, or list with one element per stage (an element may itself be a
  vector). Shrink factor per resolution level, each element as "8x4x2x1"
  or c(8, 4, 2, 1), e.g. list(c(2, 1), c(8, 4, 2, 1)). One element per
  stage, or a single element for every stage. **Required.**

- smoothing_sigmas:

  Vector, or list with one element per stage (an element may itself be a
  vector). Smoothing sigma per resolution level, each element as
  "3x2x1x0vox" or c(3, 2, 1, 0) with sigma_units. One element per stage,
  or a single element for every stage. **Required.**

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

  Vector, or list with one element per stage (an element may itself be a
  vector). Transform parameters, each element as "0.1,3,0" or c(0.1, 3,
  0), e.g. list(0.1, 0.1, c(0.1, 3, 0)) for Rigid, Affine, SyN (gradient
  step, update field variance, total field variance). A plain vector
  gives one number per stage. Defaults to 0.1 for linear and 0.1,3,0 for
  deformable transforms. One element per stage, or a single element for
  every stage.

- number_of_iterations:

  Vector, or list with one element per stage (an element may itself be a
  vector). Iterations per resolution level, each element as
  "100x70x50x20" or c(100, 70, 50, 20), e.g. list(c(100, 100), c(100,
  100), c(100, 70, 50, 20)); the level count must match shrink_factors.
  Defaults to a 1000x500x250x100... ladder truncated to the stage's
  levels. One element per stage, or a single element for every stage.

- convergence_threshold:

  Character or numeric vector. Per-stage convergence threshold (default
  1e-6). One value per stage, or a single value applied to every stage.

- convergence_window_size:

  Character or numeric vector. Per-stage convergence window size
  (default 10). One value per stage, or a single value applied to every
  stage.

- radius_or_number_of_bins:

  Vector, or list with one element per stage (an element may itself be a
  vector). Number of histogram bins for MI and Mattes, or neighbourhood
  radius for CC (defaults: 32 for MI/Mattes, 4 for CC, 1 for GC). One
  element per stage, or a single element for every stage. A stage mixing
  metric types takes one value per metric, e.g. list(56, 56, c(56, 4)).

- sampling_strategy:

  Vector, or list with one element per stage (an element may itself be a
  vector). Metric sampling strategy: "None", "Regular", or "Random"; NA
  omits sampling (antsRegistration's dense default). One element per
  stage, or a single element for every stage. antsRegistration samples
  every metric of a stage as its first metric says, so a multi-metric
  stage's entries must agree.

- sampling_percentage:

  Vector, or list with one element per stage (an element may itself be a
  vector). Fraction of voxels sampled by the metric, in (0, 1\];
  requires sampling_strategy, and NA omits it. One element per stage, or
  a single element for every stage. A multi-metric stage's entries must
  agree, as for sampling_strategy.

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

- sigma_units:

  Character or numeric vector. Units appended to smoothing_sigmas that
  do not already end in vox or mm. One element per stage, or a single
  element for every stage.

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
