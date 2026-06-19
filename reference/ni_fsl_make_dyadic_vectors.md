# FSL MakeDyadicVectors

Create vector volume representing mean principal diffusion direction

## Usage

``` r
ni_fsl_make_dyadic_vectors(
  phi_vol,
  theta_vol,
  args = NULL,
  mask = NULL,
  output = "dyads",
  perc = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- phi_vol:

  Character; file path **Required.**

- theta_vol:

  Character; file path **Required.**

- args:

  Character. Additional parameters to the command

- mask:

  Character; file path

- output:

  Character; file path

- perc:

  Numeric. the {perc}% angle of the output cone of uncertainty (output
  will be in degrees)

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
