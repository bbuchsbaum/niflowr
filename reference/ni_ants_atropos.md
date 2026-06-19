# ANTS Atropos

A multivariate n-class segmentation algorithm.

## Usage

``` r
ni_ants_atropos(
  initialization,
  intensity_images,
  mask_image,
  number_of_tissue_classes,
  args = NULL,
  dimension = 3,
  icm_use_synchronous_update = NULL,
  likelihood_model = NULL,
  mrf_smoothing_factor = NULL,
  n_iterations = NULL,
  out_classified_image_name = NULL,
  posterior_formulation = NULL,
  use_random_seed = TRUE,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- initialization:

  Character; one of: "Random", "Otsu", "KMeans",
  "PriorProbabilityImages", "PriorLabelImage" **Required.**

- intensity_images:

  Character or numeric vector **Required.**

- mask_image:

  Character; file path **Required.**

- number_of_tissue_classes:

  Integer **Required.**

- args:

  Character. Additional parameters to the command

- dimension:

  Character; one of: "3", "2", "4". image dimension (2, 3, or 4)

- icm_use_synchronous_update:

  Logical

- likelihood_model:

  Character

- mrf_smoothing_factor:

  Numeric

- n_iterations:

  Integer

- out_classified_image_name:

  Character; file path

- posterior_formulation:

  Character

- use_random_seed:

  Logical. use random seed value over constant

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
