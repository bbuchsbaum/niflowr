# FREESURFER ImageInfo

General support for FreeSurfer commands.

## Usage

``` r
ni_freesurfer_image_info(
  args = NULL,
  in_file = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- args:

  Character. Additional parameters to the command

- in_file:

  Character; file path. image to query

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
