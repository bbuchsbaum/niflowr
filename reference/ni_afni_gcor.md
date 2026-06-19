# AFNI GCOR

Computes the average correlation between every voxel

## Usage

``` r
ni_afni_gcor(
  in_file,
  args = NULL,
  mask = NULL,
  nfirst = NULL,
  no_demean = NULL,
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

  Character; file path. input dataset to compute the GCOR over
  **Required.**

- args:

  Character. Additional parameters to the command

- mask:

  Character; file path. mask dataset, for restricting the computation

- nfirst:

  Integer. specify number of initial TRs to ignore

- no_demean:

  Logical. do not (need to) demean as first step

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
