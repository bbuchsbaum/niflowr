# FREESURFER SurfaceSmooth

Smooth a surface image with mri_surf2surf.

## Usage

``` r
ni_freesurfer_surface_smooth(
  hemi,
  in_file,
  subject_id,
  args = NULL,
  cortex = TRUE,
  fwhm = NULL,
  out_file = NULL,
  reshape = NULL,
  smooth_iters = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- hemi:

  Character; one of: "lh", "rh". hemisphere to operate on **Required.**

- in_file:

  Character; file path. source surface file **Required.**

- subject_id:

  Character. subject id of surface file **Required.**

- args:

  Character. Additional parameters to the command

- cortex:

  Logical. only smooth within `$hemi.cortex.label`

- fwhm:

  Numeric. effective FWHM of the smoothing process

- out_file:

  Character; file path. surface file to write

- reshape:

  Logical. reshape surface vector to fit in non-mgh format

- smooth_iters:

  Integer. iterations of the smoothing process

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
