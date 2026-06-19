# Run a spec as a dry run

Shorthand for `ni_run(ni_call(spec, ...), dry_run = TRUE)`.

## Usage

``` r
ni_dry_run(spec_id, ...)
```

## Arguments

- spec_id:

  A spec ID (e.g. `"fsl.bet"`), path to a JSON file, or an `ni_spec`
  object.

- ...:

  Named parameter values.
