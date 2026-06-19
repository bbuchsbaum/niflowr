# AFNI Dot

Correlation coefficient between sub-brick pairs.

## Usage

``` r
ni_afni_dot(
  args = NULL,
  demean = NULL,
  docoef = NULL,
  docor = NULL,
  dodice = NULL,
  dodot = NULL,
  doeta2 = NULL,
  dosums = NULL,
  full = NULL,
  in_files = NULL,
  mask = NULL,
  mrange = NULL,
  out_file = NULL,
  show_labels = NULL,
  upper = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- args:

  Character. Additional parameters to the command

- demean:

  Logical. Remove the mean from each volume prior to computing the
  correlation

- docoef:

  Logical. Return the least square fit coefficients {{a,b}} so that
  dset2 is approximately a + b\\dset1

- docor:

  Logical. Return the correlation coefficient (default).

- dodice:

  Logical. Return the Dice coefficient (the Sorensen-Dice index).

- dodot:

  Logical. Return the dot product (unscaled).

- doeta2:

  Logical. Return eta-squared (Cohen, NeuroImage 2008).

- dosums:

  Logical. Return the 6 numbers xbar= ybar= \<(x-xbar)^2\>
  \<(y-ybar)^2\> \<(x-xbar)(y-ybar)\> and the correlation coefficient.

- full:

  Logical. Compute the whole matrix. A waste of time, but handy for
  parsing.

- in_files:

  Character or numeric vector. list of input files, possibly with
  subbrick selectors

- mask:

  Character; file path. Use this dataset as a mask

- mrange:

  Character or numeric vector. Means to further restrict the voxels from
  'mset' so thatonly those mask values within this range (inclusive)
  willbe used.

- out_file:

  Character; file path. collect output to a file

- show_labels:

  Logical. Print sub-brick labels to help identify what is being
  correlated. This option is useful whenyou have more than 2 sub-bricks
  at input.

- upper:

  Logical. Compute upper triangular matrix

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
