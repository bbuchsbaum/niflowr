# AFNI Retroicor

Performs Retrospective Image Correction for physiological

## Usage

``` r
ni_afni_retroicor(
  in_file,
  args = NULL,
  card = NULL,
  cardphase = NULL,
  order = NULL,
  out_file = NULL,
  resp = NULL,
  respphase = NULL,
  threshold = NULL,
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

  Character; file path. input file to 3dretroicor **Required.**

- args:

  Character. Additional parameters to the command

- card:

  Character; file path. 1D cardiac data file for cardiac correction

- cardphase:

  Character; file path. Filename for 1D cardiac phase output

- order:

  Integer. The order of the correction (2 is typical)

- out_file:

  Character; file path. output image file name

- resp:

  Character; file path. 1D respiratory waveform data for correction

- respphase:

  Character; file path. Filename for 1D resp phase output

- threshold:

  Integer. Threshold for detection of R-wave peaks in input (Make sure
  it is above the background noise level, Try 3/4 or 4/5 times range
  plus minimum)

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
