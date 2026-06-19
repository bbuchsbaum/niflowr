# AFNI NwarpAdjust

This program takes as input a bunch of 3D warps, averages them,

## Usage

``` r
ni_afni_nwarp_adjust(
  warps,
  args = NULL,
  in_files = NULL,
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

- warps:

  Character or numeric vector. List of input 3D warp datasets
  **Required.**

- args:

  Character. Additional parameters to the command

- in_files:

  Character or numeric vector. List of input 3D datasets to be warped by
  the adjusted warp datasets. There must be exactly as many of these
  datasets as there are input warps.

- out_file:

  Character; file path. Output mean dataset, only needed if in_files are
  also given. The output dataset will be on the common grid shared by
  the source datasets.

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
