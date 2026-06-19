# FREESURFER EditWMwithAseg

Edits a wm file using a segmentation

## Usage

``` r
ni_freesurfer_edit_w_mwith_aseg(
  brain_file,
  in_file,
  out_file,
  seg_file,
  args = NULL,
  keep_in = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- brain_file:

  Character; file path. Input brain/T1 file **Required.**

- in_file:

  Character; file path. Input white matter segmentation file
  **Required.**

- out_file:

  Character; file path. File to be written as output **Required.**

- seg_file:

  Character; file path. Input presurf segmentation file **Required.**

- args:

  Character. Additional parameters to the command

- keep_in:

  Logical. Keep edits as found in input volume

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
