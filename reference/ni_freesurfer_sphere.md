# FREESURFER Sphere

This program will add a template into an average surface

## Usage

``` r
ni_freesurfer_sphere(
  in_file,
  args = NULL,
  magic = NULL,
  out_file = NULL,
  seed = NULL,
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

  Character; file path. Input file for Sphere **Required.**

- args:

  Character. Additional parameters to the command

- magic:

  Logical. No documentation. Direct questions to
  analysis-bugs@nmr.mgh.harvard.edu

- out_file:

  Character; file path. Output file for Sphere

- seed:

  Integer. Seed for setting random number generator

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
