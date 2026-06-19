# FREESURFER Jacobian

This program computes the Jacobian of a surface mapping.

## Usage

``` r
ni_freesurfer_jacobian(
  in_mappedsurf,
  in_origsurf,
  args = NULL,
  out_file = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- in_mappedsurf:

  Character; file path. Mapped surface **Required.**

- in_origsurf:

  Character; file path. Original surface **Required.**

- args:

  Character. Additional parameters to the command

- out_file:

  Character; file path. Output Jacobian of the surface mapping

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
