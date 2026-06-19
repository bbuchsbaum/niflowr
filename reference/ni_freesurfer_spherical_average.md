# FREESURFER SphericalAverage

This program will add a template into an average surface.

## Usage

``` r
ni_freesurfer_spherical_average(
  fname,
  hemisphere,
  in_surf,
  subject_id,
  which,
  args = NULL,
  erode = NULL,
  in_average = NULL,
  in_orig = NULL,
  out_file = NULL,
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

- fname:

  Character. Filename from the average subject directory. Example: to
  use rh.entorhinal.label as the input label filename, set fname to
  'rh.entorhinal' and which to 'label'. The program will then search for
  `<in_average>/label/rh.entorhinal.label` **Required.**

- hemisphere:

  Character; one of: "lh", "rh". Input hemisphere **Required.**

- in_surf:

  Character; file path. Input surface file **Required.**

- subject_id:

  Character. Output subject id **Required.**

- which:

  Character; one of: "coords", "label", "vals", "curv", "area". No
  documentation **Required.**

- args:

  Character. Additional parameters to the command

- erode:

  Integer. Undocumented

- in_average:

  Character; directory path. Average subject

- in_orig:

  Character; file path. Original surface filename

- out_file:

  Character; file path. Output filename

- threshold:

  Numeric. Undocumented

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
