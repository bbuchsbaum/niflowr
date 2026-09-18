# Per-stage values for a staged antsRegistration input

Element `i` is stage `i`'s value and a single value applies to every
stage. Any other length is a mis-specified stage list, so it is an error
rather than silently wrapped around onto the wrong stages.

## Usage

``` r
ants_stage_values(x, name, n_stages)
```
