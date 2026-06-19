# ANTS LaplacianThickness

Calculates the cortical thickness from an anatomical image

## Usage

``` r
ni_ants_laplacian_thickness(
  input_gm,
  input_wm,
  args = NULL,
  dT = NULL,
  output_image = NULL,
  prior_thickness = NULL,
  smooth_param = NULL,
  sulcus_prior = NULL,
  tolerance = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- input_gm:

  Character; file path. gray matter segmentation image **Required.**

- input_wm:

  Character; file path. white matter segmentation image **Required.**

- args:

  Character. Additional parameters to the command

- dT:

  Numeric. Time delta used during integration (defaults to 0.01)

- output_image:

  Character. name of output file

- prior_thickness:

  Numeric. Prior thickness (defaults to 500)

- smooth_param:

  Numeric. Sigma of the Laplacian Recursive Image Filter (defaults to 1)

- sulcus_prior:

  Numeric. Positive floating point number for sulcus prior. Authors said
  that 0.15 might be a reasonable value

- tolerance:

  Numeric. Tolerance to reach during optimization (defaults to 0.001)

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
