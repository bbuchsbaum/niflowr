# FREESURFER MRIsCALabel

For a single subject, produces an annotation file, in which each

## Usage

``` r
ni_freesurfer_mr_is_ca_label(
  canonsurf,
  classifier,
  curv,
  hemisphere,
  smoothwm,
  subject_id,
  sulc,
  args = NULL,
  aseg = NULL,
  label = NULL,
  out_file = NULL,
  seed = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- canonsurf:

  Character; file path. Input canonical surface file **Required.**

- classifier:

  Character; file path. Classifier array input file **Required.**

- curv:

  Character; file path. implicit input {hemisphere}.curv **Required.**

- hemisphere:

  Character; one of: "lh", "rh". Hemisphere ('lh' or 'rh') **Required.**

- smoothwm:

  Character; file path. implicit input {hemisphere}.smoothwm
  **Required.**

- subject_id:

  Character. Subject name or ID **Required.**

- sulc:

  Character; file path. implicit input {hemisphere}.sulc **Required.**

- args:

  Character. Additional parameters to the command

- aseg:

  Character; file path. Undocumented flag. Autorecon3 uses
  ../mri/aseg.presurf.mgz as input file

- label:

  Character; file path. Undocumented flag. Autorecon3 uses
  ../label/{hemisphere}.cortex.label as input file

- out_file:

  Character; file path. Annotated surface output file

- seed:

  Integer

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
