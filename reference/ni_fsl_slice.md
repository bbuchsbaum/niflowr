# FSL Slice

Use fslslice to split a 3D file into lots of 2D files (along z-axis).

## Usage

``` r
ni_fsl_slice(
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
