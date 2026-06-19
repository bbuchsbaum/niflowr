# FREESURFER ExtractMainComponent

Extract the main component of a tessellated surface

## Usage

``` r
ni_freesurfer_extract_main_component(
  in_file,
  args = NULL,
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

  Character; file path. input surface file **Required.**

- args:

  Character. Additional parameters to the command

- out_file:

  Character; file path. surface containing main component

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
