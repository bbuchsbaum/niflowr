# FSL ProbTrackX2

Use FSL probtrackx2 for tractography on bedpostx results

## Usage

``` r
ni_fsl_prob_track_x2(
  fsamples,
  mask,
  phsamples,
  seed,
  thsamples,
  args = NULL,
  avoid_mp = NULL,
  c_thresh = NULL,
  colmask4 = NULL,
  correct_path_distribution = NULL,
  dist_thresh = NULL,
  distthresh1 = NULL,
  distthresh3 = NULL,
  fibst = NULL,
  fopd = NULL,
  force_dir = TRUE,
  inv_xfm = NULL,
  loop_check = NULL,
  lrtarget3 = NULL,
  meshspace = NULL,
  mod_euler = NULL,
  n_samples = 5000,
  n_steps = NULL,
  network = NULL,
  omatrix1 = NULL,
  omatrix2 = NULL,
  omatrix3 = NULL,
  omatrix4 = NULL,
  onewaycondition = NULL,
  opd = TRUE,
  os2t = NULL,
  out_dir = NULL,
  rand_fib = NULL,
  random_seed = NULL,
  s2tastext = NULL,
  sample_random_points = NULL,
  samples_base_name = "merged",
  seed_ref = NULL,
  simple = NULL,
  step_length = NULL,
  stop_mask = NULL,
  target2 = NULL,
  target3 = NULL,
  target4 = NULL,
  target_masks = NULL,
  use_anisotropy = NULL,
  verbose = NULL,
  waycond = NULL,
  wayorder = NULL,
  waypoints = NULL,
  xfm = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- fsamples:

  Character or numeric vector **Required.**

- mask:

  Character; file path. bet binary mask file in diffusion space
  **Required.**

- phsamples:

  Character or numeric vector **Required.**

- seed:

  Character or numeric vector. seed volume(s), or voxel(s) or freesurfer
  label file **Required.**

- thsamples:

  Character or numeric vector **Required.**

- args:

  Character. Additional parameters to the command

- avoid_mp:

  Character; file path. reject pathways passing through locations given
  by this mask

- c_thresh:

  Numeric. curvature threshold - default=0.2

- colmask4:

  Character; file path. Mask for columns of matrix4 (default=seed mask)

- correct_path_distribution:

  Logical. correct path distribution for the length of the pathways

- dist_thresh:

  Numeric. discards samples shorter than this threshold (in mm -
  default=0)

- distthresh1:

  Numeric. Discards samples (in matrix1) shorter than this threshold (in
  mm - default=0)

- distthresh3:

  Numeric. Discards samples (in matrix3) shorter than this threshold (in
  mm - default=0)

- fibst:

  Integer. force a starting fibre for tracking - default=1, i.e. first
  fibre orientation. Only works if randfib==0

- fopd:

  Character; file path. Other mask for binning tract distribution

- force_dir:

  Logical. use the actual directory name given - i.e. do not add + to
  make a new directory

- inv_xfm:

  Character; file path. transformation matrix taking DTI space to seed
  space (compulsory when using a warp_field for seeds_to_dti)

- loop_check:

  Logical. perform loop_checks on paths - slower, but allows lower
  curvature threshold

- lrtarget3:

  Character; file path. Column-space mask used for Nxn connectivity
  matrix

- meshspace:

  Character; one of: "caret", "freesurfer", "first", "vox". Mesh
  reference space - either "caret" (default) or "freesurfer" or "first"
  or "vox"

- mod_euler:

  Logical. use modified euler streamlining

- n_samples:

  Integer. number of samples - default=5000

- n_steps:

  Integer. number of steps per sample - default=2000

- network:

  Logical. activate network mode - only keep paths going through at
  least one seed mask (required if multiple seed masks)

- omatrix1:

  Logical. Output matrix1 - SeedToSeed Connectivity

- omatrix2:

  Logical. Output matrix2 - SeedToLowResMask

- omatrix3:

  Logical. Output matrix3 (NxN connectivity matrix)

- omatrix4:

  Logical. Output matrix4 - DtiMaskToSeed (special Oxford Sparse Format)

- onewaycondition:

  Logical. Apply waypoint conditions to each half tract separately

- opd:

  Logical. outputs path distributions

- os2t:

  Logical. Outputs seeds to targets

- out_dir:

  Character; directory path. directory to put the final volumes in

- rand_fib:

  Character; one of: "0", "1", "2", "3". options: 0 - default, 1 - to
  randomly sample initial fibres (with f \> fibthresh), 2 - to sample in
  proportion fibres (with f\>fibthresh) to f, 3 - to sample ALL
  populations at random (even if f\<fibthresh)

- random_seed:

  Integer. random seed

- s2tastext:

  Logical. output seed-to-target counts as a text file (useful when
  seeding from a mesh)

- sample_random_points:

  Numeric. sample random points within seed voxels

- samples_base_name:

  Character. the rootname/base_name for samples files

- seed_ref:

  Character; file path. reference vol to define seed space in simple
  mode - diffusion space assumed if absent

- simple:

  Logical. rack from a list of voxels (seed must be a ASCII list of
  coordinates)

- step_length:

  Numeric. step_length in mm - default=0.5

- stop_mask:

  Character; file path. stop tracking at locations given by this mask
  file

- target2:

  Character; file path. Low resolution binary brain mask for storing
  connectivity distribution in matrix2 mode

- target3:

  Character; file path. Mask used for NxN connectivity matrix (or Nxn if
  lrtarget3 is set)

- target4:

  Character; file path. Brain mask in DTI space

- target_masks:

  Character or numeric vector. list of target masks - required for
  seeds_to_targets classification

- use_anisotropy:

  Logical. use anisotropy to constrain tracking

- verbose:

  Character; one of: "0", "1", "2". Verbose level, \[0-2\]. Level 2 is
  required to output particle files.

- waycond:

  Character; one of: "OR", "AND". Waypoint condition. Either "AND"
  (default) or "OR"

- wayorder:

  Logical. Reject streamlines that do not hit waypoints in given order.
  Only valid if waycond=AND

- waypoints:

  Character; file path. waypoint mask or ascii list of waypoint masks -
  only keep paths going through ALL the masks

- xfm:

  Character; file path. transformation matrix taking seed space to DTI
  space (either FLIRT matrix or FNIRT warp_field) - default is identity

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
