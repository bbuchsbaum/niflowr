# AFNI Fim

Program to calculate the cross-correlation of an ideal reference

## Usage

``` r
ni_afni_fim(
  ideal_file,
  in_file,
  args = NULL,
  fim_thr = NULL,
  out = NULL,
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

- ideal_file:

  Character; file path. ideal time series file name **Required.**

- in_file:

  Character; file path. input file to 3dfim+ **Required.**

- args:

  Character. Additional parameters to the command

- fim_thr:

  Numeric. fim internal mask threshold value

- out:

  Character. Flag to output the specified parameter

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
