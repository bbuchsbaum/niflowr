# FSL FUGUE

FSL FUGUE set of tools for EPI distortion correction

## Usage

``` r
ni_fsl_fugue(
  args = NULL,
  asym_se_time = NULL,
  despike_2dfilter = NULL,
  despike_threshold = NULL,
  dwell_time = NULL,
  dwell_to_asym_ratio = NULL,
  fmap_in_file = NULL,
  fmap_out_file = NULL,
  fourier_order = NULL,
  icorr = NULL,
  icorr_only = NULL,
  in_file = NULL,
  mask_file = NULL,
  median_2dfilter = NULL,
  no_extend = NULL,
  no_gap_fill = NULL,
  nokspace = NULL,
  pava = NULL,
  phase_conjugate = NULL,
  phasemap_in_file = NULL,
  poly_order = NULL,
  save_unmasked_fmap = NULL,
  save_unmasked_shift = NULL,
  shift_in_file = NULL,
  shift_out_file = NULL,
  smooth2d = NULL,
  smooth3d = NULL,
  unwarp_direction = NULL,
  unwarped_file = NULL,
  warped_file = NULL,
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

- asym_se_time:

  Numeric. set the fieldmap asymmetric spin echo time (sec)

- despike_2dfilter:

  Logical. apply a 2D de-spiking filter

- despike_threshold:

  Numeric. specify the threshold for de-spiking (default=3.0)

- dwell_time:

  Numeric. set the EPI dwell time per phase-encode line - same as echo
  spacing - (sec)

- dwell_to_asym_ratio:

  Numeric. set the dwell to asym time ratio

- fmap_in_file:

  Character; file path. filename for loading fieldmap (rad/s)

- fmap_out_file:

  Character; file path. filename for saving fieldmap (rad/s)

- fourier_order:

  Integer. apply Fourier (sinusoidal) fitting of order N

- icorr:

  Logical. apply intensity correction to unwarping (pixel shift method
  only)

- icorr_only:

  Logical. apply intensity correction only

- in_file:

  Character; file path. filename of input volume

- mask_file:

  Character; file path. filename for loading valid mask

- median_2dfilter:

  Logical. apply 2D median filtering

- no_extend:

  Logical. do not apply rigid-body extrapolation to the fieldmap

- no_gap_fill:

  Logical. do not apply gap-filling measure to the fieldmap

- nokspace:

  Logical. do not use k-space forward warping

- pava:

  Logical. apply monotonic enforcement via PAVA

- phase_conjugate:

  Logical. apply phase conjugate method of unwarping

- phasemap_in_file:

  Character; file path. filename for input phase image

- poly_order:

  Integer. apply polynomial fitting of order N

- save_unmasked_fmap:

  Logical. saves the unmasked fieldmap when using –savefmap

- save_unmasked_shift:

  Logical. saves the unmasked shiftmap when using –saveshift

- shift_in_file:

  Character; file path. filename for reading pixel shift volume

- shift_out_file:

  Character; file path. filename for saving pixel shift volume

- smooth2d:

  Numeric. apply 2D Gaussian smoothing of sigma N (in mm)

- smooth3d:

  Numeric. apply 3D Gaussian smoothing of sigma N (in mm)

- unwarp_direction:

  Character; one of: "x", "y", "z", "x-", "y-", "z-". specifies
  direction of warping (default y)

- unwarped_file:

  Character; file path. apply unwarping and save as filename

- warped_file:

  Character; file path. apply forward warping and save as filename

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
