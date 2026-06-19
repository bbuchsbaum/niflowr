# FREESURFER GTMPVC

Perform Partial Volume Correction (PVC) to PET Data.

## Usage

``` r
ni_freesurfer_gtmpvc(
  in_file,
  reg_file,
  reg_identity,
  regheader,
  segmentation,
  X = NULL,
  X0 = NULL,
  args = NULL,
  auto_mask = NULL,
  beta = NULL,
  color_table_file = NULL,
  contrast = NULL,
  default_color_table = NULL,
  default_seg_merge = NULL,
  frame = NULL,
  km_hb = NULL,
  km_ref = NULL,
  lat = NULL,
  mask_file = NULL,
  merge_cblum_wm_gyri = NULL,
  merge_hypos = NULL,
  mg = NULL,
  mg_ref_cerebral_wm = NULL,
  mg_ref_lobes_wm = NULL,
  mgx = NULL,
  no_pvc = NULL,
  no_reduce_fov = NULL,
  no_rescale = NULL,
  no_tfe = NULL,
  num_threads = NULL,
  opt_brain = NULL,
  opt_seg_merge = NULL,
  opt_tol = NULL,
  optimization_schema = NULL,
  psf = NULL,
  psf_col = NULL,
  psf_row = NULL,
  psf_slice = NULL,
  pvc_dir = NULL,
  rbv = NULL,
  rbv_res = NULL,
  reduce_fox_eqodd = NULL,
  replace = NULL,
  rescale = NULL,
  save_eres = NULL,
  save_input = NULL,
  save_yhat = NULL,
  save_yhat0 = NULL,
  save_yhat_full_fov = NULL,
  save_yhat_with_noise = NULL,
  scale_refval = NULL,
  steady_state_params = NULL,
  tissue_fraction_resolution = NULL,
  tt_reduce = NULL,
  tt_update = NULL,
  y = NULL,
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

  Character; file path. input volume - source data to pvc **Required.**

- reg_file:

  Character; file path. LTA registration file that maps PET to
  anatomical **Required.**

- reg_identity:

  Logical. assume that input is in anatomical space **Required.**

- regheader:

  Logical. assume input and seg share scanner space **Required.**

- segmentation:

  Character; file path. segfile : anatomical segmentation to define
  regions for GTM **Required.**

- X:

  Logical. save X matrix in matlab4 format as X.mat (it will be big)

- X0:

  Logical. save X0 matrix in matlab4 format as X0.mat (it will be big)

- args:

  Character. Additional parameters to the command

- auto_mask:

  Character or numeric vector. FWHM thresh : automatically compute mask

- beta:

  Logical. save beta matrix in matlab4 format as beta.mat

- color_table_file:

  Character; file path. color table file with seg id names

- contrast:

  Character or numeric vector. contrast file

- default_color_table:

  Logical. use \$FREESURFER_HOME/FreeSurferColorLUT.txt

- default_seg_merge:

  Logical. default schema for merging ROIs

- frame:

  Integer. only process 0-based frame F from inputvol

- km_hb:

  Character or numeric vector. RefId1 RefId2 ... : compute HiBinding TAC
  for KM as mean of given RefIds

- km_ref:

  Character or numeric vector. RefId1 RefId2 ... : compute reference TAC
  for KM as mean of given RefIds

- lat:

  Logical. lateralize tissue types

- mask_file:

  Character; file path. ignore areas outside of the mask (in input vol
  space)

- merge_cblum_wm_gyri:

  Logical. cerebellum WM gyri back into cerebellum WM

- merge_hypos:

  Logical. merge left and right hypointensites into to ROI

- mg:

  Character or numeric vector. gmthresh RefId1 RefId2 ...: perform
  Mueller-Gaertner PVC, gmthresh is min gm pvf bet 0 and 1

- mg_ref_cerebral_wm:

  Logical. set MG RefIds to 2 and 41

- mg_ref_lobes_wm:

  Logical. set MG RefIds to those for lobes when using wm subseg

- mgx:

  Numeric. gmxthresh : GLM-based Mueller-Gaertner PVC, gmxthresh is min
  gm pvf bet 0 and 1

- no_pvc:

  Logical. turns off PVC entirely (both PSF and TFE)

- no_reduce_fov:

  Logical. do not reduce FoV to encompass mask

- no_rescale:

  Logical. do not global rescale such that mean of reference region is
  scaleref

- no_tfe:

  Logical. do not correct for tissue fraction effect (with –psf 0 turns
  off PVC entirely)

- num_threads:

  Integer. threads : number of threads to use

- opt_brain:

  Logical. apply adaptive GTM

- opt_seg_merge:

  Logical. optimal schema for merging ROIs when applying adaptive GTM

- opt_tol:

  Character or numeric vector. n_iters_max ftol lin_min_tol :
  optimization parameters for adaptive gtm using fminsearch

- optimization_schema:

  Character; one of: "3D", "2D", "1D", "3D_MB", "2D_MB", "1D_MB", "MBZ",
  "MB3". opt : optimization schema for applying adaptive GTM

- psf:

  Numeric. scanner PSF FWHM in mm

- psf_col:

  Numeric. xFWHM : full-width-half-maximum in the x-direction

- psf_row:

  Numeric. yFWHM : full-width-half-maximum in the y-direction

- psf_slice:

  Numeric. zFWHM : full-width-half-maximum in the z-direction

- pvc_dir:

  Character. save outputs to dir

- rbv:

  Logical. perform Region-based Voxelwise (RBV) PVC

- rbv_res:

  Numeric. voxsize : set RBV voxel resolution (good for when standard
  res takes too much memory)

- reduce_fox_eqodd:

  Logical. reduce FoV to encompass mask but force nc=nr and ns to be odd

- replace:

  Character or numeric vector. Id1 Id2 : replace seg Id1 with seg Id2

- rescale:

  Character or numeric vector. Id1 \<Id2...\> : specify reference
  region(s) used to rescale (default is pons)

- save_eres:

  Logical. saves residual error

- save_input:

  Logical. saves rescaled input as input.rescaled.nii.gz

- save_yhat:

  Logical. save signal estimate (yhat) smoothed with the PSF

- save_yhat0:

  Logical. save signal estimate (yhat)

- save_yhat_full_fov:

  Logical. save signal estimate (yhat)

- save_yhat_with_noise:

  Character or numeric vector. seed nreps : save signal estimate (yhat)
  with noise

- scale_refval:

  Numeric. refval : scale such that mean in reference region is refval

- steady_state_params:

  Character or numeric vector. bpc scale dcf : steady-state analysis
  spec blood plasma concentration, unit scale and decay correction
  factor. You must also spec –km-ref. Turns off rescaling

- tissue_fraction_resolution:

  Numeric. set the tissue fraction resolution parameter (def is 0.5)

- tt_reduce:

  Logical. reduce segmentation to that of a tissue type

- tt_update:

  Logical. changes tissue type of VentralDC, BrainStem, and Pons to be
  SubcortGM

- y:

  Logical. save y matrix in matlab4 format as y.mat

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
