# FSL ContrastMgr

Use FSL contrast_mgr command to evaluate contrasts

## Usage

``` r
ni_fsl_contrast_mgr(
  corrections,
  dof_file,
  param_estimates,
  sigmasquareds,
  tcon_file,
  args = NULL,
  contrast_num = NULL,
  fcon_file = NULL,
  suffix = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- corrections:

  Character; file path. statistical corrections used within FILM
  modelling **Required.**

- dof_file:

  Character; file path. degrees of freedom **Required.**

- param_estimates:

  Character or numeric vector. Parameter estimates for each column of
  the design matrix **Required.**

- sigmasquareds:

  Character; file path. summary of residuals, See Woolrich, et. al.,
  2001 **Required.**

- tcon_file:

  Character; file path. contrast file containing T-contrasts
  **Required.**

- args:

  Character. Additional parameters to the command

- contrast_num:

  Character. contrast number to start labeling copes from

- fcon_file:

  Character; file path. contrast file containing F-contrasts

- suffix:

  Character. suffix to put on the end of the cope filename before the
  contrast number, default is nothing

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
