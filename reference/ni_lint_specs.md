# Lint niflowr specs with optional autofix

Performs mechanical checks on spec JSON files (or parsed specs),
including: shell metacharacters in CLI arg strings, positional
collisions, invalid flag formats, and broken constraint references.

## Usage

``` r
ni_lint_specs(
  spec_dir = "inst/specs",
  spec_paths = NULL,
  strict = FALSE,
  fix = FALSE,
  write = fix
)
```

## Arguments

- spec_dir:

  Directory containing spec JSON files. Ignored if `spec_paths` is
  provided.

- spec_paths:

  Optional character vector of spec file paths to lint.

- strict:

  Logical; if `TRUE`, abort when lint errors remain.

- fix:

  Logical; if `TRUE`, apply safe autofixes in-memory.

- write:

  Logical; if `TRUE` and `fix = TRUE`, write modified specs back to
  disk.

## Value

A data frame (or tibble, if available) with lint findings.
