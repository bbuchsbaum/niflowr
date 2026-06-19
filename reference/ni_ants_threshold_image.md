# ANTS ThresholdImage

Apply thresholds on images.

## Usage

``` r
ni_ants_threshold_image(
  copy_header,
  input_image,
  args = NULL,
  dimension = 3,
  input_mask = NULL,
  inside_value = NULL,
  mode = NULL,
  num_thresholds = NULL,
  output_image = NULL,
  outside_value = NULL,
  th_high = NULL,
  th_low = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- copy_header:

  Logical. copy headers of the original image into the output
  (corrected) file **Required.**

- input_image:

  Character; file path. input image file **Required.**

- args:

  Character. Additional parameters to the command

- dimension:

  Integer. dimension of output image

- input_mask:

  Character; file path. input mask for Otsu, Kmeans

- inside_value:

  Numeric. inside value

- mode:

  Character; one of: "Otsu", "Kmeans". whether to run Otsu / Kmeans
  thresholding

- num_thresholds:

  Integer. number of thresholds

- output_image:

  Character; file path. output image file

- outside_value:

  Numeric. outside value

- th_high:

  Numeric. upper threshold

- th_low:

  Numeric. lower threshold

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
