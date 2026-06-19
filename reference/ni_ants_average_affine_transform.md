# ANTS AverageAffineTransform

Examples

## Usage

``` r
ni_ants_average_affine_transform(
  dimension,
  output_affine_transform,
  transforms,
  args = NULL,
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

- output_affine_transform:

  Character; file path. Outputfname.txt: the name of the resulting
  transform. **Required.**

- transforms:

  Character or numeric vector. transforms to average **Required.**

- args:

  Character. Additional parameters to the command

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
