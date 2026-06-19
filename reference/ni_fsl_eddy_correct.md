# FSL EddyCorrect

.. warning:: Deprecated in FSL. Please use

## Usage

``` r
ni_fsl_eddy_correct(
  in_file,
  ref_num,
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

  Character; file path. 4D input file **Required.**

- ref_num:

  Integer. reference number **Required.**

- args:

  Character. Additional parameters to the command

- out_file:

  Character; file path. 4D output file

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
