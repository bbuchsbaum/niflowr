# FREESURFER MRISPreprocReconAll

Extends MRISPreproc to allow it to be used in a recon-all workflow

## Usage

``` r
ni_freesurfer_mris_preproc_recon_all(
  hemi,
  target,
  args = NULL,
  fsgd_file = NULL,
  fwhm = NULL,
  fwhm_source = NULL,
  num_iters = NULL,
  num_iters_source = NULL,
  out_file = NULL,
  proj_frac = NULL,
  smooth_cortex_only = NULL,
  source_format = NULL,
  subject_file = NULL,
  subject_id = "subject_id",
  subjects = NULL,
  surf_area = NULL,
  surf_dir = NULL,
  surf_measure = NULL,
  surf_measure_file = NULL,
  surfreg_files = NULL,
  vol_measure_file = NULL,
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

  Character; one of: "lh", "rh". hemisphere for source and target
  **Required.**

- target:

  Character. target subject name **Required.**

- args:

  Character. Additional parameters to the command

- fsgd_file:

  Character; file path. specify subjects using fsgd file

- fwhm:

  Numeric. smooth by fwhm mm on the target surface

- fwhm_source:

  Numeric. smooth by fwhm mm on the source surface

- num_iters:

  Integer. niters : smooth by niters on the target surface

- num_iters_source:

  Integer. niters : smooth by niters on the source surface

- out_file:

  Character; file path. output filename

- proj_frac:

  Numeric. projection fraction for vol2surf

- smooth_cortex_only:

  Logical. only smooth cortex (ie, exclude medial wall)

- source_format:

  Character. source format

- subject_file:

  Character; file path. file specifying subjects separated by white
  space

- subject_id:

  Character. subject from whom measures are calculated

- subjects:

  Character or numeric vector. subjects from who measures are calculated

- surf_area:

  Character. Extract vertex area from subject/surf/hemi.surfname to use
  as input.

- surf_dir:

  Character. alternative directory (instead of surf)

- surf_measure:

  Character. Use subject/surf/hemi.surf_measure as input

- surf_measure_file:

  Character; file path. file necessary for surfmeas

- surfreg_files:

  Character or numeric vector. lh and rh input surface registration
  files

- vol_measure_file:

  Character or numeric vector. list of volume measure and reg file
  tuples

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
