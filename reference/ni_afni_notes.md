# AFNI Notes

A program to add, delete, and show notes for AFNI datasets.

## Usage

``` r
ni_afni_notes(
  in_file,
  add = NULL,
  add_history = NULL,
  args = NULL,
  delete = NULL,
  out_file = NULL,
  rep_history = NULL,
  ses = NULL,
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

  Character; file path. input file to 3dNotes **Required.**

- add:

  Character. note to add

- add_history:

  Character. note to add to history

- args:

  Character. Additional parameters to the command

- delete:

  Integer. delete note number num

- out_file:

  Character; file path. output image file name

- rep_history:

  Character. note with which to replace history

- ses:

  Logical. print to stdout the expanded notes

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
