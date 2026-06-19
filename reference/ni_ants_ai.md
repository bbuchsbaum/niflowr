# ANTS AI

Calculate the optimal linear transform parameters for aligning two
images.

## Usage

``` r
ni_ants_ai(
  fixed_image,
  metric,
  moving_image,
  args = NULL,
  convergence = c(10, 1e-06, 10),
  dimension = 3,
  fixed_image_mask = NULL,
  output_transform = "initialization.mat",
  principal_axes = FALSE,
  search_factor = c(20, 0.12),
  search_grid = NULL,
  transform = c("Affine", "0.1"),
  verbose = FALSE,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- fixed_image:

  Character; file path. Image to which the moving_image should be
  transformed **Required.**

- metric:

  Character or numeric vector. the metric(s) to use. **Required.**

- moving_image:

  Character; file path. Image that will be transformed to fixed_image
  **Required.**

- args:

  Character. Additional parameters to the command

- convergence:

  Character or numeric vector. convergence

- dimension:

  Character; one of: "3", "2". dimension of output image

- fixed_image_mask:

  Character; file path. fixed mage mask

- output_transform:

  Character; file path. output file name

- principal_axes:

  Logical. align using principal axes

- search_factor:

  Character or numeric vector. search factor

- search_grid:

  Character or numeric vector. Translation search grid in mm

- transform:

  Character or numeric vector. Several transform options are available

- verbose:

  Logical. enable verbosity

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
