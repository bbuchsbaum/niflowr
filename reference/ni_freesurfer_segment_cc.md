# FREESURFER SegmentCC

This program segments the corpus callosum into five separate labels in

## Usage

``` r
ni_freesurfer_segment_cc(
  in_file,
  in_norm,
  out_rotation,
  subject_id,
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

  Character; file path. Input aseg file to read from subjects directory
  **Required.**

- in_norm:

  Character; file path. Required undocumented input
  {subject}/mri/norm.mgz **Required.**

- out_rotation:

  Character; file path. Global filepath for writing rotation lta
  **Required.**

- subject_id:

  Character. Subject name **Required.**

- args:

  Character. Additional parameters to the command

- out_file:

  Character; file path. Filename to write aseg including CC

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
