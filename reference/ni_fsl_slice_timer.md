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
  custom_timing_units = NULL,
  timing_reference = NULL,
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

  Character; file path. Single-column FSL forward shifts in fractions of
  TR. Negative values shift data backwards. custom_timing_units and
  timing_reference are required.

- global_shift:

  Numeric. Global forward shift in fractions of TR; 0 means no global
  shift.

- index_dir:

  Logical. slice indexing from top to bottom

- interleaved:

  Logical. use interleaved acquisition

- out_file:

  Character; file path. Requested corrected NIfTI path. slicetimer
  receives its extension-free stem and FSL appends the configured NIFTI
  or NIFTI_GZ suffix.

- slice_direction:

  Character; one of: "1", "2", "3". direction of slice acquisition (x=1,
  y=2, z=3) - default is z

- time_repetition:

  Numeric. Repetition time in seconds.

- custom_timing_units:

  Character; one of: "fraction_of_tr". Units contract for
  custom_timings; FSL accepts forward-shift fractions of TR only.

- timing_reference:

  Character; one of: "forward_shift_to_reference". Interpretation
  contract for custom_timings: every file value is a forward shift to
  the declared reference.

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
