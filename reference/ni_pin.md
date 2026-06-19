# Create/update a runtime lockfile

Resolves configured runtime profiles and writes a lockfile that captures
the pinned references used for reproducible execution.

## Usage

``` r
ni_pin(
  path = NULL,
  cfg = NULL,
  profiles = NULL,
  pull = TRUE,
  include_specs = TRUE
)
```

## Arguments

- path:

  Lockfile path. Defaults to `runtime.lockfile` in config (or
  `"niflowr.lock.yml"`).

- cfg:

  Optional resolved config list. Defaults to current effective config.

- profiles:

  Optional subset of profile names to lock. Defaults to all configured
  profiles.

- pull:

  Logical; allow pulling/resolving container artifacts when needed.

- include_specs:

  Logical; include spec id/version/profile index.

## Value

Parsed lock object (invisibly).
