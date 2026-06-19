# AFNI Bandpass

Program to lowpass and/or highpass each voxel time series in a

## Usage

``` r
ni_afni_bandpass(
  highpass,
  in_file,
  lowpass,
  args = NULL,
  automask = NULL,
  blur = NULL,
  despike = NULL,
  localPV = NULL,
  mask = NULL,
  nfft = NULL,
  no_detrend = NULL,
  normalize = NULL,
  notrans = NULL,
  orthogonalize_dset = NULL,
  orthogonalize_file = NULL,
  out_file = NULL,
  tr = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- highpass:

  Numeric. highpass **Required.**

- in_file:

  Character; file path. input file to 3dBandpass **Required.**

- lowpass:

  Numeric. lowpass **Required.**

- args:

  Character. Additional parameters to the command

- automask:

  Logical. Create a mask from the input dataset.

- blur:

  Numeric. Blur (inside the mask only) with a filter width (FWHM) of
  'fff' millimeters.

- despike:

  Logical. Despike each time series before other processing. Hopefully,
  you don't actually need to do this, which is why it is optional.

- localPV:

  Numeric. Replace each vector by the local Principal Vector (AKA first
  singular vector) from a neighborhood of radius 'rrr' millimeters. Note
  that the PV time series is L2 normalized. This option is mostly for
  Bob Cox to have fun with.

- mask:

  Character; file path. mask file

- nfft:

  Integer. Set the FFT length \[must be a legal value\].

- no_detrend:

  Logical. Skip the quadratic detrending of the input that occurs before
  the FFT-based bandpassing. You would only want to do this if the
  dataset had been detrended already in some other program.

- normalize:

  Logical. Make all output time series have L2 norm = 1 (i.e., sum of
  squares = 1).

- notrans:

  Logical. Don't check for initial positive transients in the data. The
  test is a little slow, so skipping it is OK, if you KNOW the data time
  series are transient-free.

- orthogonalize_dset:

  Character; file path. Orthogonalize each voxel to the corresponding
  voxel time series in dataset 'fset', which must have the same spatial
  and temporal grid structure as the main input dataset. At present,
  only one '-dsort' option is allowed.

- orthogonalize_file:

  Character or numeric vector. Also orthogonalize input to columns in
  f.1D. Multiple '-ort' options are allowed.

- out_file:

  Character; file path. output file from 3dBandpass

- tr:

  Numeric. Set time step (TR) in sec \[default=from dataset header\].

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
