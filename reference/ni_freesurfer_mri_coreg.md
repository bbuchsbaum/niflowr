# FREESURFER MRICoreg

This program registers one volume to another

## Usage

``` r
ni_freesurfer_mri_coreg(
  reference_file,
  source_file,
  subject_id,
  args = NULL,
  brute_force_limit = NULL,
  brute_force_samples = NULL,
  conform_reference = NULL,
  dof = NULL,
  ftol = NULL,
  initial_rotation = NULL,
  initial_scale = NULL,
  initial_shear = NULL,
  initial_translation = NULL,
  linmintol = NULL,
  max_iters = NULL,
  no_brute_force = NULL,
  no_coord_dithering = NULL,
  no_cras0 = NULL,
  no_intensity_dithering = NULL,
  no_smooth = NULL,
  num_threads = NULL,
  out_lta_file = TRUE,
  out_params_file = NULL,
  out_reg_file = NULL,
  ref_fwhm = NULL,
  reference_mask = NULL,
  saturation_threshold = NULL,
  sep = NULL,
  source_mask = NULL,
  source_oob = NULL,
  subjects_dir = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- reference_file:

  Character; file path. reference (target) file **Required.**

- source_file:

  Character; file path. source file to be registered **Required.**

- subject_id:

  Character. freesurfer subject ID (implies
  `reference_mask == aparc+aseg.mgz` unless otherwise specified)
  **Required.**

- args:

  Character. Additional parameters to the command

- brute_force_limit:

  Numeric. constrain brute force search to +/- lim

- brute_force_samples:

  Integer. number of samples in brute force search

- conform_reference:

  Logical. conform reference without rescaling

- dof:

  Character; one of: "6", "9", "12". number of transform degrees of
  freedom

- ftol:

  Numeric. floating-point tolerance (default=1e-7)

- initial_rotation:

  Character or numeric vector. initial rotation in degrees

- initial_scale:

  Character or numeric vector. initial scale

- initial_shear:

  Character or numeric vector. initial shear (Hxy, Hxz, Hyz)

- initial_translation:

  Character or numeric vector. initial translation in mm (implies
  no_cras0)

- linmintol:

  Numeric

- max_iters:

  Character. maximum iterations (default: 4)

- no_brute_force:

  Logical. do not brute force search

- no_coord_dithering:

  Logical. turn off coordinate dithering

- no_cras0:

  Logical. do not set translation parameters to align centers of source
  and reference files

- no_intensity_dithering:

  Logical. turn off intensity dithering

- no_smooth:

  Logical. do not apply smoothing to either reference or source file

- num_threads:

  Integer. number of OpenMP threads

- out_lta_file:

  Character or numeric vector. output registration file (LTA format)

- out_params_file:

  Character or numeric vector. output parameters file

- out_reg_file:

  Character or numeric vector. output registration file (REG format)

- ref_fwhm:

  Numeric. apply smoothing to reference file

- reference_mask:

  Character or numeric vector. mask reference volume with given mask, or
  None if `False`

- saturation_threshold:

  Character. saturation threshold (default=9.999)

- sep:

  Character or numeric vector. set spatial scales, in voxels (default
  \[2, 4\])

- source_mask:

  Character. mask source file with given mask

- source_oob:

  Logical. count source voxels that are out-of-bounds as 0

- subjects_dir:

  Character; directory path. FreeSurfer SUBJECTS_DIR

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
