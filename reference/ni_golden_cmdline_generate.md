# Generate golden command fixtures for all specs

Builds deterministic command/argument snapshots for each spec and writes
a single JSON fixture suitable for regression testing.

## Usage

``` r
ni_golden_cmdline_generate(
  output = "tests/golden/cmdline_golden.json",
  spec_ids = NULL,
  spec_dir = "inst/specs"
)
```

## Arguments

- output:

  Path to the golden JSON fixture file.

- spec_ids:

  Optional spec IDs. Defaults to all bundled specs.

- spec_dir:

  Directory containing specs when running from source.

## Value

Path written (invisibly).
