# AFNI Automask

Create a brain-only mask of the image using AFNI 3dAutomask command

## Usage

``` r
ni_afni_automask(
  in_file,
  args = NULL,
  brain_file = NULL,
  clfrac = NULL,
  dilate = NULL,
  erode = NULL,
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

  Character; file path. input file to 3dAutomask **Required.**

- args:

  Character. Additional parameters to the command

- brain_file:

  Character; file path. output file from 3dAutomask

- clfrac:

  Numeric. sets the clip level fraction (must be 0.1-0.9). A small value
  will tend to make the mask larger \[default = 0.5\].

- dilate:

  Integer. dilate the mask outwards

- erode:

  Integer. erode the mask inwards

- out_file:

  Character; file path. output image file name

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
