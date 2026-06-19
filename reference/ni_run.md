# Execute an ni_call

Validates inputs, builds an argument vector, resolves runtime engine
(`native`, `docker`, `apptainer`), executes via
[`processx::run()`](http://processx.r-lib.org/reference/run.md), checks
outputs, and returns a structured result.

## Usage

``` r
ni_run(
  call,
  ...,
  dry_run = FALSE,
  echo = interactive(),
  provenance = TRUE,
  error_on_status = TRUE,
  return = c("result", "files")
)
```

## Arguments

- call:

  An `ni_call` object, or a spec ID (in which case remaining args are
  passed to
  [`ni_call()`](https://bbuchsbaum.github.io/niflowr/reference/ni_call.md)).

- ...:

  If `call` is a spec ID, passed to
  [`ni_call()`](https://bbuchsbaum.github.io/niflowr/reference/ni_call.md).

- dry_run:

  Logical; if `TRUE`, print the resolved command and return without
  executing.

- echo:

  Logical; if `TRUE`, print stdout/stderr in real time. Defaults to
  [`interactive()`](https://rdrr.io/r/base/interactive.html).

- provenance:

  Logical; write a provenance JSON sidecar. Default `TRUE`.

- error_on_status:

  Logical; if `TRUE` (default), error when the command exits with a
  non-zero status. If `FALSE`, issue a warning instead.

- return:

  One of `"result"` (default) or `"files"`.

## Value

An `ni_result` object, or (when `return = "files"`) a character vector
of output files with the full result attached as `ni_result` attribute.
