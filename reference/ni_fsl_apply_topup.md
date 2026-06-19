# FSL ApplyTOPUP

Interface for FSL topup, a tool for estimating and correcting

## Usage

``` r
ni_fsl_apply_topup(
  encoding_file,
  in_files,
  args = NULL,
  datatype = NULL,
  in_index = NULL,
  in_topup_fieldcoef = NULL,
  interp = NULL,
  method = NULL,
  out_corrected = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- encoding_file:

  Character; file path. name of text file with PE directions/times
  **Required.**

- in_files:

  Character or numeric vector. name of file with images **Required.**

- args:

  Character. Additional parameters to the command

- datatype:

  Character; one of: "char", "short", "int", "float", "double". force
  output data type

- in_index:

  Character or numeric vector. comma separated list of indices
  corresponding to –datain

- in_topup_fieldcoef:

  Character; file path. topup file containing the field coefficients

- interp:

  Character; one of: "trilinear", "spline". interpolation method

- method:

  Character; one of: "jac", "lsr". use jacobian modulation (jac) or
  least-squares resampling (lsr)

- out_corrected:

  Character; file path. output (warped) image

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
