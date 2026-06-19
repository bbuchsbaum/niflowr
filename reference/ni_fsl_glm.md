# FSL GLM

FSL GLM:

## Usage

``` r
ni_fsl_glm(
  design,
  in_file,
  args = NULL,
  contrasts = NULL,
  dat_norm = NULL,
  demean = NULL,
  des_norm = NULL,
  dof = NULL,
  mask = NULL,
  out_cope = NULL,
  out_data_name = NULL,
  out_f_name = NULL,
  out_file = NULL,
  out_p_name = NULL,
  out_pf_name = NULL,
  out_res_name = NULL,
  out_sigsq_name = NULL,
  out_t_name = NULL,
  out_varcb_name = NULL,
  out_vnscales_name = NULL,
  out_z_name = NULL,
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

- design:

  Character; file path. file name of the GLM design matrix (text time
  courses for temporal regression or an image file for spatial
  regression) **Required.**

- in_file:

  Character; file path. input file name (text matrix or 3D/4D image
  file) **Required.**

- args:

  Character. Additional parameters to the command

- contrasts:

  Character; file path. matrix of t-statics contrasts

- dat_norm:

  Logical. switch on normalization of the data time series to unit std
  deviation

- demean:

  Logical. switch on demeaining of design and data

- des_norm:

  Logical. switch on normalization of the design matrix columns to unit
  std deviation

- dof:

  Integer. set degrees of freedom explicitly

- mask:

  Character; file path. mask image file name if input is image

- out_cope:

  Character; file path. output file name for COPE (either as txt or
  image

- out_data_name:

  Character; file path. output file name for pre-processed data

- out_f_name:

  Character; file path. output file name for F-value of full model fit

- out_file:

  Character; file path. filename for GLM parameter estimates (GLM betas)

- out_p_name:

  Character; file path. output file name for p-values of Z-stats (either
  as text file or image)

- out_pf_name:

  Character; file path. output file name for p-value for full model fit

- out_res_name:

  Character; file path. output file name for residuals

- out_sigsq_name:

  Character; file path. output file name for residual noise variance
  sigma-square

- out_t_name:

  Character; file path. output file name for t-stats (either as txt or
  image

- out_varcb_name:

  Character; file path. output file name for variance of COPEs

- out_vnscales_name:

  Character; file path. output file name for scaling factors for
  variance normalisation

- out_z_name:

  Character; file path. output file name for Z-stats (either as txt or
  image

- var_norm:

  Logical. perform MELODIC variance-normalisation on data

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
