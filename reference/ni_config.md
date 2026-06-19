# Get or update niflowr runtime configuration

By default, `ni_config()` returns the effective configuration computed
as:

## Usage

``` r
ni_config(
  derivatives_dir = NULL,
  config = NULL,
  config_file = NULL,
  auto_read = NULL,
  .reset = FALSE
)
```

## Arguments

- derivatives_dir:

  Base directory used for inferred BIDS-derivatives outputs. Default:
  `"derivatives/niflowr"`.

- config:

  Optional named list of configuration overrides to merge into in-memory
  overrides.

- config_file:

  Path to project config file. Default: `"niflowr.yml"`.

- auto_read:

  Logical; if `TRUE`, read `config_file` automatically when resolving
  config.

- .reset:

  Logical; if `TRUE`, reset in-memory overrides and behavior.

## Value

Named list with current effective configuration.

## Details

`defaults <- niflowr defaults`

`file <- niflowr.yml (if present and auto_read = TRUE)`

`effective <- merge(defaults, file, in_memory_overrides)`
