# AFNI CenterMass

Computes center of mass using 3dCM command

## Usage

``` r
ni_afni_center_mass(
  in_file,
  all_rois = NULL,
  args = NULL,
  automask = NULL,
  cm_file = NULL,
  local_ijk = NULL,
  mask_file = NULL,
  roi_vals = NULL,
  set_cm = NULL,
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

  Character; file path. input file to 3dCM **Required.**

- all_rois:

  Logical. Don't bother listing the values of ROIs you want: The program
  will find all of them and produce a full list

- args:

  Character. Additional parameters to the command

- automask:

  Logical. Generate the mask automatically

- cm_file:

  Character; file path. File to write center of mass to

- local_ijk:

  Logical. Output values as (i,j,k) in local orientation

- mask_file:

  Character; file path. Only voxels with nonzero values in the provided
  mask will be averaged.

- roi_vals:

  Character or numeric vector. Compute center of mass for each blob with
  voxel value of v0, v1, v2, etc. This option is handy for getting ROI
  centers of mass.

- set_cm:

  Character or numeric vector. After computing the center of mass, set
  the origin fields in the header so that the center of mass will be at
  (x,y,z) in DICOM coords.

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
