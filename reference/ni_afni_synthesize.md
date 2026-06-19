# AFNI Synthesize

Reads a '-cbucket' dataset and a '.xmat.1D' matrix from 3dDeconvolve,

## Usage

``` r
ni_afni_synthesize(
  cbucket,
  matrix,
  select,
  TR = NULL,
  args = NULL,
  cenfill = NULL,
  dry_run_arg = NULL,
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

- cbucket:

  Character; file path. Read the dataset output from 3dDeconvolve via
  the '-cbucket' option. **Required.**

- matrix:

  Character; file path. Read the matrix output from 3dDeconvolve via the
  '-x1D' option. **Required.**

- select:

  Character or numeric vector. A list of selected columns from the
  matrix (and the corresponding coefficient sub-bricks from the
  cbucket). Valid types include 'baseline', 'polort', 'allfunc',
  'allstim', 'all', Can also provide 'something' where something matches
  a stim_label from 3dDeconvolve, and 'digits' where digits are the
  numbers of the select matrix columns by numbers (starting at 0), or
  number ranges of the form '3..7' and '3-7'. **Required.**

- TR:

  Numeric. TR to set in the output. The default value of TR is read from
  the header of the matrix file.

- args:

  Character. Additional parameters to the command

- cenfill:

  Character; one of: "zero", "nbhr", "none". Determines how censored
  time points from the 3dDeconvolve run will be filled. Valid types are
  'zero', 'nbhr' and 'none'.

- dry_run_arg:

  Logical. Don't compute the output, just check the inputs. (spec input:
  dry_run)

- out_file:

  Character; file path. output dataset prefix name (default 'syn')

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
