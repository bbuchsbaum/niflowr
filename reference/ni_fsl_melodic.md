# FSL MELODIC

Multivariate Exploratory Linear Optimised Decomposition into Independent

## Usage

``` r
ni_fsl_melodic(
  in_files,
  ICs = NULL,
  approach = NULL,
  args = NULL,
  bg_image = NULL,
  bg_threshold = NULL,
  cov_weight = NULL,
  dim = NULL,
  dim_est = NULL,
  epsilon = NULL,
  epsilonS = NULL,
  log_power = NULL,
  mask = NULL,
  max_restart = NULL,
  maxit = NULL,
  migp = NULL,
  migpN = NULL,
  migp_factor = NULL,
  migp_shuffle = NULL,
  mix = NULL,
  mm_thresh = NULL,
  no_bet = NULL,
  no_mask = NULL,
  no_mm = NULL,
  non_linearity = NULL,
  num_ICs = NULL,
  out_all = NULL,
  out_dir = NULL,
  out_mean = NULL,
  out_orig = NULL,
  out_pca = NULL,
  out_stats = NULL,
  out_unmix = NULL,
  out_white = NULL,
  pbsc = NULL,
  rem_cmp = NULL,
  remove_deriv = NULL,
  report = NULL,
  report_maps = NULL,
  s_con = NULL,
  s_des = NULL,
  sep_vn = NULL,
  sep_whiten = NULL,
  smode = NULL,
  t_con = NULL,
  t_des = NULL,
  tr_sec = NULL,
  update_mask = NULL,
  var_norm = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- in_files:

  Character or numeric vector. input file names (either single file name
  or a list) **Required.**

- ICs:

  Character; file path. filename of the IC components file for mixture
  modelling

- approach:

  Character. approach for decomposition, 2D: defl, symm (default), 3D:
  tica (default), concat

- args:

  Character. Additional parameters to the command

- bg_image:

  Character; file path. specify background image for report (default:
  mean image)

- bg_threshold:

  Numeric. brain/non-brain threshold used to mask non-brain voxels, as a
  percentage (only if –nobet selected)

- cov_weight:

  Numeric. voxel-wise weights for the covariance matrix (e.g.
  segmentation information)

- dim:

  Integer. dimensionality reduction into \#num dimensions (default:
  automatic estimation)

- dim_est:

  Character. use specific dim. estimation technique: lap, bic, mdl, aic,
  mean (default: lap)

- epsilon:

  Numeric. minimum error change

- epsilonS:

  Numeric. minimum error change for rank-1 approximation in TICA

- log_power:

  Logical. calculate log of power for frequency spectrum

- mask:

  Character; file path. file name of mask for thresholding

- max_restart:

  Integer. maximum number of restarts

- maxit:

  Integer. maximum number of iterations before restart

- migp:

  Logical. switch on MIGP data reduction

- migpN:

  Integer. number of internal Eigenmaps

- migp_factor:

  Integer. Internal Factor of mem-threshold relative to number of
  Eigenmaps (default: 2)

- migp_shuffle:

  Logical. randomise MIGP file order (default: TRUE)

- mix:

  Character; file path. mixing matrix for mixture modelling / filtering

- mm_thresh:

  Numeric. threshold for Mixture Model based inference

- no_bet:

  Logical. switch off BET

- no_mask:

  Logical. switch off masking

- no_mm:

  Logical. switch off mixture modelling on IC maps

- non_linearity:

  Character. nonlinearity: gauss, tanh, pow3, pow4

- num_ICs:

  Integer. number of IC's to extract (for deflation approach)

- out_all:

  Logical. output everything

- out_dir:

  Character; directory path. output directory name

- out_mean:

  Logical. output mean volume

- out_orig:

  Logical. output the original ICs

- out_pca:

  Logical. output PCA results

- out_stats:

  Logical. output thresholded maps and probability maps

- out_unmix:

  Logical. output unmixing matrix

- out_white:

  Logical. output whitening/dewhitening matrices

- pbsc:

  Logical. switch off conversion to percent BOLD signal change

- rem_cmp:

  Character or numeric vector. component numbers to remove

- remove_deriv:

  Logical. removes every second entry in paradigm file (EV derivatives)

- report:

  Logical. generate Melodic web report

- report_maps:

  Character. control string for spatial map images (see slicer)

- s_con:

  Character; file path. t-contrast matrix across subject-domain

- s_des:

  Character; file path. design matrix across subject-domain

- sep_vn:

  Logical. switch off joined variance normalization

- sep_whiten:

  Logical. switch on separate whitening

- smode:

  Character; file path. matrix of session modes for report generation

- t_con:

  Character; file path. t-contrast matrix across time-domain

- t_des:

  Character; file path. design matrix across time-domain

- tr_sec:

  Numeric. TR in seconds

- update_mask:

  Logical. switch off mask updating

- var_norm:

  Logical. switch off variance normalization

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
