# FREESURFER ApplyVolTransform

Use FreeSurfer mri_vol2vol to apply a transform.

## Usage

``` r
ni_freesurfer_apply_vol_transform(
  fs_target = NULL,
  fsl_reg_file = NULL,
  lta_file = NULL,
  lta_inv_file = NULL,
  mni_152_reg = NULL,
  reg_file = NULL,
  reg_header = NULL,
  source_file,
  subject = NULL,
  tal = NULL,
  target_file = NULL,
  xfm_reg_file = NULL,
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

  Logical. use orig.mgz from subject in regfile as target **Required
  unless an alternative is supplied:** `target_file`, `tal`.

- fsl_reg_file:

  Character; file path. fslRAS-to-fslRAS matrix (FSL format) **Required
  unless an alternative is supplied:** `reg_file`, `lta_file`,
  `lta_inv_file`, `xfm_reg_file`, `reg_header`, `mni_152_reg`,
  `subject`.

- lta_file:

  Character; file path. Linear Transform Array file **Required unless an
  alternative is supplied:** `reg_file`, `lta_inv_file`, `fsl_reg_file`,
  `xfm_reg_file`, `reg_header`, `mni_152_reg`, `subject`.

- lta_inv_file:

  Character; file path. LTA, invert **Required unless an alternative is
  supplied:** `reg_file`, `lta_file`, `fsl_reg_file`, `xfm_reg_file`,
  `reg_header`, `mni_152_reg`, `subject`.

- mni_152_reg:

  Logical. target MNI152 space **Required unless an alternative is
  supplied:** `reg_file`, `lta_file`, `lta_inv_file`, `fsl_reg_file`,
  `xfm_reg_file`, `reg_header`, `subject`.

- reg_file:

  Character; file path. tkRAS-to-tkRAS matrix (tkregister2 format)
  **Required unless an alternative is supplied:** `lta_file`,
  `lta_inv_file`, `fsl_reg_file`, `xfm_reg_file`, `reg_header`,
  `mni_152_reg`, `subject`.

- reg_header:

  Logical. ScannerRAS-to-ScannerRAS matrix = identity **Required unless
  an alternative is supplied:** `reg_file`, `lta_file`, `lta_inv_file`,
  `fsl_reg_file`, `xfm_reg_file`, `mni_152_reg`, `subject`.

- source_file:

  Character; file path. Input volume you wish to transform **Required.**

- subject:

  Character. set matrix = identity and use subject for any templates
  **Required unless an alternative is supplied:** `reg_file`,
  `lta_file`, `lta_inv_file`, `fsl_reg_file`, `xfm_reg_file`,
  `reg_header`, `mni_152_reg`.

- tal:

  Logical. map to a sub FOV of MNI305 (with –reg only) **Required unless
  an alternative is supplied:** `target_file`, `fs_target`.

- target_file:

  Character; file path. Output template volume **Required unless an
  alternative is supplied:** `tal`, `fs_target`.

- xfm_reg_file:

  Character; file path. ScannerRAS-to-ScannerRAS matrix (MNI format)
  **Required unless an alternative is supplied:** `reg_file`,
  `lta_file`, `lta_inv_file`, `fsl_reg_file`, `reg_header`,
  `mni_152_reg`, `subject`.

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
