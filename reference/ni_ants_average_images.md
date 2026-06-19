# ANTS AverageImages

Examples

## Usage

``` r
ni_ants_average_images(
  dimension,
  images,
  normalize,
  args = NULL,
  output_average_image = "average.nii",
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- dimension:

  Character; one of: "3", "2". image dimension (2 or 3) **Required.**

- images:

  Character or numeric vector. image to apply transformation to
  (generally a coregistered functional) **Required.**

- normalize:

  Logical. Normalize: if true, the 2nd image is divided by its mean.
  This will select the largest image to average into. **Required.**

- args:

  Character. Additional parameters to the command

- output_average_image:

  Character; file path. the name of the resulting image.

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
