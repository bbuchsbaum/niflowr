# FREESURFER MRIPretess

Uses Freesurfer's mri_pretess to prepare volumes to be tessellated.

## Usage

``` r
ni_freesurfer_mri_pretess(
  in_filled,
  in_norm,
  label,
  args = NULL,
  keep = NULL,
  nocorners = NULL,
  out_file = NULL,
  test = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- in_filled:

  Character; file path. filled volume, usually wm.mgz **Required.**

- in_norm:

  Character; file path. the normalized, brain-extracted T1w image.
  Usually norm.mgz **Required.**

- label:

  Character or numeric vector. label to be picked up, can be a
  Freesurfer's string like 'wm' or a label value (e.g. 127 for rh or 255
  for lh) **Required.**

- args:

  Character. Additional parameters to the command

- keep:

  Logical. keep WM edits

- nocorners:

  Logical. do not remove corner configurations in addition to edge ones.

- out_file:

  Character; file path. the output file after mri_pretess.

- test:

  Logical. adds a voxel that should be removed by mri_pretess. The value
  of the voxel is set to that of an ON-edited WM, so it should be kept
  with -keep. The output will NOT be saved.

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
