# FSL CopyGeom

Use fslcpgeom to copy the header geometry information to another image.

## Usage

``` r
ni_fsl_copy_geom(
  dest_file,
  in_file,
  args = NULL,
  ignore_dims = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- dest_file:

  Character; file path. destination image **Required.**

- in_file:

  Character; file path. source image **Required.**

- args:

  Character. Additional parameters to the command

- ignore_dims:

  Logical. Do not copy image dimensions

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
