# FREESURFER Resample

Use FreeSurfer mri_convert to up or down-sample image files

## Usage

``` r
ni_freesurfer_resample(
  in_file,
  voxel_size,
  args = NULL,
  resampled_file = NULL,
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

  Character; file path. file to resample **Required.**

- voxel_size:

  Character or numeric vector. triplet of output voxel sizes
  **Required.**

- args:

  Character. Additional parameters to the command

- resampled_file:

  Character; file path. output filename

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
