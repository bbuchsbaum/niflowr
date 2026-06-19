# FSL VecReg

Use FSL vecreg for registering vector data

## Usage

``` r
ni_fsl_vec_reg(
  in_file,
  ref_vol,
  affine_mat = NULL,
  args = NULL,
  interpolation = NULL,
  mask = NULL,
  out_file = NULL,
  ref_mask = NULL,
  rotation_mat = NULL,
  rotation_warp = NULL,
  warp_field = NULL,
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

  Character; file path. filename for input vector or tensor field
  **Required.**

- ref_vol:

  Character; file path. filename for reference (target) volume
  **Required.**

- affine_mat:

  Character; file path. filename for affine transformation matrix

- args:

  Character. Additional parameters to the command

- interpolation:

  Character; one of: "nearestneighbour", "trilinear", "sinc", "spline".
  interpolation method : nearestneighbour, trilinear (default), sinc or
  spline

- mask:

  Character; file path. brain mask in input space

- out_file:

  Character; file path. filename for output registered vector or tensor
  field

- ref_mask:

  Character; file path. brain mask in output space (useful for speed up
  of nonlinear reg)

- rotation_mat:

  Character; file path. filename for secondary affine matrix if set,
  this will be used for the rotation of the vector/tensor field

- rotation_warp:

  Character; file path. filename for secondary warp field if set, this
  will be used for the rotation of the vector/tensor field

- warp_field:

  Character; file path. filename for 4D warp field for nonlinear
  registration

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
