# AFNI TStat

Compute voxel-wise statistics using AFNI 3dTstat command

## Usage

``` r
ni_afni_t_stat(
  in_file,
  args = NULL,
  mask = NULL,
  options = NULL,
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

  Character; file path. input file to 3dTstat **Required.**

- args:

  Character. Additional parameters to the command

- mask:

  Character; file path. mask file

- options:

  Character. selected statistical output

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
