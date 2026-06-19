# Run runtime diagnostics

Performs quick checks for runtime binaries, mount roots, profile shape,
and lockfile availability/consistency.

## Usage

``` r
ni_doctor(cfg = NULL, strict = FALSE, check_lock = TRUE)
```

## Arguments

- cfg:

  Optional resolved config list. Defaults to current effective config.

- strict:

  Logical; if `TRUE`, abort on any failed checks.

- check_lock:

  Logical; include lockfile checks.

## Value

Data frame with `check`, `status`, and `message` columns.
