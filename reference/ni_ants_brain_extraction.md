# ANTS BrainExtraction

Atlas-based brain extraction.

## Usage

``` r
ni_ants_brain_extraction(
  anatomical_image,
  brain_probability_mask,
  brain_template,
  args = NULL,
  debug = NULL,
  dimension = 3,
  extraction_registration_mask = NULL,
  image_suffix = "nii.gz",
  keep_temporary_files = NULL,
  out_prefix = "highres001_",
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

  Character; file path. Structural image, typically T1. If more than one
  anatomical image is specified, subsequently specified images are used
  during the segmentation process. However, only the first image is used
  in the registration of priors. Our suggestion would be to specify the
  T1 as the first image. Anatomical template created using e.g. LPBA40
  data set with buildtemplateparallel.sh in ANTs. **Required.**

- brain_probability_mask:

  Character; file path. Brain probability mask created using e.g. LPBA40
  data set which have brain masks defined, and warped to anatomical
  template and averaged resulting in a probability image. **Required.**

- brain_template:

  Character; file path. Anatomical template created using e.g. LPBA40
  data set with buildtemplateparallel.sh in ANTs. **Required.**

- args:

  Character. Additional parameters to the command

- debug:

  Logical. If \> 0, runs a faster version of the script. Only for
  testing. Implies -u 0. Requires single thread computation for complete
  reproducibility.

- dimension:

  Character; one of: "3", "2". image dimension (2 or 3)

- extraction_registration_mask:

  Character; file path. Mask (defined in the template space) used during
  registration for brain extraction. To limit the metric computation to
  a specific region.

- image_suffix:

  Character. any of standard ITK formats, nii.gz is default

- keep_temporary_files:

  Integer. Keep brain extraction/segmentation warps, etc (default = 0).

- out_prefix:

  Character. Prefix that is prepended to all output files

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
