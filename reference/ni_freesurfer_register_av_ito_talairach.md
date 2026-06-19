# FREESURFER RegisterAVItoTalairach

converts the vox2vox from talairach_avi to a talairach.xfm file

## Usage

``` r
ni_freesurfer_register_av_ito_talairach(
  in_file,
  target,
  vox2vox,
  args = NULL,
  out_file = "talairach.auto.xfm",
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

  Character; file path. The input file **Required.**

- target:

  Character; file path. The target file **Required.**

- vox2vox:

  Character; file path. The vox2vox file **Required.**

- args:

  Character. Additional parameters to the command

- out_file:

  Character; file path. The transform output

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
