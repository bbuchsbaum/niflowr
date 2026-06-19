# ANTS CreateJacobianDeterminantImage

Examples

## Usage

``` r
ni_ants_create_jacobian_determinant_image(
  deformationField,
  imageDimension,
  outputImage,
  args = NULL,
  doLogJacobian = NULL,
  useGeometric = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- deformationField:

  Character; file path. deformation transformation file **Required.**

- imageDimension:

  Character; one of: "3", "2". image dimension (2 or 3) **Required.**

- outputImage:

  Character; file path. output filename **Required.**

- args:

  Character. Additional parameters to the command

- doLogJacobian:

  Character; one of: "0", "1". return the log jacobian

- useGeometric:

  Character; one of: "0", "1". return the geometric jacobian

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
