# Validate current runtime config against lockfile

Validate current runtime config against lockfile

## Usage

``` r
ni_lock_validate(
  path = NULL,
  cfg = NULL,
  profiles = NULL,
  strict = FALSE,
  check_sif = TRUE
)
```

## Arguments

- path:

  Lockfile path. Defaults to config `runtime.lockfile`.

- cfg:

  Optional resolved config list. Defaults to current effective config.

- profiles:

  Optional subset of profile names to validate.

- strict:

  Logical; if `TRUE`, abort on any validation failures.

- check_sif:

  Logical; verify SIF file existence/checksum when present.

## Value

Data frame with validation checks.
