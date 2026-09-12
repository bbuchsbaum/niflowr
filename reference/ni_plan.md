# Resolve an inspectable execution plan

Resolves the selected engine, environment overrides (configuration \<
spec \< call), working directories, mounts, payload and execution argv.
No workload is launched. Mount directories may be created and unmapped
inputs staged.

## Usage

``` r
ni_plan(call)
```

## Arguments

- call:

  An `ni_call` object.

## Value

An `ni_execution_plan` list, also returned by `ni_run(dry_run = TRUE)`.
