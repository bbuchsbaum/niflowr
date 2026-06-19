# FREESURFER WatershedSkullStrip

This program strips skull and other outer non-brain tissue and

## Usage

``` r
ni_freesurfer_watershed_skull_strip(
  in_file,
  out_file,
  args = NULL,
  brain_atlas = NULL,
  t1 = NULL,
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

  Character; file path. input volume **Required.**

- out_file:

  Character; file path. output volume **Required.**

- args:

  Character. Additional parameters to the command

- brain_atlas:

  Character; file path

- t1:

  Logical. specify T1 input volume (T1 grey value = 110)

- transform:

  Character; file path. undocumented

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
