# FSL ApplyWarp

FSL's applywarp wrapper to apply the results of a FNIRT registration

## Usage

``` r
ni_fsl_apply_warp(
  in_file,
  ref_file,
  abswarp = NULL,
  args = NULL,
  datatype = NULL,
  field_file = NULL,
  interp = NULL,
  mask_file = NULL,
  out_file = NULL,
  postmat = NULL,
  premat = NULL,
  relwarp = NULL,
  superlevel = NULL,
  supersample = NULL,
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

  Character; file path. image to be warped **Required.**

- ref_file:

  Character; file path. reference image **Required.**

- abswarp:

  Logical. treat warp field as absolute: x' = w(x)

- args:

  Character. Additional parameters to the command

- datatype:

  Character; one of: "char", "short", "int", "float", "double". Force
  output data type \[char short int float double\].

- field_file:

  Character; file path. file containing warp field

- interp:

  Character; one of: "nn", "trilinear", "sinc", "spline". interpolation
  method

- mask_file:

  Character; file path. filename for mask image (in reference space)

- out_file:

  Character; file path. output filename

- postmat:

  Character; file path. filename for post-transform (affine matrix)

- premat:

  Character; file path. filename for pre-transform (affine matrix)

- relwarp:

  Logical. treat warp field as relative: x' = x + w(x)

- superlevel:

  Character or numeric vector. level of intermediary supersampling, a
  for 'automatic' or integer level. Default = 2

- supersample:

  Logical. intermediary supersampling of output, default is off

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
