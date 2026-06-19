# FSL PowerSpectrum

Use FSL PowerSpectrum command for power spectrum estimation.

## Usage

``` r
ni_fsl_power_spectrum(
  in_file,
  args = NULL,
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

- in_file:

  Character; file path. input 4D file to estimate the power spectrum
  **Required.**

- args:

  Character. Additional parameters to the command

- out_file:

  Character; file path. name of output 4D file for power spectrum

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
