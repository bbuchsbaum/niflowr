# FREESURFER MRIsCombine

Uses Freesurfer's `mris_convert` to combine two surface files into one.

## Usage

``` r
ni_freesurfer_mr_is_combine(
  in_files,
  out_file,
  args = NULL,
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

  Character or numeric vector. Two surfaces to be combined.
  **Required.**

- out_file:

  Character; file path. Output filename. Combined surfaces from
  in_files. **Required.**

- args:

  Character. Additional parameters to the command

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
