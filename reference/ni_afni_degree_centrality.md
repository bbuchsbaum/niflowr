# AFNI DegreeCentrality

Performs degree centrality on a dataset using a given maskfile

## Usage

``` r
ni_afni_degree_centrality(
  in_file,
  args = NULL,
  autoclip = NULL,
  automask = NULL,
  mask = NULL,
  oned_file = NULL,
  out_file = NULL,
  polort = NULL,
  sparsity = NULL,
  thresh = NULL,
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

  Character; file path. input file to 3dDegreeCentrality **Required.**

- args:

  Character. Additional parameters to the command

- autoclip:

  Logical. Clip off low-intensity regions in the dataset

- automask:

  Logical. Mask the dataset to target brain-only voxels

- mask:

  Character; file path. mask file to mask input data

- oned_file:

  Character. output filepath to text dump of correlation matrix

- out_file:

  Character; file path. output image file name

- polort:

  Integer

- sparsity:

  Numeric. only take the top percent of connections

- thresh:

  Numeric. threshold to exclude connections where corr \<= thresh

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
