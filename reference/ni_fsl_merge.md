# FSL Merge

Use fslmerge to concatenate images

## Usage

``` r
ni_fsl_merge(
  dimension,
  in_files,
  args = NULL,
  merged_file = NULL,
  tr = NULL,
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

  Character; one of: "t", "x", "y", "z", "a". dimension along which to
  merge, optionally set tr input when dimension is t **Required.**

- in_files:

  Character or numeric vector **Required.**

- args:

  Character. Additional parameters to the command

- merged_file:

  Character; file path

- tr:

  Numeric. use to specify TR in seconds (default is 1.00 sec), overrides
  dimension and sets it to tr

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
