# FSL PrepareFieldmap

Interface for the fsl_prepare_fieldmap script (FSL 5.0)

## Usage

``` r
ni_fsl_prepare_fieldmap(
  delta_TE,
  in_magnitude,
  in_phase,
  args = NULL,
  nocheck = FALSE,
  out_fieldmap = NULL,
  scanner = "SIEMENS",
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- delta_TE:

  Numeric. echo time difference of the fieldmap sequence in ms. (usually
  2.46ms in Siemens) **Required.**

- in_magnitude:

  Character; file path. Magnitude difference map, brain extracted
  **Required.**

- in_phase:

  Character; file path. Phase difference map, in SIEMENS format range
  from 0-4096 or 0-8192) **Required.**

- args:

  Character. Additional parameters to the command

- nocheck:

  Logical. do not perform sanity checks for image size/range/dimensions

- out_fieldmap:

  Character; file path. output name for prepared fieldmap

- scanner:

  Character. must be SIEMENS

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
