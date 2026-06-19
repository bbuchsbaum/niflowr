# FREESURFER BBRegister

Use FreeSurfer bbregister to register a volume to the Freesurfer
anatomical.

## Usage

``` r
ni_freesurfer_bb_register(
  contrast_type,
  source_file,
  subject_id,
  args = NULL,
  dof = NULL,
  epi_mask = NULL,
  fsldof = NULL,
  init = NULL,
  init_cost_file = NULL,
  init_reg_file = NULL,
  intermediate_file = NULL,
  out_fsl_file = NULL,
  out_lta_file = NULL,
  out_reg_file = NULL,
  reg_frame = NULL,
  reg_middle_frame = NULL,
  registered_file = NULL,
  spm_nifti = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- contrast_type:

  Character; one of: "t1", "t2", "bold", "dti". contrast type of image
  **Required.**

- source_file:

  Character; file path. source file to be registered **Required.**

- subject_id:

  Character. freesurfer subject id **Required.**

- args:

  Character. Additional parameters to the command

- dof:

  Character; one of: "6", "9", "12". number of transform degrees of
  freedom

- epi_mask:

  Logical. mask out B0 regions in stages 1 and 2

- fsldof:

  Integer. degrees of freedom for initial registration (FSL)

- init:

  Character; one of: "coreg", "rr", "spm", "fsl", "header", "best".
  initialize registration with mri_coreg, spm, fsl, or header

- init_cost_file:

  Character or numeric vector. output initial registration cost file

- init_reg_file:

  Character; file path. existing registration file

- intermediate_file:

  Character; file path. Intermediate image, e.g. in case of partial FOV

- out_fsl_file:

  Character or numeric vector. write the transformation matrix in FSL
  FLIRT format

- out_lta_file:

  Character or numeric vector. write the transformation matrix in LTA
  format

- out_reg_file:

  Character; file path. output registration file

- reg_frame:

  Integer. 0-based frame index for 4D source file

- reg_middle_frame:

  Logical. Register middle frame of 4D source file

- registered_file:

  Character or numeric vector. output warped sourcefile either True or
  filename

- spm_nifti:

  Logical. force use of nifti rather than analyze with SPM

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
