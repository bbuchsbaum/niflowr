# AFNI Means

Takes the voxel-by-voxel mean of all input datasets using 3dMean

## Usage

``` r
ni_afni_means(
  in_file_a,
  args = NULL,
  count = NULL,
  datum = NULL,
  in_file_b = NULL,
  mask_inter = NULL,
  mask_union = NULL,
  non_zero = NULL,
  out_file = NULL,
  scale = NULL,
  sqr = NULL,
  std_dev = NULL,
  summ = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- in_file_a:

  Character; file path. input file to 3dMean **Required.**

- args:

  Character. Additional parameters to the command

- count:

  Logical. compute count of non-zero voxels

- datum:

  Character. Sets the data type of the output dataset

- in_file_b:

  Character; file path. another input file to 3dMean

- mask_inter:

  Logical. create intersection mask

- mask_union:

  Logical. create union mask

- non_zero:

  Logical. use only non-zero values

- out_file:

  Character; file path. output image file name

- scale:

  Character. scaling of output

- sqr:

  Logical. mean square instead of value

- std_dev:

  Logical. calculate std dev

- summ:

  Logical. take sum, (not average)

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
