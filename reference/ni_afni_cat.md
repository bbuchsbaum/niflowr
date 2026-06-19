# AFNI Cat

1dcat takes as input one or more 1D files, and writes out a 1D file

## Usage

``` r
ni_afni_cat(
  in_files,
  out_file,
  args = NULL,
  keepfree = NULL,
  omitconst = NULL,
  out_double = NULL,
  out_fint = NULL,
  out_format = NULL,
  out_int = NULL,
  out_nice = NULL,
  sel = NULL,
  stack = NULL,
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

- out_file:

  Character; file path. output (concatenated) file name **Required.**

- args:

  Character. Additional parameters to the command

- keepfree:

  Logical. Keep only columns that are marked as 'free' in the
  3dAllineate header from '-1Dparam_save'. If there is no such header,
  all columns are kept.

- omitconst:

  Logical. Omit columns that are identically constant from output.

- out_double:

  Logical. specify double data type for output

- out_fint:

  Logical. specify int, rounded down, data type for output

- out_format:

  Character; one of: "int", "nice", "double", "fint", "cint". specify
  data type for output.

- out_int:

  Logical. specify int data type for output

- out_nice:

  Logical. specify nice data type for output

- sel:

  Character. Apply the same column/row selection string to all filenames
  on the command line.

- stack:

  Logical. Stack the columns of the resultant matrix in the output.

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
