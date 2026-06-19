# AFNI Merge

Merge or edit volumes using AFNI 3dmerge command

## Usage

``` r
ni_afni_merge(
  in_files,
  args = NULL,
  blurfwhm = NULL,
  doall = NULL,
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

- in_files:

  Character or numeric vector **Required.**

- args:

  Character. Additional parameters to the command

- blurfwhm:

  Integer. FWHM blur value (mm)

- doall:

  Logical. apply options to all sub-bricks in dataset

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
