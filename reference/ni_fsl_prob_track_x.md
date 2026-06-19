# FSL ProbTrackX

Use FSL probtrackx for tractography on bedpostx results

## Usage

``` r
ni_fsl_prob_track_x(
  fsamples,
  mask,
  phsamples,
  seed,
  thsamples,
  args = NULL,
  avoid_mp = NULL,
  c_thresh = NULL,
  correct_path_distribution = NULL,
  dist_thresh = NULL,
  fibst = NULL,
  force_dir = TRUE,
  inv_xfm = NULL,
  loop_check = NULL,
  mask2 = NULL,
  mesh = NULL,
  mod_euler = NULL,
  mode = NULL,
  n_samples = 5000,
  n_steps = NULL,
  network = NULL,
  opd = TRUE,
  os2t = NULL,
  out_dir = NULL,
  rand_fib = NULL,
  random_seed = NULL,
  s2tastext = NULL,
  sample_random_points = NULL,
  samples_base_name = "merged",
  seed_ref = NULL,
  step_length = NULL,
  stop_mask = NULL,
  target_masks = NULL,
  use_anisotropy = NULL,
  verbose = NULL,
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

- correct_path_distribution:

  Logical. correct path distribution for the length of the pathways

- dist_thresh:

  Numeric. discards samples shorter than this threshold (in mm -
  default=0)

- fibst:

  Integer. force a starting fibre for tracking - default=1, i.e. first
  fibre orientation. Only works if randfib==0

- force_dir:

  Logical. use the actual directory name given - i.e. do not add + to
  make a new directory

- inv_xfm:

  Character; file path. transformation matrix taking DTI space to seed
  space (compulsory when using a warp_field for seeds_to_dti)

- loop_check:

  Logical. perform loop_checks on paths - slower, but allows lower
  curvature threshold

- mask2:

  Character; file path. second bet binary mask (in diffusion space) in
  twomask_symm mode

- mesh:

  Character; file path. Freesurfer-type surface descriptor (in ascii
  format)

- mod_euler:

  Logical. use modified euler streamlining

- mode:

  Character; one of: "simple", "two_mask_symm", "seedmask". options:
  simple (single seed voxel), seedmask (mask of seed voxels),
  twomask_symm (two bet binary masks)

- n_samples:

  Integer. number of samples - default=5000

- n_steps:

  Integer. number of steps per sample - default=2000

- network:

  Logical. activate network mode - only keep paths going through at
  least one seed mask (required if multiple seed masks)

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

- step_length:

  Numeric. step_length in mm - default=0.5

- stop_mask:

  Character; file path. stop tracking at locations given by this mask
  file

- target_masks:

  Character or numeric vector. list of target masks - required for
  seeds_to_targets classification

- use_anisotropy:

  Logical. use anisotropy to constrain tracking

- verbose:

  Character; one of: "0", "1", "2". Verbose level, \[0-2\]. Level 2 is
  required to output particle files.

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
