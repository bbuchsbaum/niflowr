# FREESURFER Aparc2Aseg

Maps the cortical labels from the automatic cortical parcellation

## Usage

``` r
ni_freesurfer_aparc2_aseg(
  lh_annotation,
  lh_pial,
  lh_ribbon,
  lh_white,
  out_file,
  rh_annotation,
  rh_pial,
  rh_ribbon,
  rh_white,
  ribbon,
  subject_id,
  a2009s = NULL,
  args = NULL,
  aseg = NULL,
  ctxseg = NULL,
  hypo_wm = NULL,
  label_wm = NULL,
  rip_unknown = NULL,
  volmask = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- lh_annotation:

  Character; file path. Input file must be
  \<subject_id\>/label/lh.aparc.annot **Required.**

- lh_pial:

  Character; file path. Input file must be \<subject_id\>/surf/lh.pial
  **Required.**

- lh_ribbon:

  Character; file path. Input file must be
  \<subject_id\>/mri/lh.ribbon.mgz **Required.**

- lh_white:

  Character; file path. Input file must be \<subject_id\>/surf/lh.white
  **Required.**

- out_file:

  Character; file path. Full path of file to save the output
  segmentation in **Required.**

- rh_annotation:

  Character; file path. Input file must be
  \<subject_id\>/label/rh.aparc.annot **Required.**

- rh_pial:

  Character; file path. Input file must be \<subject_id\>/surf/rh.pial
  **Required.**

- rh_ribbon:

  Character; file path. Input file must be
  \<subject_id\>/mri/rh.ribbon.mgz **Required.**

- rh_white:

  Character; file path. Input file must be \<subject_id\>/surf/rh.white
  **Required.**

- ribbon:

  Character; file path. Input file must be \<subject_id\>/mri/ribbon.mgz
  **Required.**

- subject_id:

  Character. Subject being processed **Required.**

- a2009s:

  Logical. Using the a2009s atlas

- args:

  Character. Additional parameters to the command

- aseg:

  Character; file path. Input aseg file

- ctxseg:

  Character; file path

- hypo_wm:

  Logical. Label hypointensities as WM

- label_wm:

  Logical. For each voxel labeled as white matter in the aseg, re-assign
  its label to be that of the closest cortical point if its distance is
  less than dmaxctx.

- rip_unknown:

  Logical. Do not label WM based on 'unknown' corical label

- volmask:

  Logical. Volume mask flag

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
