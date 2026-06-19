# AFNI NwarpCat

Catenates (composes) 3D warps defined on a grid, OR via a matrix.

## Usage

``` r
ni_afni_nwarp_cat(
  in_files,
  args = NULL,
  expad = NULL,
  interp = "wsinc5",
  inv_warp = NULL,
  out_file = NULL,
  space = NULL,
  verb = NULL,
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

  Character or numeric vector. list of tuples of 3D warps and associated
  functions **Required.**

- args:

  Character. Additional parameters to the command

- expad:

  Integer. Pad the nonlinear warps by the given number of voxels in all
  directions. The warp displacements are extended by linear
  extrapolation from the faces of the input grid..

- interp:

  Character; one of: "wsinc5", "linear", "quintic". specify a different
  interpolation method than might be used for the warp

- inv_warp:

  Logical. invert the final warp before output

- out_file:

  Character; file path. output image file name

- space:

  Character. string to attach to the output dataset as its atlas space
  marker.

- verb:

  Logical. be verbose

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
