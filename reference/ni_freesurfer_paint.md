# FREESURFER Paint

This program is useful for extracting one of the arrays ("a variable")

## Usage

``` r
ni_freesurfer_paint(
  in_surf,
  template,
  args = NULL,
  averages = NULL,
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

- in_surf:

  Character; file path. Surface file with grid (vertices) onto which the
  template data is to be sampled or 'painted' **Required.**

- template:

  Character; file path. Template file **Required.**

- args:

  Character. Additional parameters to the command

- averages:

  Integer. Average curvature patterns

- out_file:

  Character; file path. File containing a surface-worth of per-vertex
  values, saved in 'curvature' format.

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
