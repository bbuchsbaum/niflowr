# FSL FLIRT

FSL FLIRT wrapper for coregistration

## Usage

``` r
ni_fsl_flirt(
  in_file,
  reference,
  angle_rep = NULL,
  apply_isoxfm = NULL,
  apply_xfm = NULL,
  args = NULL,
  bbrslope = NULL,
  bbrtype = NULL,
  bgvalue = NULL,
  bins = NULL,
  coarse_search = NULL,
  cost = NULL,
  cost_func = NULL,
  datatype = NULL,
  display_init = NULL,
  dof = NULL,
  echospacing = NULL,
  fieldmap = NULL,
  fieldmapmask = NULL,
  fine_search = NULL,
  force_scaling = NULL,
  in_matrix_file = NULL,
  in_weight = NULL,
  interp = NULL,
  min_sampling = NULL,
  no_clamp = NULL,
  no_resample = NULL,
  no_resample_blur = NULL,
  no_search = NULL,
  out_file = NULL,
  out_matrix_file = NULL,
  padding_size = NULL,
  pedir = NULL,
  ref_weight = NULL,
  rigid2D = NULL,
  schedule = NULL,
  searchr_x = NULL,
  searchr_y = NULL,
  searchr_z = NULL,
  sinc_width = NULL,
  sinc_window = NULL,
  uses_qform = NULL,
  verbose = NULL,
  wm_seg = NULL,
  wmcoords = NULL,
  wmnorms = NULL,
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

  Character; file path. input file **Required.**

- reference:

  Character; file path. reference file **Required.**

- angle_rep:

  Character; one of: "quaternion", "euler". representation of rotation
  angles

- apply_isoxfm:

  Numeric. as applyxfm but forces isotropic resampling

- apply_xfm:

  Logical. apply transformation supplied by in_matrix_file or uses_qform
  to use the affine matrix stored in the reference header

- args:

  Character. Additional parameters to the command

- bbrslope:

  Numeric. value of bbr slope

- bbrtype:

  Character; one of: "signed", "global_abs", "local_abs". type of bbr
  cost function: signed \[default\], global_abs, local_abs

- bgvalue:

  Numeric. use specified background value for points outside FOV

- bins:

  Integer. number of histogram bins

- coarse_search:

  Integer. coarse search delta angle

- cost:

  Character; one of: "mutualinfo", "corratio", "normcorr", "normmi",
  "leastsq", "labeldiff", "bbr". cost function

- cost_func:

  Character; one of: "mutualinfo", "corratio", "normcorr", "normmi",
  "leastsq", "labeldiff", "bbr". cost function

- datatype:

  Character; one of: "char", "short", "int", "float", "double". force
  output data type

- display_init:

  Logical. display initial matrix

- dof:

  Integer. number of transform degrees of freedom

- echospacing:

  Numeric. value of EPI echo spacing - units of seconds

- fieldmap:

  Character; file path. fieldmap image in rads/s - must be already
  registered to the reference image

- fieldmapmask:

  Character; file path. mask for fieldmap image

- fine_search:

  Integer. fine search delta angle

- force_scaling:

  Logical. force rescaling even for low-res images

- in_matrix_file:

  Character; file path. input 4x4 affine matrix

- in_weight:

  Character; file path. File for input weighting volume

- interp:

  Character; one of: "trilinear", "nearestneighbour", "sinc", "spline".
  final interpolation method used in reslicing

- min_sampling:

  Numeric. set minimum voxel dimension for sampling

- no_clamp:

  Logical. do not use intensity clamping

- no_resample:

  Logical. do not change input sampling

- no_resample_blur:

  Logical. do not use blurring on downsampling

- no_search:

  Logical. set all angular searches to ranges 0 to 0

- out_file:

  Character; file path. registered output file

- out_matrix_file:

  Character; file path. output affine matrix in 4x4 asciii format

- padding_size:

  Integer. for applyxfm: interpolates outside image by size

- pedir:

  Integer. phase encode direction of EPI - 1/2/3=x/y/z &
  -1/-2/-3=-x/-y/-z

- ref_weight:

  Character; file path. File for reference weighting volume

- rigid2D:

  Logical. use 2D rigid body mode - ignores dof

- schedule:

  Character; file path. replaces default schedule

- searchr_x:

  Character or numeric vector. search angles along x-axis, in degrees

- searchr_y:

  Character or numeric vector. search angles along y-axis, in degrees

- searchr_z:

  Character or numeric vector. search angles along z-axis, in degrees

- sinc_width:

  Integer. full-width in voxels

- sinc_window:

  Character; one of: "rectangular", "hanning", "blackman". sinc window

- uses_qform:

  Logical. initialize using sform or qform

- verbose:

  Integer. verbose mode, 0 is least

- wm_seg:

  Character; file path. white matter segmentation volume needed by BBR
  cost function

- wmcoords:

  Character; file path. white matter boundary coordinates for BBR cost
  function

- wmnorms:

  Character; file path. white matter boundary normals for BBR cost
  function

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
