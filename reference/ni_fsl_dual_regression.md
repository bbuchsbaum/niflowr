# FSL DualRegression

Wrapper Script for Dual Regression Workflow

## Usage

``` r
ni_fsl_dual_regression(
  group_IC_maps_4D,
  in_files,
  n_perm,
  args = NULL,
  con_file = NULL,
  des_norm = TRUE,
  design_file = NULL,
  one_sample_group_mean = NULL,
  out_dir = "output",
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- group_IC_maps_4D:

  Character; file path. 4D image containing spatial IC maps (melodic_IC)
  from the whole-group ICA analysis **Required.**

- in_files:

  Character or numeric vector. List all subjects' preprocessed,
  standard-space 4D datasets **Required.**

- n_perm:

  Integer. Number of permutations for randomise; set to 1 for just raw
  tstat output, set to 0 to not run randomise at all. **Required.**

- args:

  Character. Additional parameters to the command

- con_file:

  Character; file path. Design contrasts for final cross-subject
  modelling with randomise

- des_norm:

  Logical. Whether to variance-normalise the timecourses used as the
  stage-2 regressors; True is default and recommended

- design_file:

  Character; file path. Design matrix for final cross-subject modelling
  with randomise

- one_sample_group_mean:

  Logical. perform 1-sample group-mean test instead of generic
  permutation test

- out_dir:

  Character; directory path. This directory will be created to hold all
  output and logfiles

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
