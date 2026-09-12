# Run runtime diagnostics

Performs quick checks for runtime binaries, mount roots, profile shape,
and lockfile availability/consistency. When Docker is available,
optionally probes each profile image to confirm the payload command
actually runs (catching shell ENTRYPOINTs that silently ignore the
command).

## Usage

``` r
ni_doctor(cfg = NULL, strict = FALSE, check_lock = TRUE, check_payload = TRUE)
```

## Arguments

- cfg:

  Optional resolved config list. Defaults to current effective config.

- strict:

  Logical; if `TRUE`, abort on any failed checks.

- check_lock:

  Logical; include lockfile checks.

- check_payload:

  Logical; when `TRUE` (default), probe configured Docker profile images
  that are already present locally to verify the payload command
  executes. Skips profiles whose images are not available locally (does
  not pull).

## Value

Data frame with `check`, `status`, and `message` columns.
