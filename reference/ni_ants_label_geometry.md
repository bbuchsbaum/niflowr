# ANTS LabelGeometry

Extracts geometry measures using a label file and an optional image file

## Usage

``` r
ni_ants_label_geometry(
  intensity_image,
  label_image,
  args = NULL,
  dimension = 3,
  output_file = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- intensity_image:

  Character; file path. Intensity image to extract values from. This is
  an optional input **Required.**

- label_image:

  Character; file path. label image to use for extracting geometry
  measures **Required.**

- args:

  Character. Additional parameters to the command

- dimension:

  Character; one of: "3", "2". image dimension (2 or 3)

- output_file:

  Character. name of output file

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
