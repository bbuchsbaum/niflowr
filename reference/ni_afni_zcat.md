# AFNI Zcat

Copies an image of one type to an image of the same

## Usage

``` r
ni_afni_zcat(
  in_files,
  args = NULL,
  datum = NULL,
  fscale = NULL,
  nscale = NULL,
  out_file = NULL,
  verb = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- in_files:

  Character or numeric vector **Required.**

- args:

  Character. Additional parameters to the command

- datum:

  Character; one of: "byte", "short", "float". specify data type for
  output. Valid types are 'byte', 'short' and 'float'.

- fscale:

  Logical. Force scaling of the output to the maximum integer range.
  This only has effect if the output datum is byte or short (either
  forced or defaulted). This option is sometimes necessary to eliminate
  unpleasant truncation artifacts.

- nscale:

  Logical. Don't do any scaling on output to byte or short datasets.
  This may be especially useful when operating on mask datasets whose
  output values are only 0's and 1's.

- out_file:

  Character; file path. output dataset prefix name (default 'zcat')

- verb:

  Logical. print out some verbositiness as the program proceeds.

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
