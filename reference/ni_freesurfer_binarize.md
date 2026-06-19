# FREESURFER Binarize

Use FreeSurfer mri_binarize to threshold an input volume

## Usage

``` r
ni_freesurfer_binarize(
  in_file,
  abs = NULL,
  args = NULL,
  bin_col_num = NULL,
  bin_val = NULL,
  bin_val_not = NULL,
  binary_file = NULL,
  count_file = NULL,
  dilate = NULL,
  erode = NULL,
  erode2d = NULL,
  frame_no = NULL,
  invert = NULL,
  mask_file = NULL,
  mask_thresh = NULL,
  match = NULL,
  max = NULL,
  merge_file = NULL,
  min = NULL,
  rmax = NULL,
  rmin = NULL,
  ventricles = NULL,
  wm = NULL,
  wm_ven_csf = NULL,
  zero_edges = NULL,
  zero_slice_edge = NULL,
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

  Character; file path. input volume **Required.**

- abs:

  Logical. take abs of invol first (ie, make unsigned)

- args:

  Character. Additional parameters to the command

- bin_col_num:

  Logical. set binarized voxel value to its column number

- bin_val:

  Integer. set vox within thresh to val (default is 1)

- bin_val_not:

  Integer. set vox outside range to val (default is 0)

- binary_file:

  Character; file path. binary output volume

- count_file:

  Character or numeric vector. save number of hits in ascii file (hits,
  ntotvox, pct)

- dilate:

  Integer. niters: dilate binarization in 3D

- erode:

  Integer. nerode: erode binarization in 3D (after any dilation)

- erode2d:

  Integer. nerode2d: erode binarization in 2D (after any 3D erosion)

- frame_no:

  Integer. use 0-based frame of input (default is 0)

- invert:

  Logical. set binval=0, binvalnot=1

- mask_file:

  Character; file path. must be within mask

- mask_thresh:

  Numeric. set thresh for mask

- match:

  Character or numeric vector. match instead of threshold

- max:

  Numeric. max thresh

- merge_file:

  Character; file path. merge with mergevol

- min:

  Numeric. min thresh

- rmax:

  Numeric. compute max based on rmax\*globalmean

- rmin:

  Numeric. compute min based on rmin\*globalmean

- ventricles:

  Logical. set match vals those for aseg ventricles+choroid (not 4th)

- wm:

  Logical. set match vals to 2 and 41 (aseg for cerebral WM)

- wm_ven_csf:

  Logical. WM and ventricular CSF, including choroid (not 4th)

- zero_edges:

  Logical. zero the edge voxels

- zero_slice_edge:

  Logical. zero the edge slice voxels

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
