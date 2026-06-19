# AFNI TShift

Shifts voxel time series from input so that separate slices are aligned

## Usage

``` r
ni_afni_t_shift(
  in_file,
  args = NULL,
  ignore = NULL,
  interp = NULL,
  out_file = NULL,
  rlt = NULL,
  rltplus = NULL,
  slice_timing = NULL,
  tpattern = NULL,
  tr = NULL,
  tslice = NULL,
  tzero = NULL,
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

  Character; file path. input file to 3dTshift **Required.**

- args:

  Character. Additional parameters to the command

- ignore:

  Integer. ignore the first set of points specified

- interp:

  Character; one of: "Fourier", "linear", "cubic", "quintic", "heptic".
  different interpolation methods (see 3dTshift for details) default =
  Fourier

- out_file:

  Character; file path. output image file name

- rlt:

  Logical. Before shifting, remove the mean and linear trend

- rltplus:

  Logical. Before shifting, remove the mean and linear trend and later
  put back the mean

- slice_timing:

  Character or numeric vector. time offsets from the volume acquisition
  onset for each slice

- tpattern:

  Character or numeric vector. use specified slice time pattern rather
  than one in header

- tr:

  Character. manually set the TR. You can attach suffix "s" for seconds
  or "ms" for milliseconds.

- tslice:

  Integer. align each slice to time offset of given slice

- tzero:

  Numeric. align each slice to given time offset

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
