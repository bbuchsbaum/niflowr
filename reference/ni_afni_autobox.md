# AFNI Autobox

Computes size of a box that fits around the volume.

## Usage

``` r
ni_afni_autobox(
  in_file,
  args = NULL,
  no_clustering = NULL,
  out_file = NULL,
  padding = NULL,
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

  Character; file path. input file **Required.**

- args:

  Character. Additional parameters to the command

- no_clustering:

  Logical. Don't do any clustering to find box. Any non-zero voxel will
  be preserved in the cropped volume. The default method uses some
  clustering to find the cropping box, and will clip off small isolated
  blobs.

- out_file:

  Character; file path

- padding:

  Integer. Number of extra voxels to pad on each side of box

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
