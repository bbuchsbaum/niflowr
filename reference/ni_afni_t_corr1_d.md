# AFNI TCorr1D

Computes the correlation coefficient between each voxel time series

## Usage

``` r
ni_afni_t_corr1_d(
  xset,
  y_1d,
  args = NULL,
  ktaub = NULL,
  out_file = NULL,
  pearson = NULL,
  quadrant = NULL,
  spearman = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- xset:

  Character; file path. 3d+time dataset input **Required.**

- y_1d:

  Character; file path. 1D time series file input **Required.**

- args:

  Character. Additional parameters to the command

- ktaub:

  Logical. Correlation is the Kendall's tau_b correlation coefficient

- out_file:

  Character; file path. output filename prefix

- pearson:

  Logical. Correlation is the normal Pearson correlation coefficient

- quadrant:

  Logical. Correlation is the quadrant correlation coefficient

- spearman:

  Logical. Correlation is the Spearman (rank) correlation coefficient

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
