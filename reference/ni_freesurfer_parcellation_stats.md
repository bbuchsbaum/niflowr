# FREESURFER ParcellationStats

This program computes a number of anatomical properties.

## Usage

``` r
ni_freesurfer_parcellation_stats(
  aseg,
  brainmask,
  hemisphere,
  lh_pial,
  lh_white,
  rh_pial,
  rh_white,
  ribbon,
  subject_id,
  thickness,
  transform,
  wm,
  args = NULL,
  in_annotation = NULL,
  in_cortex = NULL,
  in_label = NULL,
  mgz = NULL,
  out_color = NULL,
  out_table = NULL,
  surface = NULL,
  tabular_output = NULL,
  th3 = NULL,
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

  Character; file path. Input file must be
  \<subject_id\>/mri/aseg.presurf.mgz **Required.**

- brainmask:

  Character; file path. Input file must be
  \<subject_id\>/mri/brainmask.mgz **Required.**

- hemisphere:

  Character; one of: "lh", "rh". Hemisphere being processed
  **Required.**

- lh_pial:

  Character; file path. Input file must be \<subject_id\>/surf/lh.pial
  **Required.**

- lh_white:

  Character; file path. Input file must be \<subject_id\>/surf/lh.white
  **Required.**

- rh_pial:

  Character; file path. Input file must be \<subject_id\>/surf/rh.pial
  **Required.**

- rh_white:

  Character; file path. Input file must be \<subject_id\>/surf/rh.white
  **Required.**

- ribbon:

  Character; file path. Input file must be \<subject_id\>/mri/ribbon.mgz
  **Required.**

- subject_id:

  Character. Subject being processed **Required.**

- thickness:

  Character; file path. Input file must be
  \<subject_id\>/surf/?h.thickness **Required.**

- transform:

  Character; file path. Input file must be
  \<subject_id\>/mri/transforms/talairach.xfm **Required.**

- wm:

  Character; file path. Input file must be \<subject_id\>/mri/wm.mgz
  **Required.**

- args:

  Character. Additional parameters to the command

- in_annotation:

  Character; file path. compute properties for each label in the
  annotation file separately

- in_cortex:

  Character; file path. Input cortex label

- in_label:

  Character; file path. limit calculations to specified label

- mgz:

  Logical. Look for mgz files

- out_color:

  Character; file path. Output annotation files's colortable to text
  file

- out_table:

  Character; file path. Table output to tablefile

- surface:

  Character. Input surface (e.g. 'white')

- tabular_output:

  Logical. Tabular output

- th3:

  Logical. turns on new vertex-wise volume calc for mris_anat_stats

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
