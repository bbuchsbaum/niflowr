# Validate parameter values against a spec

Checks required params, types, file existence, numeric ranges, enum
membership, xor constraints, and requires constraints.

## Usage

``` r
validate_inputs(spec, values)
```

## Arguments

- spec:

  An `ni_spec` object.

- values:

  Named list of parameter values.

## Value

Invisible `TRUE` on success; raises an error on failure.
