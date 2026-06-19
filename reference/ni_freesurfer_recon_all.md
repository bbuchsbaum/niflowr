# FREESURFER ReconAll

Uses recon-all to generate surfaces and parcellations of structural data

## Usage

``` r
ni_freesurfer_recon_all(
  FLAIR_file = NULL,
  T1_files = NULL,
  T2_file = NULL,
  args = NULL,
  base_template_id = NULL,
  base_timepoint_ids = NULL,
  big_ventricles = NULL,
  brainstem = NULL,
  directive = "all",
  expert = NULL,
  flags = NULL,
  hemi = NULL,
  hippocampal_subfields_T1 = NULL,
  hippocampal_subfields_T2 = NULL,
  hires = NULL,
  longitudinal_template_id = NULL,
  longitudinal_timepoint_id = NULL,
  mprage = NULL,
  openmp = NULL,
  parallel = NULL,
  subject_id = NULL,
  subjects_dir = NULL,
  use_FLAIR = NULL,
  use_T2 = NULL,
  xopts = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- FLAIR_file:

  Character; file path. Convert FLAIR image to orig directory

- T1_files:

  Character or numeric vector. name of T1 file to process

- T2_file:

  Character; file path. Convert T2 image to orig directory

- args:

  Character. Additional parameters to the command

- base_template_id:

  Character. base template id

- base_timepoint_ids:

  Character or numeric vector. processed timepoint to use in template

- big_ventricles:

  Logical. For use in subjects with enlarged ventricles

- brainstem:

  Logical. Segment brainstem structures

- directive:

  Character; one of: "all", "autorecon1", "autorecon2",
  "autorecon2-volonly", "autorecon2-perhemi", "autorecon2-inflate1",
  "autorecon2-cp", "autorecon2-wm", "autorecon3", "autorecon3-T2pial",
  "autorecon-pial", "autorecon-hemi", "localGI", "qcache". process
  directive

- expert:

  Character; file path. Set parameters using expert file

- flags:

  Character or numeric vector. additional parameters

- hemi:

  Character; one of: "lh", "rh". hemisphere to process

- hippocampal_subfields_T1:

  Logical. segment hippocampal subfields using input T1 scan

- hippocampal_subfields_T2:

  Character or numeric vector. segment hippocampal subfields using T2
  scan, identified by ID (may be combined with hippocampal_subfields_T1)

- hires:

  Logical. Conform to minimum voxel size (for voxels \< 1mm)

- longitudinal_template_id:

  Character. longitudinal base template id

- longitudinal_timepoint_id:

  Character. longitudinal session/timepoint id

- mprage:

  Logical. Assume scan parameters are MGH MP-RAGE protocol, which
  produces darker gray matter

- openmp:

  Integer. Number of processors to use in parallel

- parallel:

  Logical. Enable parallel execution

- subject_id:

  Character. subject name

- subjects_dir:

  Character; directory path. path to subjects directory

- use_FLAIR:

  Logical. Use FLAIR image to refine the pial surface

- use_T2:

  Logical. Use T2 image to refine the pial surface

- xopts:

  Character; one of: "use", "clean", "overwrite". Use, delete or
  overwrite existing expert options file

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
