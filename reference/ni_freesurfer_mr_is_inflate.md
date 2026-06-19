# FREESURFER MRIsInflate

This program will inflate a cortical surface.

## Usage

``` r
ni_freesurfer_mr_is_inflate(
  in_file,
  args = NULL,
  no_save_sulc = NULL,
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

  Character; file path. Input file for MRIsInflate **Required.**

- args:

  Character. Additional parameters to the command

- no_save_sulc:

  Logical. Do not save sulc file as output

- out_file:

  Character; file path. Output file for MRIsInflate

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
