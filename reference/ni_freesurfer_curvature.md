# FREESURFER Curvature

This program will compute the second fundamental form of a cortical

## Usage

``` r
ni_freesurfer_curvature(
  in_file,
  args = NULL,
  averages = NULL,
  distances = NULL,
  n = NULL,
  save = NULL,
  threshold = NULL,
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

  Character; file path. Input file for Curvature **Required.**

- args:

  Character. Additional parameters to the command

- averages:

  Integer. Perform this number iterative averages of curvature measure
  before saving

- distances:

  Character or numeric vector. Undocumented input integer distances

- n:

  Logical. Undocumented boolean flag

- save:

  Logical. Save curvature files (will only generate screen output
  without this option)

- threshold:

  Numeric. Undocumented input threshold

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
