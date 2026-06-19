# FREESURFER SmoothTessellation

Smooth a tessellated surface.

## Usage

``` r
ni_freesurfer_smooth_tessellation(
  in_file,
  args = NULL,
  curvature_averaging_iterations = NULL,
  disable_estimates = NULL,
  gaussian_curvature_norm_steps = NULL,
  gaussian_curvature_smoothing_steps = NULL,
  normalize_area = NULL,
  out_area_file = NULL,
  out_curvature_file = NULL,
  out_file = NULL,
  seed = NULL,
  smoothing_iterations = NULL,
  snapshot_writing_iterations = NULL,
  use_gaussian_curvature_smoothing = NULL,
  use_momentum = NULL,
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

  Character; file path. Input volume to tessellate voxels from.
  **Required.**

- args:

  Character. Additional parameters to the command

- curvature_averaging_iterations:

  Integer. Number of curvature averaging iterations (default=10)

- disable_estimates:

  Logical. Disables the writing of curvature and area estimates

- gaussian_curvature_norm_steps:

  Integer. Use Gaussian curvature smoothing

- gaussian_curvature_smoothing_steps:

  Integer. Use Gaussian curvature smoothing

- normalize_area:

  Logical. Normalizes the area after smoothing

- out_area_file:

  Character; file path. Write area to `?h.areaname` (default "area")

- out_curvature_file:

  Character; file path. Write curvature to `?h.curvname` (default
  "curv")

- out_file:

  Character; file path. output filename or True to generate one

- seed:

  Integer. Seed for setting random number generator

- smoothing_iterations:

  Integer. Number of smoothing iterations (default=10)

- snapshot_writing_iterations:

  Integer. Write snapshot every *n* iterations

- use_gaussian_curvature_smoothing:

  Logical. Use Gaussian curvature smoothing

- use_momentum:

  Logical. Uses momentum

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
