# FREESURFER MRIsCalc

'mris_calc' is a simple calculator that operates on FreeSurfer

## Usage

``` r
ni_freesurfer_mr_is_calc(
  action,
  in_file1,
  out_file,
  args = NULL,
  in_file2 = NULL,
  in_float = NULL,
  in_int = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- action:

  Character. Action to perform on input file(s) **Required.**

- in_file1:

  Character; file path. Input file 1 **Required.**

- out_file:

  Character; file path. Output file after calculation **Required.**

- args:

  Character. Additional parameters to the command

- in_file2:

  Character; file path. Input file 2

- in_float:

  Numeric. Input float

- in_int:

  Integer. Input integer

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
