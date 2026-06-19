# Read a transform output using neurotransform

Loads a spatial transform file from an ni_result using
`neurotransform::read_transform()`.

## Usage

``` r
ni_read_transform(result, output_name = NULL, type = NULL, ...)
```

## Arguments

- result:

  An `ni_result` object.

- output_name:

  Name of the transform output. If `NULL`, guesses from output names
  (looks for "warp", "affine", "matrix", "transform").

- type:

  Transform type (e.g. `"ants"`, `"fsl"`, `"freesurfer"`). If `NULL`,
  inferred from the spec id.

- ...:

  Additional arguments passed to `neurotransform::read_transform()`.

## Value

A neurotransform morphism object.
