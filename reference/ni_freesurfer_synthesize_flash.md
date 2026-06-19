# FREESURFER SynthesizeFLASH

Synthesize a FLASH acquisition from T1 and proton density maps.

## Usage

``` r
ni_freesurfer_synthesize_flash(
  flip_angle,
  pd_image,
  t1_image,
  te,
  tr,
  args = NULL,
  fixed_weighting = NULL,
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

- flip_angle:

  Numeric. flip angle (in degrees) **Required.**

- pd_image:

  Character; file path. image of proton density values **Required.**

- t1_image:

  Character; file path. image of T1 values **Required.**

- te:

  Numeric. echo time (in msec) **Required.**

- tr:

  Numeric. repetition time (in msec) **Required.**

- args:

  Character. Additional parameters to the command

- fixed_weighting:

  Logical. use a fixed weighting to generate optimal gray/white contrast

- out_file:

  Character; file path. image to write

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
