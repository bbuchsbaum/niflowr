# Measure how well a registration aligned

A registration can run, write a transform, and not fold while stopping
at a poor optimum. This reports the evidence that separates the two:
image similarity between the template and the moving image warped into
it, overlap of warped masks or labels, and the Jacobian determinant of
the transform. All image work runs through ANTs (`antsApplyTransforms`,
`MeasureImageSimilarity`, `CreateJacobianDeterminantImage`) on the same
engine as the registration.

## Usage

``` r
ni_ants_registration_qa(
  registration = NULL,
  fixed_image = NULL,
  moving_image = NULL,
  transform = NULL,
  fixed_mask = NULL,
  moving_mask = NULL,
  fixed_labels = NULL,
  moving_labels = NULL,
  similarity = c(MI = 32, CC = 4),
  interpolation = "Linear",
  jacobian = TRUE,
  keep_field = FALSE,
  out_dir = NULL,
  .engine = NULL,
  .profile = NULL,
  timeout = Inf,
  echo = FALSE
)
```

## Arguments

- registration:

  An `ni_result` from
  [`ni_ants_register_to_template()`](https://bbuchsbaum.github.io/niflowr/reference/ni_ants_register_to_template.md)
  or
  [`ni_ants_registration()`](https://bbuchsbaum.github.io/niflowr/reference/ni_ants_registration.md)
  run with `write_composite_transform = TRUE`. Supplies the images,
  transform, engine, and profile not given explicitly.

- fixed_image, moving_image:

  The template and the registered image. For multi-channel registrations
  the first channel is used.

- transform:

  The transform that resamples the moving image into template space: a
  composite `.h5`, or several files in `antsApplyTransforms` order (e.g.
  `c("x_1Warp.nii.gz", "x_0GenericAffine.mat")`).

- fixed_mask, moving_mask:

  Brain masks. `fixed_mask` limits the similarity metrics and the
  Jacobian summary; with both, the warped moving mask's Dice with
  `fixed_mask` is reported.

- fixed_labels, moving_labels:

  Label images; with both, per-label Dice after warping `moving_labels`
  with `GenericLabel` interpolation.

- similarity:

  Named numeric vector of metrics to compute, each with its bins (MI,
  Mattes) or radius (CC, others).

- interpolation:

  Interpolation for the warped moving image.

- jacobian:

  Whether to compute the Jacobian determinant summary.

- keep_field:

  Whether to keep the composed displacement field (large at 1 mm) after
  computing the Jacobian.

- out_dir:

  Directory in which each call creates its QA directory. Defaults to the
  transform's directory; set it to keep QA files out of a derivatives
  tree. Must be reachable by the engine (a mapped root for containers).

- .engine, .profile:

  Execution engine and runtime profile; default to the registration's.

- timeout:

  Seconds before each ANTs step is stopped.

- echo:

  Whether to echo tool output.

## Value

An `ni_registration_qa` object: a list with `similarity` (data frame),
`mask_dice` (`NA` without both masks), `label_dice` (data frame, or
`NULL` without both label images), `jacobian` (summary list, or `NULL`
when `jacobian = FALSE`), and `files`.

## Details

The moving image is always re-warped here with `interpolation`, so
scores are comparable between registrations (for example niflowr's and
fMRIPrep's transforms) only with the same images, mask, interpolation,
and metric parameters. Similarity values are ANTs metric costs, so
**lower is better**; they are computed densely (no sampling), so they
are deterministic. Dice is overlap, so higher is better. A non-positive
Jacobian determinant marks folding.

Each call writes its images to a new directory inside `out_dir`, so QA
can be re-run. Relative paths are resolved against the R working
directory.

## See also

[`ni_ants_register_to_template()`](https://bbuchsbaum.github.io/niflowr/reference/ni_ants_register_to_template.md)
