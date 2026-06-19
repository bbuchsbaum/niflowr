# FSL ImageStats

Use FSL fslstats command to calculate stats from images

## Usage

``` r
ni_fsl_image_stats(
  in_file,
  op_string,
  args = NULL,
  index_mask_file = NULL,
  split_4d = NULL,
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

  Character; file path. input file to generate stats of **Required.**

- op_string:

  Character. string defining the operation, options are applied in
  order, e.g. -M -l 10 -M will report the non-zero mean, apply a
  threshold and then report the new nonzero mean **Required.**

- args:

  Character. Additional parameters to the command

- index_mask_file:

  Character; file path. generate separate n submasks from indexMask, for
  indexvalues 1..n where n is the maximum index value in indexMask, and
  generate statistics for each submask

- split_4d:

  Logical. give a separate output line for each 3D volume of a 4D
  timeseries

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
