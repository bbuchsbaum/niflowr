# ANTS AffineInitializer

Initialize an affine transform (as in antsBrainExtraction.sh)

## Usage

``` r
ni_ants_affine_initializer(
  fixed_image,
  moving_image,
  args = NULL,
  dimension = 3,
  local_search = 10,
  out_file = "transform.mat",
  principal_axes = FALSE,
  radian_fraction = 0.1,
  search_factor = 15,
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

  Character; file path. reference image **Required.**

- moving_image:

  Character; file path. moving image **Required.**

- args:

  Character. Additional parameters to the command

- dimension:

  Character; one of: "3", "2". dimension

- local_search:

  Integer. determines if a local optimization is run at each search
  point for the set number of iterations

- out_file:

  Character; file path. output transform file

- principal_axes:

  Logical. whether the rotation is searched around an initial principal
  axis alignment.

- radian_fraction:

  Character. search this arc +/- principal axes

- search_factor:

  Numeric. increments (degrees) for affine search

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
