# AFNI Eval

Evaluates an expression that may include columns of data from one or

## Usage

``` r
ni_afni_eval(
  expr,
  in_file_a,
  args = NULL,
  in_file_b = NULL,
  in_file_c = NULL,
  out1D = NULL,
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

- expr:

  Character. expr **Required.**

- in_file_a:

  Character; file path. input file to 1deval **Required.**

- args:

  Character. Additional parameters to the command

- in_file_b:

  Character; file path. operand file to 1deval

- in_file_c:

  Character; file path. operand file to 1deval

- out1D:

  Logical. output in 1D

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
