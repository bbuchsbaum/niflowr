# ANTS ComposeMultiTransform

Take a set of transformations and convert them to a single
transformation matrix/warpfield.

## Usage

``` r
ni_ants_compose_multi_transform(
  transforms,
  args = NULL,
  dimension = 3,
  output_transform = NULL,
  reference_image = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- transforms:

  Character or numeric vector. transforms to average **Required.**

- args:

  Character. Additional parameters to the command

- dimension:

  Character; one of: "3", "2". image dimension (2 or 3)

- output_transform:

  Character; file path. the name of the resulting transform.

- reference_image:

  Character; file path. Reference image (only necessary when output is
  warpfield)

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
