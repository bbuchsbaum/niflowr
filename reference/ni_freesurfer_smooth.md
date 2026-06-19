# FREESURFER Smooth

Use FreeSurfer mris_volsmooth to smooth a volume

## Usage

``` r
ni_freesurfer_smooth(
  in_file,
  num_iters,
  reg_file,
  surface_fwhm,
  args = NULL,
  proj_frac = NULL,
  proj_frac_avg = NULL,
  smoothed_file = NULL,
  vol_fwhm = NULL,
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

  Character; file path. source volume **Required.**

- num_iters:

  Character. number of iterations instead of fwhm **Required.**

- reg_file:

  Character; file path. registers volume to surface anatomical
  **Required.**

- surface_fwhm:

  Character. surface FWHM in mm **Required.**

- args:

  Character. Additional parameters to the command

- proj_frac:

  Numeric. project frac of thickness a long surface normal

- proj_frac_avg:

  Character or numeric vector. average a long normal min max delta

- smoothed_file:

  Character; file path. output volume

- vol_fwhm:

  Character. volume smoothing outside of surface

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
