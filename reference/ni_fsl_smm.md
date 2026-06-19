# FSL SMM

Spatial Mixture Modelling. For more detail on the spatial mixture
modelling

## Usage

``` r
ni_fsl_smm(
  mask,
  spatial_data_file,
  args = NULL,
  no_deactivation_class = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- mask:

  Character; file path. mask file **Required.**

- spatial_data_file:

  Character; file path. statistics spatial map **Required.**

- args:

  Character. Additional parameters to the command

- no_deactivation_class:

  Logical. enforces no deactivation class

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
