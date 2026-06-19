# FSL SmoothEstimate

Estimates the smoothness of an image

## Usage

``` r
ni_fsl_smooth_estimate(
  dof,
  mask_file,
  args = NULL,
  residual_fit_file = NULL,
  zstat_file = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- dof:

  Integer. number of degrees of freedom **Required.**

- mask_file:

  Character; file path. brain mask volume **Required.**

- args:

  Character. Additional parameters to the command

- residual_fit_file:

  Character; file path. residual-fit image file

- zstat_file:

  Character; file path. zstat image file

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
