# AFNI CatMatvec

Catenates 3D rotation+shift matrix+vector transformations.

## Usage

``` r
ni_afni_cat_matvec(
  in_file,
  out_file,
  args = NULL,
  fourxfour = NULL,
  matrix = NULL,
  oneline = NULL,
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

  Character or numeric vector. list of tuples of mfiles and associated
  opkeys **Required.**

- out_file:

  Character; file path. File to write concattenated matvecs to
  **Required.**

- args:

  Character. Additional parameters to the command

- fourxfour:

  Logical. Output matrix in augmented form (last row is 0 0 0 1)This
  option does not work with -MATRIX or -ONELINE

- matrix:

  Logical. indicates that the resulting matrix willbe written to outfile
  in the 'MATRIX(...)' format (FORM 3).This feature could be used, with
  clever scripting, to inputa matrix directly on the command line to
  program 3dWarp.

- oneline:

  Logical. indicates that the resulting matrixwill simply be written as
  12 numbers on one line.

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
