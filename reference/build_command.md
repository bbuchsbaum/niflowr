# Build a command argument vector from an ni_call

Implements the argstr/position/flag/sep rules to produce a safe
character vector of arguments (never a shell string).

## Usage

``` r
build_command(call)
```

## Arguments

- call:

  An `ni_call` object.

## Value

A list with components `command`, `args`, `stdout`, `stderr`.
