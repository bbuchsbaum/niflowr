# FSL InvWarp

Use FSL Invwarp to invert a FNIRT warp

## Usage

``` r
ni_fsl_inv_warp(
  reference,
  warp,
  absolute = NULL,
  args = NULL,
  inverse_warp = NULL,
  jacobian_max = NULL,
  jacobian_min = NULL,
  niter = NULL,
  noconstraint = NULL,
  regularise = NULL,
  relative = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- reference:

  Character; file path. Name of a file in target space. Note that the
  target space is now different from the target space that was used to
  create the –warp file. It would typically be the file that was
  specified with the –in argument when running fnirt. **Required.**

- warp:

  Character; file path. Name of file containing
  warp-coefficients/fields. This would typically be the output from the
  –cout switch of fnirt (but can also use fields, like the output from
  –fout). **Required.**

- absolute:

  Logical. If set it indicates that the warps in –warp should be
  interpreted as absolute, provided that it is not created by fnirt
  (which always uses relative warps). If set it also indicates that the
  output –out should be absolute.

- args:

  Character. Additional parameters to the command

- inverse_warp:

  Character; file path. Name of output file, containing warps that are
  the "reverse" of those in –warp. This will be a field-file (rather
  than a file of spline coefficients), and it will have any affine
  component included as part of the displacements.

- jacobian_max:

  Numeric. Maximum acceptable Jacobian value for constraint (default
  100.0)

- jacobian_min:

  Numeric. Minimum acceptable Jacobian value for constraint (default
  0.01)

- niter:

  Integer. Determines how many iterations of the gradient-descent search
  that should be run.

- noconstraint:

  Logical. Do not apply Jacobian constraint

- regularise:

  Numeric. Regularization strength (default=1.0).

- relative:

  Logical. If set it indicates that the warps in –warp should be
  interpreted as relative. I.e. the values in –warp are displacements
  from the coordinates in the –ref space. If set it also indicates that
  the output –out should be relative.

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
