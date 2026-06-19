# FREESURFER RemoveIntersection

This program removes the intersection of the given MRI

## Usage

``` r
ni_freesurfer_remove_intersection(
  in_file,
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

- in_file:

  Character; file path. Input file for RemoveIntersection **Required.**

- args:

  Character. Additional parameters to the command

- out_file:

  Character; file path. Output file for RemoveIntersection

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
