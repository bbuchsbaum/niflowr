# FSL DistanceMap

Use FSL's distancemap to generate a map of the distance to the nearest

## Usage

``` r
ni_fsl_distance_map(
  in_file,
  args = NULL,
  distance_map = NULL,
  invert_input = NULL,
  local_max_file = NULL,
  mask_file = NULL,
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

  Character; file path. image to calculate distance values for
  **Required.**

- args:

  Character. Additional parameters to the command

- distance_map:

  Character; file path. distance map to write

- invert_input:

  Logical. invert input image

- local_max_file:

  Character or numeric vector. write an image of the local maxima

- mask_file:

  Character; file path. binary mask to constrain calculations

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
