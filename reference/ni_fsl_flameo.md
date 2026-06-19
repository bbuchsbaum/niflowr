# FSL FLAMEO

Use FSL flameo command to perform higher level model fits

## Usage

``` r
ni_fsl_flameo(
  cope_file,
  cov_split_file,
  design_file,
  mask_file,
  run_mode,
  t_con_file,
  args = NULL,
  burnin = NULL,
  dof_var_cope_file = NULL,
  f_con_file = NULL,
  fix_mean = NULL,
  infer_outliers = NULL,
  log_dir = "stats",
  n_jumps = NULL,
  no_pe_outputs = NULL,
  outlier_iter = NULL,
  sample_every = NULL,
  sigma_dofs = NULL,
  var_cope_file = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- cope_file:

  Character; file path. cope regressor data file **Required.**

- cov_split_file:

  Character; file path. ascii matrix specifying the groups the
  covariance is split into **Required.**

- design_file:

  Character; file path. design matrix file **Required.**

- mask_file:

  Character; file path. mask file **Required.**

- run_mode:

  Character; one of: "fe", "ols", "flame1", "flame12". inference to
  perform **Required.**

- t_con_file:

  Character; file path. ascii matrix specifying t-contrasts
  **Required.**

- args:

  Character. Additional parameters to the command

- burnin:

  Integer. number of jumps at start of mcmc to be discarded

- dof_var_cope_file:

  Character; file path. dof data file for varcope data

- f_con_file:

  Character; file path. ascii matrix specifying f-contrasts

- fix_mean:

  Logical. fix mean for tfit

- infer_outliers:

  Logical. infer outliers - not for fe

- log_dir:

  Character; directory path

- n_jumps:

  Integer. number of jumps made by mcmc

- no_pe_outputs:

  Logical. do not output pe files

- outlier_iter:

  Integer. Number of max iterations to use when inferring outliers.
  Default is 12.

- sample_every:

  Integer. number of jumps for each sample

- sigma_dofs:

  Integer. sigma (in mm) to use for Gaussian smoothing the DOFs in
  FLAME 2. Default is 1mm, -1 indicates no smoothing

- var_cope_file:

  Character; file path. varcope weightings data file

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
