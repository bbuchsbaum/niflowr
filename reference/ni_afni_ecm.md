# AFNI ECM

Performs degree centrality on a dataset using a given maskfile

## Usage

``` r
ni_afni_ecm(
  in_file,
  args = NULL,
  autoclip = NULL,
  automask = NULL,
  eps = NULL,
  fecm = NULL,
  full = NULL,
  mask = NULL,
  max_iter = NULL,
  memory = NULL,
  out_file = NULL,
  polort = NULL,
  scale = NULL,
  shift = NULL,
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

  Character; file path. input file to 3dECM **Required.**

- args:

  Character. Additional parameters to the command

- autoclip:

  Logical. Clip off low-intensity regions in the dataset

- automask:

  Logical. Mask the dataset to target brain-only voxels

- eps:

  Numeric. sets the stopping criterion for the power iteration;
  :math:`l2\\|v_\\text\{old\} - v_\\text\{new\}\\| < eps\\|v_\\text\{old\}\\|`;
  default = 0.001

- fecm:

  Logical. Fast centrality method; substantial speed increase but cannot
  accommodate thresholding; automatically selected if -thresh or
  -sparsity are not set

- full:

  Logical. Full power method; enables thresholding; automatically
  selected if -thresh or -sparsity are set

- mask:

  Character; file path. mask file to mask input data

- max_iter:

  Integer. sets the maximum number of iterations to use in the power
  iteration; default = 1000

- memory:

  Numeric. Limit memory consumption on system by setting the amount of
  GB to limit the algorithm to; default = 2GB

- out_file:

  Character; file path. output image file name

- polort:

  Integer

- scale:

  Numeric. scale correlation coefficients in similarity matrix to after
  shifting, x \>= 0.0; default = 1.0 for -full, 0.5 for -fecm

- shift:

  Numeric. shift correlation coefficients in similarity matrix to
  enforce non-negativity, s \>= 0.0; default = 0.0 for -full, 1.0 for
  -fecm

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
