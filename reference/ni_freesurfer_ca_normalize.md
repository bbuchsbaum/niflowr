# FREESURFER CANormalize

This program creates a normalized volume using the brain volume and an

## Usage

``` r
ni_freesurfer_ca_normalize(
  atlas,
  in_file,
  transform,
  args = NULL,
  control_points = NULL,
  long_file = NULL,
  mask = NULL,
  out_file = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- atlas:

  Character; file path. The atlas file in gca format **Required.**

- in_file:

  Character; file path. The input file for CANormalize **Required.**

- transform:

  Character; file path. The transform file in lta format **Required.**

- args:

  Character. Additional parameters to the command

- control_points:

  Character; file path. File name for the output control points

- long_file:

  Character; file path. undocumented flag used in longitudinal
  processing

- mask:

  Character; file path. Specifies volume to use as mask

- out_file:

  Character; file path. The output file for CANormalize

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
