# Validate a spec JSON file against the schema

Validates the raw JSON (before parsing) to preserve array types.

## Usage

``` r
ni_spec_validate_file(path)
```

## Arguments

- path:

  Path to a JSON spec file.

## Value

Invisible `TRUE` on success; raises an error on failure.
