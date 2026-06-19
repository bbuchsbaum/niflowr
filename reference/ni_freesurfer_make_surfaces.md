# FREESURFER MakeSurfaces

This program positions the tessellation of the cortical surface at the

## Usage

``` r
ni_freesurfer_make_surfaces(
  hemisphere,
  in_filled,
  in_orig,
  in_wm,
  subject_id,
  args = NULL,
  fix_mtl = NULL,
  in_T1 = NULL,
  in_aseg = NULL,
  longitudinal = NULL,
  maximum = NULL,
  mgz = NULL,
  no_white = NULL,
  noaparc = NULL,
  orig_pial = NULL,
  orig_white = NULL,
  white = NULL,
  white_only = NULL,
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

  Character; one of: "lh", "rh". Hemisphere being processed
  **Required.**

- in_filled:

  Character; file path. Implicit input file filled.mgz **Required.**

- in_orig:

  Character; file path. Implicit input file .orig **Required.**

- in_wm:

  Character; file path. Implicit input file wm.mgz **Required.**

- subject_id:

  Character. Subject being processed **Required.**

- args:

  Character. Additional parameters to the command

- fix_mtl:

  Logical. Undocumented flag

- in_T1:

  Character; file path. Input brain or T1 file

- in_aseg:

  Character; file path. Input segmentation file

- longitudinal:

  Logical. No documentation (used for longitudinal processing)

- maximum:

  Numeric. No documentation (used for longitudinal processing)

- mgz:

  Logical. No documentation. Direct questions to
  analysis-bugs@nmr.mgh.harvard.edu

- no_white:

  Logical. Undocumented flag

- noaparc:

  Logical. No documentation. Direct questions to
  analysis-bugs@nmr.mgh.harvard.edu

- orig_pial:

  Character; file path. Specify a pial surface to start with

- orig_white:

  Character; file path. Specify a white surface to start with

- white:

  Character. White surface name

- white_only:

  Logical. Undocumented flag

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
