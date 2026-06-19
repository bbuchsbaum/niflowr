# FREESURFER RemoveNeck

Crops the neck out of the mri image

## Usage

``` r
ni_freesurfer_remove_neck(
  in_file,
  template,
  transform,
  args = NULL,
  out_file = NULL,
  radius = NULL,
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

  Character; file path. Input file for RemoveNeck **Required.**

- template:

  Character; file path. Input template file for RemoveNeck **Required.**

- transform:

  Character; file path. Input transform file for RemoveNeck
  **Required.**

- args:

  Character. Additional parameters to the command

- out_file:

  Character; file path. Output file for RemoveNeck

- radius:

  Integer. Radius

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
