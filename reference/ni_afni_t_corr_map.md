# AFNI TCorrMap

For each voxel time series, computes the correlation between it

## Usage

``` r
ni_afni_t_corr_map(
  in_file,
  absolute_threshold = NULL,
  args = NULL,
  automask = NULL,
  average_expr = NULL,
  average_expr_nonzero = NULL,
  bandpass = NULL,
  blur_fwhm = NULL,
  correlation_maps = NULL,
  correlation_maps_masked = NULL,
  histogram = NULL,
  mask = NULL,
  mean_file = NULL,
  out_file = NULL,
  pmean = NULL,
  polort = NULL,
  qmean = NULL,
  regress_out_timeseries = NULL,
  seeds = NULL,
  seeds_width = NULL,
  sum_expr = NULL,
  var_absolute_threshold = NULL,
  var_absolute_threshold_normalize = NULL,
  zmean = NULL,
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

  Character; file path **Required.**

- absolute_threshold:

  Character; file path

- args:

  Character. Additional parameters to the command

- automask:

  Logical

- average_expr:

  Character; file path

- average_expr_nonzero:

  Character; file path

- bandpass:

  Character or numeric vector

- blur_fwhm:

  Numeric

- correlation_maps:

  Character; file path

- correlation_maps_masked:

  Character; file path

- histogram:

  Character; file path

- mask:

  Character; file path

- mean_file:

  Character; file path

- out_file:

  Character; file path. output image file name

- pmean:

  Character; file path

- polort:

  Integer

- qmean:

  Character; file path

- regress_out_timeseries:

  Character; file path

- seeds:

  Character; file path

- seeds_width:

  Numeric

- sum_expr:

  Character; file path

- var_absolute_threshold:

  Character; file path

- var_absolute_threshold_normalize:

  Character; file path

- zmean:

  Character; file path

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
