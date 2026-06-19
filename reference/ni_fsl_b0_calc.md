# FSL B0Calc

B0 inhomogeneities occur at interfaces of materials with different
magnetic susceptibilities,

## Usage

``` r
ni_fsl_b0_calc(
  in_file,
  args = NULL,
  chi_air = 4e-07,
  compute_xyz = FALSE,
  delta = -9.45e-06,
  directconv = FALSE,
  extendboundary = 1,
  out_file = NULL,
  x_b0 = 0,
  x_grad = 0,
  xyz_b0 = NULL,
  y_b0 = 0,
  y_grad = 0,
  z_b0 = 1,
  z_grad = 0,
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

  Character; file path. filename of input image (usually a tissue/air
  segmentation) **Required.**

- args:

  Character. Additional parameters to the command

- chi_air:

  Numeric. susceptibility of air

- compute_xyz:

  Logical. calculate and save all 3 field components (i.e. x,y,z)

- delta:

  Numeric. Delta value (chi_tissue - chi_air)

- directconv:

  Logical. use direct (image space) convolution, not FFT

- extendboundary:

  Numeric. Relative proportion to extend voxels at boundary

- out_file:

  Character; file path. filename of B0 output volume

- x_b0:

  Numeric. Value for zeroth-order b0 field (x-component), in Tesla

- x_grad:

  Numeric. Value for zeroth-order x-gradient field (per mm)

- xyz_b0:

  Character or numeric vector. Zeroth-order B0 field in Tesla

- y_b0:

  Numeric. Value for zeroth-order b0 field (y-component), in Tesla

- y_grad:

  Numeric. Value for zeroth-order y-gradient field (per mm)

- z_b0:

  Numeric. Value for zeroth-order b0 field (z-component), in Tesla

- z_grad:

  Numeric. Value for zeroth-order z-gradient field (per mm)

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
