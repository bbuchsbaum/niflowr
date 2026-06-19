# AFNI TCorrelate

Computes the correlation coefficient between corresponding voxel

## Usage

``` r
ni_afni_t_correlate(
  xset,
  yset,
  args = NULL,
  out_file = NULL,
  pearson = NULL,
  polort = NULL,
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

  Character; file path. input xset **Required.**

- yset:

  Character; file path. input yset **Required.**

- args:

  Character. Additional parameters to the command

- out_file:

  Character; file path. output image file name

- pearson:

  Logical. Correlation is the normal Pearson correlation coefficient

- polort:

  Integer. Remove polynomial trend of order m

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
