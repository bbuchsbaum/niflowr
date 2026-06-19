# FREESURFER RobustRegister

Perform intramodal linear registration (translation and rotation) using

## Usage

``` r
ni_freesurfer_robust_register(
  auto_sens,
  outlier_sens,
  source_file,
  target_file,
  args = NULL,
  est_int_scale = NULL,
  force_double = NULL,
  force_float = NULL,
  half_source = NULL,
  half_source_xfm = NULL,
  half_targ = NULL,
  half_targ_xfm = NULL,
  half_weights = NULL,
  high_iterations = NULL,
  in_xfm_file = NULL,
  init_orient = NULL,
  iteration_thresh = NULL,
  least_squares = NULL,
  mask_source = NULL,
  mask_target = NULL,
  max_iterations = NULL,
  no_init = NULL,
  no_multi = NULL,
  out_reg_file = TRUE,
  outlier_limit = NULL,
  registered_file = NULL,
  subsample_thresh = NULL,
  trans_only = NULL,
  weights_file = NULL,
  write_vo2vox = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- auto_sens:

  Logical. auto-detect good sensitivity **Required.**

- outlier_sens:

  Numeric. set outlier sensitivity explicitly **Required.**

- source_file:

  Character; file path. volume to be registered **Required.**

- target_file:

  Character; file path. target volume for the registration **Required.**

- args:

  Character. Additional parameters to the command

- est_int_scale:

  Logical. estimate intensity scale (recommended for unnormalized
  images)

- force_double:

  Logical. use double-precision intensities

- force_float:

  Logical. use float intensities

- half_source:

  Character or numeric vector. write source volume mapped to halfway
  space

- half_source_xfm:

  Character or numeric vector. write transform from source to halfway
  space

- half_targ:

  Character or numeric vector. write target volume mapped to halfway
  space

- half_targ_xfm:

  Character or numeric vector. write transform from target to halfway
  space

- half_weights:

  Character or numeric vector. write weights volume mapped to halfway
  space

- high_iterations:

  Integer. max \# of times on highest resolution

- in_xfm_file:

  Character; file path. use initial transform on source

- init_orient:

  Logical. use moments for initial orient (recommended for stripped
  brains)

- iteration_thresh:

  Numeric. stop iterations when below threshold

- least_squares:

  Logical. use least squares instead of robust estimator

- mask_source:

  Character; file path. image to mask source volume with

- mask_target:

  Character; file path. image to mask target volume with

- max_iterations:

  Integer. maximum \# of times on each resolution

- no_init:

  Logical. skip transform init

- no_multi:

  Logical. work on highest resolution

- out_reg_file:

  Character or numeric vector. registration file; either True or
  filename

- outlier_limit:

  Numeric. set maximal outlier limit in satit

- registered_file:

  Character or numeric vector. registered image; either True or filename

- subsample_thresh:

  Integer. subsample if dimension is above threshold size

- trans_only:

  Logical. find 3 parameter translation only

- weights_file:

  Character or numeric vector. weights image to write; either True or
  filename

- write_vo2vox:

  Logical. output vox2vox matrix (default is RAS2RAS)

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
