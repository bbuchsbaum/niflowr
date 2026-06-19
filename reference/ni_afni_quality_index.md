# AFNI QualityIndex

Computes a quality index for each sub-brick in a 3D+time dataset.

## Usage

``` r
ni_afni_quality_index(
  in_file,
  args = NULL,
  autoclip = FALSE,
  automask = FALSE,
  clip = NULL,
  interval = FALSE,
  mask = NULL,
  out_file = NULL,
  quadrant = FALSE,
  spearman = FALSE,
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

  Character; file path. input dataset **Required.**

- args:

  Character. Additional parameters to the command

- autoclip:

  Logical. clip off small voxels

- automask:

  Logical. clip off small voxels

- clip:

  Numeric. clip off values below

- interval:

  Logical. write out the median + 3.5 MAD of outlier count with each
  timepoint

- mask:

  Character; file path. compute correlation only across masked voxels

- out_file:

  Character; file path. capture standard output

- quadrant:

  Logical. Similar to -spearman, but using 1 minus the quadrant
  correlation coefficient as the quality index.

- spearman:

  Logical. Quality index is 1 minus the Spearman (rank) correlation
  coefficient of each sub-brick with the median sub-brick. (default).

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
