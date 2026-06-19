# FREESURFER VolumeMask

Computes a volume mask, at the same resolution as the

## Usage

``` r
ni_freesurfer_volume_mask(
  left_ribbonlabel,
  left_whitelabel,
  lh_pial,
  lh_white,
  rh_pial,
  rh_white,
  right_ribbonlabel,
  right_whitelabel,
  subject_id,
  args = NULL,
  in_aseg = NULL,
  save_ribbon = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- left_ribbonlabel:

  Integer. Left cortical ribbon label **Required.**

- left_whitelabel:

  Integer. Left white matter label **Required.**

- lh_pial:

  Character; file path. Implicit input left pial surface **Required.**

- lh_white:

  Character; file path. Implicit input left white matter surface
  **Required.**

- rh_pial:

  Character; file path. Implicit input right pial surface **Required.**

- rh_white:

  Character; file path. Implicit input right white matter surface
  **Required.**

- right_ribbonlabel:

  Integer. Right cortical ribbon label **Required.**

- right_whitelabel:

  Integer. Right white matter label **Required.**

- subject_id:

  Character. Subject being processed **Required.**

- args:

  Character. Additional parameters to the command

- in_aseg:

  Character; file path. Input aseg file for VolumeMask

- save_ribbon:

  Logical. option to save just the ribbon for the hemispheres in the
  format ?h.ribbon.mgz

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
