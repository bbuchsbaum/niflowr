# AFNI Calc

This program does voxel-by-voxel arithmetic on 3D datasets.

## Usage

``` r
ni_afni_calc(
  expr,
  in_file_a,
  args = NULL,
  in_file_b = NULL,
  in_file_c = NULL,
  out_file = NULL,
  overwrite = NULL,
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

  Character; file path. input file to 3dcalc **Required.**

- args:

  Character. Additional parameters to the command

- in_file_b:

  Character; file path. operand file to 3dcalc

- in_file_c:

  Character; file path. operand file to 3dcalc

- out_file:

  Character; file path. output image file name

- overwrite:

  Logical. overwrite output

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
