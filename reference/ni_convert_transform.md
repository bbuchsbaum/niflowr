# Convert a declared transform output to another format

Reads a transform with
[`ni_read_transform()`](https://bbuchsbaum.github.io/niflowr/reference/ni_read_transform.md)
and writes the same geometric mapping in another supported convention.
Affine transforms can be converted among generic text, FSL FLIRT,
ITK/ANTs, AFNI, FreeSurfer LTA, and X5. Warp and composite transforms
can be written as X5; a single warp can also be written as an
ANTs-compatible NIfTI vector field.

## Usage

``` r
ni_convert_transform(
  result,
  path,
  format = c("generic", "fsl", "itk", "afni", "lta", "x5", "ants"),
  output_name = NULL,
  source_image = NULL,
  target_image = NULL,
  source = NULL,
  target = NULL,
  ...
)
```

## Arguments

- result:

  An `ni_result` object.

- path:

  Destination file path.

- format:

  Destination format.

- output_name:

  Name of the transform output. May be omitted when exactly one resolved
  output is declared as a transform.

- source_image, target_image:

  Optional image paths overriding the source and target images named in
  the spec metadata. These are mainly useful for FSL matrices, whose
  interpretation depends on both image geometries.

- source, target:

  Optional source and target domain identifiers stored on the returned
  morphism. By default the corresponding image paths are used.

- ...:

  Additional arguments passed to the selected `neurotransform` reader.

## Value

`path`, invisibly.
