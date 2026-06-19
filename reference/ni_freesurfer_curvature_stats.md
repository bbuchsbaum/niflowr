# FREESURFER CurvatureStats

In its simplest usage, 'mris_curvature_stats' will compute a set

## Usage

``` r
ni_freesurfer_curvature_stats(
  curvfile1,
  curvfile2,
  hemisphere,
  subject_id,
  args = NULL,
  min_max = NULL,
  out_file = NULL,
  surface = NULL,
  values = NULL,
  write = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- curvfile1:

  Character; file path. Input file for CurvatureStats **Required.**

- curvfile2:

  Character; file path. Input file for CurvatureStats **Required.**

- hemisphere:

  Character; one of: "lh", "rh". Hemisphere being processed
  **Required.**

- subject_id:

  Character. Subject being processed **Required.**

- args:

  Character. Additional parameters to the command

- min_max:

  Logical. Output min / max information for the processed curvature.

- out_file:

  Character; file path. Output curvature stats file

- surface:

  Character; file path. Specify surface file for CurvatureStats

- values:

  Logical. Triggers a series of derived curvature values

- write:

  Logical. Write curvature files

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
