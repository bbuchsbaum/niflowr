# FREESURFER AddXFormToHeader

Just adds specified xform to the volume header.

## Usage

``` r
ni_freesurfer_add_x_form_to_header(
  in_file,
  transform,
  args = NULL,
  copy_name = NULL,
  out_file = "output.mgz",
  verbose = NULL,
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

  Character; file path. input volume **Required.**

- transform:

  Character; file path. xfm file **Required.**

- args:

  Character. Additional parameters to the command

- copy_name:

  Logical. do not try to load the xfmfile, just copy name

- out_file:

  Character; file path. output volume

- verbose:

  Logical. be verbose

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
