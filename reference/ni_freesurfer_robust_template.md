# FREESURFER RobustTemplate

construct an unbiased robust template for longitudinal volumes

## Usage

``` r
ni_freesurfer_robust_template(
  auto_detect_sensitivity,
  in_files,
  out_file,
  outlier_sensitivity,
  args = NULL,
  average_metric = NULL,
  fixed_timepoint = NULL,
  in_intensity_scales = NULL,
  initial_timepoint = NULL,
  initial_transforms = NULL,
  intensity_scaling = NULL,
  no_iteration = NULL,
  scaled_intensity_outputs = NULL,
  subsample_threshold = NULL,
  transform_outputs = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- auto_detect_sensitivity:

  Logical. auto-detect good sensitivity (recommended for head or full
  brain scans) **Required.**

- in_files:

  Character or numeric vector. input movable volumes to be aligned to
  common mean/median template **Required.**

- out_file:

  Character; file path. output template volume (final mean/median image)
  **Required.**

- outlier_sensitivity:

  Numeric. set outlier sensitivity manually (e.g. "–sat 4.685" ). Higher
  values mean less sensitivity. **Required.**

- args:

  Character. Additional parameters to the command

- average_metric:

  Character; one of: "median", "mean". construct template from: 0 Mean,
  1 Median (default)

- fixed_timepoint:

  Logical. map everything to init TP# (init TP is not resampled)

- in_intensity_scales:

  Character or numeric vector. use initial intensity scales

- initial_timepoint:

  Integer. use TP# for special init (default random), 0: no init

- initial_transforms:

  Character or numeric vector. use initial transforms (lta) on source

- intensity_scaling:

  Logical. allow also intensity scaling (default off)

- no_iteration:

  Logical. do not iterate, just create first template

- scaled_intensity_outputs:

  Character or numeric vector. final intensity scales (will activate
  –iscale)

- subsample_threshold:

  Integer. subsample if dim \> \# on all axes (default no subs.)

- transform_outputs:

  Character or numeric vector. output xforms to template (for each
  input)

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
