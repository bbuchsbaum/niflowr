# FREESURFER ApplyMask

Use Freesurfer's mri_mask to apply a mask to an image.

## Usage

``` r
ni_freesurfer_apply_mask(
  in_file,
  mask_file,
  args = NULL,
  invert_xfm = NULL,
  keep_mask_deletion_edits = NULL,
  mask_thresh = NULL,
  out_file = NULL,
  transfer = NULL,
  use_abs = NULL,
  xfm_file = NULL,
  xfm_source = NULL,
  xfm_target = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- in_file:

  Character; file path. input image (will be masked) **Required.**

- mask_file:

  Character; file path. image defining mask space **Required.**

- args:

  Character. Additional parameters to the command

- invert_xfm:

  Logical. invert transformation

- keep_mask_deletion_edits:

  Logical. transfer voxel-deletion edits (voxels=1) from mask to out vol

- mask_thresh:

  Numeric. threshold mask before applying

- out_file:

  Character; file path. final image to write

- transfer:

  Integer. transfer only voxel value \# from mask to out

- use_abs:

  Logical. take absolute value of mask before applying

- xfm_file:

  Character; file path. LTA-format transformation matrix to align mask
  with input

- xfm_source:

  Character; file path. image defining transform source space

- xfm_target:

  Character; file path. image defining transform target space

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
