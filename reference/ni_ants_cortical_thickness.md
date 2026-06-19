# ANTS CorticalThickness

Examples

## Usage

``` r
ni_ants_cortical_thickness(
  anatomical_image,
  brain_probability_mask,
  brain_template,
  segmentation_priors,
  t1_registration_template,
  args = NULL,
  b_spline_smoothing = NULL,
  debug = NULL,
  dimension = 3,
  extraction_registration_mask = NULL,
  image_suffix = "nii.gz",
  keep_temporary_files = NULL,
  label_propagation = NULL,
  max_iterations = NULL,
  out_prefix = "antsCT_",
  posterior_formulation = NULL,
  prior_segmentation_weight = NULL,
  quick_registration = NULL,
  segmentation_iterations = NULL,
  use_floatingpoint_precision = NULL,
  use_random_seeding = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- anatomical_image:

  Character; file path. Structural *intensity* image, typically T1. If
  more than one anatomical image is specified, subsequently specified
  images are used during the segmentation process. However, only the
  first image is used in the registration of priors. Our suggestion
  would be to specify the T1 as the first image. **Required.**

- brain_probability_mask:

  Character; file path. brain probability mask in template space
  **Required.**

- brain_template:

  Character; file path. Anatomical *intensity* template (possibly
  created using a population data set with buildtemplateparallel.sh in
  ANTs). This template is *not* skull-stripped. **Required.**

- segmentation_priors:

  Character or numeric vector **Required.**

- t1_registration_template:

  Character; file path. Anatomical *intensity* template (assumed to be
  skull-stripped). A common case would be where this would be the same
  template as specified in the -e option which is not skull stripped.
  **Required.**

- args:

  Character. Additional parameters to the command

- b_spline_smoothing:

  Logical. Use B-spline SyN for registrations and B-spline exponential
  mapping in DiReCT.

- debug:

  Logical. If \> 0, runs a faster version of the script. Only for
  testing. Implies -u 0. Requires single thread computation for complete
  reproducibility.

- dimension:

  Character; one of: "3", "2". image dimension (2 or 3)

- extraction_registration_mask:

  Character; file path. Mask (defined in the template space) used during
  registration for brain extraction.

- image_suffix:

  Character. any of standard ITK formats, nii.gz is default

- keep_temporary_files:

  Integer. Keep brain extraction/segmentation warps, etc (default = 0).

- label_propagation:

  Character. Incorporate a distance prior one the posterior formulation.
  Should be of the form 'label\[lambda,boundaryProbability\]' where
  label is a value of 1,2,3,... denoting label ID. The label probability
  for anything outside the current label = boundaryProbability \* exp(
  -lambda \* distanceFromBoundary ) Intuitively, smaller lambda values
  will increase the spatial capture range of the distance prior. To
  apply to all label values, simply omit specifying the label, i.e. -l
  \[lambda,boundaryProbability\].

- max_iterations:

  Integer. ANTS registration max iterations (default = 100x100x70x20)

- out_prefix:

  Character. Prefix that is prepended to all output files

- posterior_formulation:

  Character. Atropos posterior formulation and whether or not to use
  mixture model proportions. e.g 'Socrates\[1\]' (default) or
  'Aristotle\[1\]'. Choose the latter if you want use the distance
  priors (see also the -l option for label propagation control).

- prior_segmentation_weight:

  Numeric. Atropos spatial prior *probability* weight for the
  segmentation

- quick_registration:

  Logical. If = 1, use antsRegistrationSyNQuick.sh as the basis for
  registration during brain extraction, brain segmentation, and
  (optional) normalization to a template. Otherwise use
  antsRegistrationSyN.sh (default = 0).

- segmentation_iterations:

  Integer. N4 -\> Atropos -\> N4 iterations during segmentation (default
  = 3)

- use_floatingpoint_precision:

  Character; one of: "0", "1". Use floating point precision in
  registrations (default = 0)

- use_random_seeding:

  Character; one of: "0", "1". Use random number generated from system
  clock in Atropos (default = 1)

- .cwd:

  Working directory override.

- .env:

  Named character vector of environment variables.

- .engine:

  Execution engine override.

- .profile:

  Runtime profile override.

- dry_run:

  Logical; preview command without executing.

- echo:

  Logical; echo stdout/stderr in real time.

## Value

An `ni_result` object.
