# AFNI Despike

Removes 'spikes' from the 3D+time input dataset

## Usage

``` r
ni_afni_despike(
  in_file,
  args = NULL,
  out_file = NULL,
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

  Character; file path. input file to 3dDespike **Required.**

- args:

  Character. Additional parameters to the command

- out_file:

  Character; file path. output image file name

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
