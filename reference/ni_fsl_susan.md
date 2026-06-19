# FSL SUSAN

FSL SUSAN wrapper to perform smoothing

## Usage

``` r
ni_fsl_susan(
  brightness_threshold,
  fwhm,
  in_file,
  args = NULL,
  dimension = 3,
  out_file = NULL,
  use_median = 1,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- brightness_threshold:

  Numeric. brightness threshold and should be greater than noise level
  and less than contrast of edges to be preserved. **Required.**

- fwhm:

  Numeric. fwhm of smoothing, in mm, gets converted using
  sqrt(8\*log(2)) **Required.**

- in_file:

  Character; file path. filename of input timeseries **Required.**

- args:

  Character. Additional parameters to the command

- dimension:

  Character; one of: "3", "2". within-plane (2) or fully 3D (3)

- out_file:

  Character; file path. output file name

- use_median:

  Character; one of: "1", "0". whether to use a local median filter in
  the cases where single-point noise is detected

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
