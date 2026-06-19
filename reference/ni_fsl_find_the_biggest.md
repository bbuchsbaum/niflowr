# FSL FindTheBiggest

Use FSL find_the_biggest for performing hard segmentation on

## Usage

``` r
ni_fsl_find_the_biggest(
  in_files,
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

- in_files:

  Character or numeric vector. a list of input volumes or a
  singleMatrixFile **Required.**

- args:

  Character. Additional parameters to the command

- out_file:

  Character; file path. file with the resulting segmentation

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
