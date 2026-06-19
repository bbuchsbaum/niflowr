# AFNI Resample

Resample or reorient an image using AFNI 3dresample command

## Usage

``` r
ni_afni_resample(
  in_file,
  args = NULL,
  master = NULL,
  orientation = NULL,
  out_file = NULL,
  resample_mode = NULL,
  voxel_size = NULL,
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

  Character; file path. input file to 3dresample **Required.**

- args:

  Character. Additional parameters to the command

- master:

  Character; file path. align dataset grid to a reference file

- orientation:

  Character. new orientation code

- out_file:

  Character; file path. output image file name

- resample_mode:

  Character; one of: "NN", "Li", "Cu", "Bk". resampling method from set
  {"NN", "Li", "Cu", "Bk"}. These are for "Nearest Neighbor", "Linear",
  "Cubic" and "Blocky"interpolation, respectively. Default is NN.

- voxel_size:

  Character or numeric vector. resample to new dx, dy and dz

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
