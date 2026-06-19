# AFNI Copy

Copies an image of one type to an image of the same

## Usage

``` r
ni_afni_copy(
  in_file,
  args = NULL,
  out_file = NULL,
  verbose = NULL,
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

  Character; file path. input file to 3dcopy **Required.**

- args:

  Character. Additional parameters to the command

- out_file:

  Character; file path. output image file name

- verbose:

  Logical. print progress reports

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
