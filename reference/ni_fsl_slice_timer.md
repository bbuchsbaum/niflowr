# FSL SliceTimer

FSL slicetimer wrapper to perform slice timing correction

## Usage

``` r
ni_fsl_slice_timer(
  in_file,
  args = NULL,
  custom_order = NULL,
  custom_timings = NULL,
  global_shift = NULL,
  index_dir = NULL,
  interleaved = NULL,
  out_file = NULL,
  slice_direction = NULL,
  time_repetition = NULL,
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

  Character; file path. filename of input timeseries **Required.**

- args:

  Character. Additional parameters to the command

- custom_order:

  Character; file path. filename of single-column custom interleave
  order file (first slice is referred to as 1 not 0)

- custom_timings:

  Character; file path. slice timings, in fractions of TR, range 0:1
  (default is 0.5 = no shift)

- global_shift:

  Numeric. shift in fraction of TR, range 0:1 (default is 0.5 = no
  shift)

- index_dir:

  Logical. slice indexing from top to bottom

- interleaved:

  Logical. use interleaved acquisition

- out_file:

  Character; file path. filename of output timeseries

- slice_direction:

  Character; one of: "1", "2", "3". direction of slice acquisition (x=1,
  y=2, z=3) - default is z

- time_repetition:

  Numeric. Specify TR of data - default is 3s

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
