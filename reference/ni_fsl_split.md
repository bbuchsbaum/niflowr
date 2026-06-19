# FSL Split

Uses FSL Fslsplit command to separate a volume into images in

## Usage

``` r
ni_fsl_split(
  dimension,
  in_file,
  args = NULL,
  out_base_name = NULL,
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

  Character; one of: "t", "x", "y", "z". dimension along which the file
  will be split **Required.**

- in_file:

  Character; file path. input filename **Required.**

- args:

  Character. Additional parameters to the command

- out_base_name:

  Character. outputs prefix

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
