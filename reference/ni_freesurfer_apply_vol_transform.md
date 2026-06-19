# FREESURFER ApplyVolTransform

Use FreeSurfer mri_vol2vol to apply a transform.

## Usage

``` r
ni_freesurfer_apply_vol_transform(
  fs_target,
  fsl_reg_file,
  lta_file,
  lta_inv_file,
  mni_152_reg,
  reg_file,
  reg_header,
  source_file,
  subject,
  tal,
  target_file,
  xfm_reg_file,
  args = NULL,
  interp = NULL,
  inverse = NULL,
  invert_morph = NULL,
  m3z_file = NULL,
  no_ded_m3z_path = NULL,
  no_resample = NULL,
  tal_resolution = NULL,
  transformed_file = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- fs_target:

  Logical. use orig.mgz from subject in regfile as target **Required.**

- fsl_reg_file:

  Character; file path. fslRAS-to-fslRAS matrix (FSL format)
  **Required.**

- lta_file:

  Character; file path. Linear Transform Array file **Required.**

- lta_inv_file:

  Character; file path. LTA, invert **Required.**

- mni_152_reg:

  Logical. target MNI152 space **Required.**

- reg_file:

  Character; file path. tkRAS-to-tkRAS matrix (tkregister2 format)
  **Required.**

- reg_header:

  Logical. ScannerRAS-to-ScannerRAS matrix = identity **Required.**

- source_file:

  Character; file path. Input volume you wish to transform **Required.**

- subject:

  Character. set matrix = identity and use subject for any templates
  **Required.**

- tal:

  Logical. map to a sub FOV of MNI305 (with –reg only) **Required.**

- target_file:

  Character; file path. Output template volume **Required.**

- xfm_reg_file:

  Character; file path. ScannerRAS-to-ScannerRAS matrix (MNI format)
  **Required.**

- args:

  Character. Additional parameters to the command

- interp:

  Character; one of: "trilin", "nearest", "cubic". Interpolation method
  ( or nearest)

- inverse:

  Logical. sample from target to source

- invert_morph:

  Logical. Compute and use the inverse of the non-linear morph to
  resample the input volume. To be used by –m3z.

- m3z_file:

  Character; file path. This is the morph to be applied to the volume.
  Unless the morph is in mri/transforms (eg.: for talairach.m3z computed
  by reconall), you will need to specify the full path to this morph and
  use the –noDefM3zPath flag.

- no_ded_m3z_path:

  Logical. To be used with the m3z flag. Instructs the code not to look
  for them3z morph in the default location
  (SUBJECTS_DIR/subj/mri/transforms), but instead just use the path
  indicated in –m3z.

- no_resample:

  Logical. Do not resample; just change vox2ras matrix

- tal_resolution:

  Numeric. Resolution to sample when using tal

- transformed_file:

  Character; file path. Output volume

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
