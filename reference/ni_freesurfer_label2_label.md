# FREESURFER Label2Label

Converts a label in one subject's space to a label

## Usage

``` r
ni_freesurfer_label2_label(
  hemisphere,
  source_label,
  source_sphere_reg,
  source_subject,
  source_white,
  sphere_reg,
  subject_id,
  white,
  args = NULL,
  out_file = NULL,
  registration_method = "surface",
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- hemisphere:

  Character; one of: "lh", "rh". Input hemisphere **Required.**

- source_label:

  Character; file path. Source label **Required.**

- source_sphere_reg:

  Character; file path. Implicit input .sphere.reg **Required.**

- source_subject:

  Character. Source subject name **Required.**

- source_white:

  Character; file path. Implicit input .white **Required.**

- sphere_reg:

  Character; file path. Implicit input .sphere.reg **Required.**

- subject_id:

  Character. Target subject **Required.**

- white:

  Character; file path. Implicit input .white **Required.**

- args:

  Character. Additional parameters to the command

- out_file:

  Character; file path. Target label

- registration_method:

  Character; one of: "surface", "volume". Registration method

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
