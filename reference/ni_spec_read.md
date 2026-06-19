# Read a niflowr interface spec

Load and validate a JSON spec by ID (looks in bundled specs) or by file
path.

## Usage

``` r
ni_spec_read(id_or_path, cache = TRUE)
```

## Arguments

- id_or_path:

  A spec ID (e.g. `"fsl.bet"`) or path to a JSON file.

- cache:

  Logical; cache the parsed spec for reuse. Default `TRUE`.

## Value

An `ni_spec` object (S3 list).
