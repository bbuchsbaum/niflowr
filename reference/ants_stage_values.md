# Per-stage values for a staged antsRegistration input

Returns a list with one element per stage. Each element is an atomic
vector: a single value, or several (the metrics of a multi-metric stage,
or the levels of an iteration ladder). A single element applies to every
stage. Any other length is a mis-specified stage list, so it is an error
rather than silently wrapped around onto the wrong stages.

## Usage

``` r
ants_stage_values(x, name, n_stages, allow_missing = FALSE)
```

## Arguments

- allow_missing:

  Whether `NULL`/`NA` entries are allowed (they mean "omit" for optional
  per-metric settings such as sampling).
