# FREESURFER MRTM2

Perform MRTM2 kinetic modeling.

## Usage

``` r
ni_freesurfer_mrtm2(
  in_file,
  mrtm2,
  allow_ill_cond = NULL,
  allow_repeated_subjects = NULL,
  args = NULL,
  bp_clip_max = NULL,
  bp_clip_neg = NULL,
  calc_AR1 = NULL,
  check_opts = NULL,
  compute_log_y = NULL,
  contrast = NULL,
  cortex = NULL,
  debug = NULL,
  design = NULL,
  diag = NULL,
  diag_cluster = NULL,
  fixed_fx_dof = NULL,
  fixed_fx_dof_file = NULL,
  fixed_fx_var = NULL,
  force_perm = NULL,
  fsgd = NULL,
  fwhm = NULL,
  glm_dir = NULL,
  invert_mask = NULL,
  label_file = NULL,
  logan = NULL,
  mask_file = NULL,
  mrtm1 = NULL,
  nii = NULL,
  nii_gz = NULL,
  no_contrast_ok = NULL,
  no_est_fwhm = NULL,
  no_mask_smooth = NULL,
  no_prune = NULL,
  one_sample = NULL,
  pca = NULL,
  per_voxel_reg = NULL,
  profile = NULL,
  prune = NULL,
  prune_thresh = NULL,
  resynth_test = NULL,
  save_cond = NULL,
  save_estimate = NULL,
  save_res_corr_mtx = NULL,
  save_residual = NULL,
  seed = NULL,
  self_reg = NULL,
  sim_done_file = NULL,
  sim_sign = NULL,
  simulation = NULL,
  surf = NULL,
  synth = NULL,
  uniform = NULL,
  var_fwhm = NULL,
  vox_dump = NULL,
  weight_inv = NULL,
  weight_sqrt = NULL,
  weighted_ls = NULL,
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

  Character; file path. input 4D file **Required.**

- mrtm2:

  Character or numeric vector. RefTac TimeSec k2prime : perform MRTM2
  kinetic modeling **Required.**

- allow_ill_cond:

  Logical. allow ill-conditioned design matrices

- allow_repeated_subjects:

  Logical. allow subject names to repeat in the fsgd file (must appear
  before –fsgd

- args:

  Character. Additional parameters to the command

- bp_clip_max:

  Numeric. set BP voxels above max to max

- bp_clip_neg:

  Logical. set negative BP voxels to zero

- calc_AR1:

  Logical. compute and save temporal AR1 of residual

- check_opts:

  Logical. don't run anything, just check options and exit

- compute_log_y:

  Logical. compute natural log of y prior to analysis

- contrast:

  Character or numeric vector. contrast file

- cortex:

  Logical. use subjects ?h.cortex.label as label

- debug:

  Logical. turn on debugging

- design:

  Character; file path. design matrix file

- diag:

  Integer. Gdiag_no : set diagnostic level

- diag_cluster:

  Logical. save sig volume and exit from first sim loop

- fixed_fx_dof:

  Integer. dof for fixed effects analysis

- fixed_fx_dof_file:

  Character; file path. text file with dof for fixed effects analysis

- fixed_fx_var:

  Character; file path. for fixed effects analysis

- force_perm:

  Logical. force perumtation test, even when design matrix is not orthog

- fsgd:

  Character or numeric vector. freesurfer descriptor file

- fwhm:

  Character. smooth input by fwhm

- glm_dir:

  Character. save outputs to dir

- invert_mask:

  Logical. invert mask

- label_file:

  Character; file path. use label as mask, surfaces only

- logan:

  Character or numeric vector. RefTac TimeSec tstar : perform Logan
  kinetic modeling

- mask_file:

  Character; file path. binary mask

- mrtm1:

  Character or numeric vector. RefTac TimeSec : perform MRTM1 kinetic
  modeling

- nii:

  Logical. save outputs as nii

- nii_gz:

  Logical. save outputs as nii.gz

- no_contrast_ok:

  Logical. do not fail if no contrasts specified

- no_est_fwhm:

  Logical. turn off FWHM output estimation

- no_mask_smooth:

  Logical. do not mask when smoothing

- no_prune:

  Logical. do not prune

- one_sample:

  Logical. construct X and C as a one-sample group mean

- pca:

  Logical. perform pca/svd analysis on residual

- per_voxel_reg:

  Character or numeric vector. per-voxel regressors

- profile:

  Integer. niters : test speed

- prune:

  Logical. remove voxels that do not have a non-zero value at each frame
  (def)

- prune_thresh:

  Numeric. prune threshold. Default is FLT_MIN

- resynth_test:

  Integer. test GLM by resynthsis

- save_cond:

  Logical. flag to save design matrix condition at each voxel

- save_estimate:

  Logical. save signal estimate (yhat)

- save_res_corr_mtx:

  Logical. save residual error spatial correlation matrix (eres.scm).
  Big!

- save_residual:

  Logical. save residual error (eres)

- seed:

  Integer. used for synthesizing noise

- self_reg:

  Character or numeric vector. self-regressor from index col row slice

- sim_done_file:

  Character; file path. create file when simulation finished

- sim_sign:

  Character; one of: "abs", "pos", "neg". abs, pos, or neg

- simulation:

  Character or numeric vector. nulltype nsim thresh csdbasename

- surf:

  Logical. analysis is on a surface mesh

- synth:

  Logical. replace input with gaussian

- uniform:

  Character or numeric vector. use uniform distribution instead of
  gaussian

- var_fwhm:

  Character. smooth variance by fwhm

- vox_dump:

  Character or numeric vector. dump voxel GLM and exit

- weight_inv:

  Logical. invert weights

- weight_sqrt:

  Logical. sqrt of weights

- weighted_ls:

  Character; file path. weighted least squares

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
