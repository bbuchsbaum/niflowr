# AFNI TCat

Concatenate sub-bricks from input datasets into one big 3D+time dataset.

## Usage

``` r
ni_afni_t_cat(
  in_files,
  args = NULL,
  out_file = NULL,
  rlt = NULL,
  verbose = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- in_files:

  Character or numeric vector. input file to 3dTcat **Required.**

- args:

  Character. Additional parameters to the command

- out_file:

  Character; file path. output image file name

- rlt:

  Character; one of: "", "+", "++". Remove linear trends in each voxel
  time series loaded from each input dataset, SEPARATELY. Option -rlt
  removes the least squares fit of 'a+b\*t' to each voxel time series.
  Option -rlt+ adds dataset mean back in. Option -rlt++ adds overall
  mean of all dataset timeseries back in.

- verbose:

  Logical. Print out some verbose output as the program

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
