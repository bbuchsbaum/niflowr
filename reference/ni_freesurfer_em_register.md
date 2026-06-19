# FREESURFER EMRegister

This program creates a transform in lta format

## Usage

``` r
ni_freesurfer_em_register(
  in_file,
  template,
  args = NULL,
  mask = NULL,
  nbrspacing = NULL,
  out_file = NULL,
  skull = NULL,
  transform = NULL,
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

  Character; file path. in brain volume **Required.**

- template:

  Character; file path. template gca **Required.**

- args:

  Character. Additional parameters to the command

- mask:

  Character; file path. use volume as a mask

- nbrspacing:

  Integer. align to atlas containing skull setting unknown_nbr_spacing =
  nbrspacing

- out_file:

  Character; file path. output transform

- skull:

  Logical. align to atlas containing skull (uns=5)

- transform:

  Character; file path. Previously computed transform

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
