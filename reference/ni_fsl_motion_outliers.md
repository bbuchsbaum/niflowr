# FSL MotionOutliers

Use FSL
fsl_motion_outliers`http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSLMotionOutliers`\_
to find outliers in timeseries (4d) data.

## Usage

``` r
ni_fsl_motion_outliers(
  in_file,
  args = NULL,
  dummy = NULL,
  mask = NULL,
  metric = NULL,
  no_motion_correction = NULL,
  out_file = NULL,
  out_metric_plot = NULL,
  out_metric_values = NULL,
  threshold = NULL,
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

  Character; file path. unfiltered 4D image **Required.**

- args:

  Character. Additional parameters to the command

- dummy:

  Integer. number of dummy scans to delete (before running anything and
  creating EVs)

- mask:

  Character; file path. mask image for calculating metric

- metric:

  Character; one of: "refrms", "dvars", "refmse", "fd", "fdrms".
  metrics: refrms - RMS intensity difference to reference volume as
  metric \[default metric\], refmse - Mean Square Error version of
  refrms (used in original version of fsl_motion_outliers), dvars -
  DVARS, fd - frame displacement, fdrms - FD with RMS matrix calculation

- no_motion_correction:

  Logical. do not run motion correction (assumed already done)

- out_file:

  Character; file path. output outlier file name

- out_metric_plot:

  Character; file path. output metric values plot (DVARS etc.) file name

- out_metric_values:

  Character; file path. output metric values (DVARS etc.) file name

- threshold:

  Numeric. specify absolute threshold value (otherwise use box-plot
  cutoff = P75 + 1.5\*IQR)

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
