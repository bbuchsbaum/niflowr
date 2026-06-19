# ANTS ResampleImageBySpacing

Resample an image with a given spacing.

## Usage

``` r
ni_ants_resample_image_by_spacing(
  input_image,
  out_spacing,
  addvox = NULL,
  apply_smoothing = NULL,
  args = NULL,
  dimension = 3,
  nn_interp = NULL,
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

  Character; file path. input image file **Required.**

- out_spacing:

  Character or numeric vector. output spacing **Required.**

- addvox:

  Integer. addvox pads each dimension by addvox

- apply_smoothing:

  Logical. smooth before resampling

- args:

  Character. Additional parameters to the command

- dimension:

  Integer. dimension of output image

- nn_interp:

  Logical. nn interpolation

- output_image:

  Character; file path. output image file

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
