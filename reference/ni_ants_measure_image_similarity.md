# ANTS MeasureImageSimilarity

Examples

## Usage

``` r
ni_ants_measure_image_similarity(
  fixed_image,
  metric,
  moving_image,
  radius_or_number_of_bins,
  sampling_percentage,
  args = NULL,
  dimension = NULL,
  fixed_image_mask = NULL,
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

  Integer. The number of bins in each stage for the MI and Mattes
  metric, or the radius for other metrics **Required.**

- sampling_percentage:

  Character. Percentage of points accessible to the sampling strategy
  over which to optimize the metric. **Required.**

- args:

  Character. Additional parameters to the command

- dimension:

  Character; one of: "2", "3", "4". Dimensionality of the fixed/moving
  image pair

- fixed_image_mask:

  Character; file path. mask used to limit metric sampling region of the
  fixed image

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
