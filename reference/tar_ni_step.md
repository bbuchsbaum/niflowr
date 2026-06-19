# Create a targets-compatible neuroimaging processing step

A target factory that wraps an niflowr call as a `targets::tar_target()`
with `format = "file"`, so outputs are tracked as file dependencies.

## Usage

``` r
tar_ni_step(
  name,
  spec_id,
  ...,
  packages = "niflowr",
  priority = 0,
  pattern = NULL
)
```

## Arguments

- name:

  Symbol; target name.

- spec_id:

  Spec ID string (e.g. `"fsl.bet"`).

- ...:

  Named arguments passed to
  [`ni_call()`](https://bbuchsbaum.github.io/niflowr/reference/ni_call.md).

- packages:

  Character vector of packages to load. Default includes `"niflowr"`.

- priority:

  Numeric priority for target scheduling (0 to 1).

- pattern:

  A dynamic branching pattern (e.g. `map(subjects)`).

## Value

A `tar_target` object.
