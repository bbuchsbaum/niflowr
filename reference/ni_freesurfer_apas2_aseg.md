# FREESURFER Apas2Aseg

Converts aparc+aseg.mgz into something like aseg.mgz by replacing the

## Usage

``` r
ni_freesurfer_apas2_aseg(
  in_file,
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

- in_file:

  Character; file path. Input aparc+aseg.mgz **Required.**

- out_file:

  Character; file path. Output aseg file **Required.**

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
