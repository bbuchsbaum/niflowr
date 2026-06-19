# AFNI BrickStat

Computes maximum and/or minimum voxel values of an input dataset.

## Usage

``` r
ni_afni_brick_stat(
  in_file,
  args = NULL,
  mask = NULL,
  max = NULL,
  mean = NULL,
  min = NULL,
  percentile = NULL,
  slow = NULL,
  sum = NULL,
  var = NULL,
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

  Character; file path. input file to 3dmaskave **Required.**

- args:

  Character. Additional parameters to the command

- mask:

  Character; file path. -mask dset = use dset as mask to include/exclude
  voxels

- max:

  Logical. print the maximum value in the dataset

- mean:

  Logical. print the mean value in the dataset

- min:

  Logical. print the minimum value in dataset

- percentile:

  Character or numeric vector. p0 ps p1 write the percentile values
  starting at p0% and ending at p1% at a step of ps%. only one sub-brick
  is accepted.

- slow:

  Logical. read the whole dataset to find the min and max values

- sum:

  Logical. print the sum of values in the dataset

- var:

  Logical. print the variance in the dataset

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
