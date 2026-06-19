# Run an niflowr call and return output file paths

Convenience function for use inside `tar_target()` expressions. Runs the
call and returns a character vector of output paths, suitable for
`format = "file"` targets.

## Usage

``` r
ni_run_files(spec_id, ...)
```

## Arguments

- spec_id:

  Spec ID or `ni_spec` object.

- ...:

  Named arguments passed to
  [`ni_call()`](https://bbuchsbaum.github.io/niflowr/reference/ni_call.md).

## Value

Character vector of output file paths.
