# FSL ConvertXFM

Use the FSL utility convert_xfm to modify FLIRT transformation matrices.

## Usage

``` r
ni_fsl_convert_xfm(
  in_file,
  args = NULL,
  concat_xfm = NULL,
  fix_scale_skew = NULL,
  in_file2 = NULL,
  invert_xfm = NULL,
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

  Character; file path. input transformation matrix **Required.**

- args:

  Character. Additional parameters to the command

- concat_xfm:

  Logical. write joint transformation of two input matrices

- fix_scale_skew:

  Logical. use secondary matrix to fix scale and skew

- in_file2:

  Character; file path. second input matrix (for use with fix_scale_skew
  or concat_xfm)

- invert_xfm:

  Logical. invert input transformation

- out_file:

  Character; file path. final transformation matrix

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
