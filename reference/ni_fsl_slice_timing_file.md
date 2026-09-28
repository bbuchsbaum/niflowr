# Write an explicit FSL slicetimer custom-timing file

Converts slice acquisition times and a desired temporal reference into
the forward-shift fractions consumed by FSL `slicetimer --tcustom`. This
avoids passing BIDS `SliceTiming` seconds directly to an interface that
expects fractions of TR with opposite sign for later-acquired slices.

## Usage

``` r
ni_fsl_slice_timing_file(
  slice_timing,
  repetition_time,
  reference_time,
  path,
  units = "seconds"
)
```

## Arguments

- slice_timing:

  Numeric slice acquisition times.

- repetition_time:

  Positive scalar repetition time.

- reference_time:

  Scalar temporal reference within the TR.

- path:

  Destination text file.

- units:

  Units of all time values. Only `"seconds"` is accepted.

## Value

A record containing `path`, `shifts`, units, repetition time, and
reference time. Pass `result$path`,
`custom_timing_units = "fraction_of_tr"`, and
`timing_reference = "forward_shift_to_reference"` to
[`ni_fsl_slice_timer()`](https://bbuchsbaum.github.io/niflowr/reference/ni_fsl_slice_timer.md).
