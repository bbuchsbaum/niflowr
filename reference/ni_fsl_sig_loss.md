# FSL SigLoss

Estimates signal loss from a field map (in rad/s)

## Usage

``` r
ni_fsl_sig_loss(
  in_file,
  args = NULL,
  echo_time = NULL,
  mask_file = NULL,
  out_file = NULL,
  slice_direction = NULL,
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

  Character; file path. b0 fieldmap file **Required.**

- args:

  Character. Additional parameters to the command

- echo_time:

  Numeric. echo time in seconds

- mask_file:

  Character; file path. brain mask file

- out_file:

  Character; file path. output signal loss estimate file

- slice_direction:

  Character; one of: "x", "y", "z". slicing direction

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
