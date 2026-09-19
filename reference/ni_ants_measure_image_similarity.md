# ANTS MeasureImageSimilarity

Examples

## Usage

``` r
ni_ants_measure_image_similarity(
  fixed_image,
  metric,
  moving_image,
  radius_or_number_of_bins,
  args = NULL,
  dimension = 3,
  fixed_image_mask = NULL,
  sampling_percentage = NULL,
  metric_weight = 1,
  sampling_strategy = NULL,
  moving_image_mask = NULL,
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

  Character; file path. Image to which the moving image is warped
  **Required.**

- metric:

  Character; one of: "CC", "MI", "Mattes", "MeanSquares", "Demons", "GC"
  **Required.**

- moving_image:

  Character; file path. Image to apply transformation to (generally a
  coregistered functional) **Required.**

- radius_or_number_of_bins:

  Integer. Number of histogram bins for MI and Mattes, or neighbourhood
  radius for CC. **Required.**

- args:

  Character. Additional parameters to the command

- dimension:

  Character; one of: "2", "3", "4". Dimensionality of the fixed/moving
  image pair

- fixed_image_mask:

  Character; file path. Mask limiting the voxels the metric considers,
  in fixed-image space. MeasureImageSimilarity ignores a mask it cannot
  read, so the path must exist.

- sampling_percentage:

  Numeric. Fraction of voxels sampled, in (0, 1\]; requires
  sampling_strategy.

- metric_weight:

  Numeric. Metric weight (not used by MeasureImageSimilarity; kept for
  the metric token).

- sampling_strategy:

  Character; one of: "None", "Regular", "Random". Metric sampling
  strategy; omitted means dense sampling (one sample per voxel).

- moving_image_mask:

  Character; file path. Mask in moving-image space; requires
  fixed_image_mask.

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
