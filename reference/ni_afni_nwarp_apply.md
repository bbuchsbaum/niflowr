# AFNI NwarpApply

Program to apply a nonlinear 3D warp saved from 3dQwarp

## Usage

``` r
ni_afni_nwarp_apply(
  in_file,
  warp,
  ainterp = NULL,
  args = NULL,
  interp = "wsinc5",
  inv_warp = NULL,
  master = NULL,
  out_file = NULL,
  quiet = NULL,
  short = NULL,
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

- in_file:

  Character or numeric vector. the name of the dataset to be warped can
  be multiple datasets **Required.**

- warp:

  Character. the name of the warp dataset. multiple warps can be
  concatenated (make sure they exist) **Required.**

- ainterp:

  Character; one of: "NN", "nearestneighbour", "nearestneighbor",
  "linear", "trilinear", "cubic", "tricubic", "quintic", "triquintic",
  "wsinc5". specify a different interpolation method than might be used
  for the warp

- args:

  Character. Additional parameters to the command

- interp:

  Character; one of: "wsinc5", "NN", "nearestneighbour",
  "nearestneighbor", "linear", "trilinear", "cubic", "tricubic",
  "quintic", "triquintic". defines interpolation method to use during
  warp

- inv_warp:

  Logical. After the warp specified in '-nwarp' is computed, invert it

- master:

  Character; file path. the name of the master dataset, which defines
  the output grid

- out_file:

  Character; file path. output image file name

- quiet:

  Logical. don't be verbose :(

- short:

  Logical. Write output dataset using 16-bit short integers, rather than
  the usual 32-bit floats.

- verb:

  Logical. be extra verbose :)

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
