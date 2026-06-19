# FREESURFER RelabelHypointensities

Relabel Hypointensities

## Usage

``` r
ni_freesurfer_relabel_hypointensities(
  aseg,
  lh_white,
  rh_white,
  args = NULL,
  out_file = NULL,
  surf_directory = ".",
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- aseg:

  Character; file path. Input aseg file **Required.**

- lh_white:

  Character; file path. Implicit input file must be lh.white
  **Required.**

- rh_white:

  Character; file path. Implicit input file must be rh.white
  **Required.**

- args:

  Character. Additional parameters to the command

- out_file:

  Character; file path. Output aseg file

- surf_directory:

  Character; directory path. Directory containing lh.white and rh.white

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
