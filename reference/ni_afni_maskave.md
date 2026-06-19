# AFNI Maskave

Computes average of all voxels in the input dataset

## Usage

``` r
ni_afni_maskave(
  in_file,
  args = NULL,
  mask = NULL,
  out_file = NULL,
  quiet = NULL,
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

  Character; file path. input file to 3dmaskave **Required.**

- args:

  Character. Additional parameters to the command

- mask:

  Character; file path. matrix to align input file

- out_file:

  Character; file path. output image file name

- quiet:

  Logical. matrix to align input file

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
