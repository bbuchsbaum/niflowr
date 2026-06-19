# ANTS RegistrationSynQuick

Registration using a symmetric image normalization method (SyN).

## Usage

``` r
ni_ants_registration_syn_quick(
  fixed_image,
  moving_image,
  output_prefix,
  args = NULL,
  dimension = 3,
  histogram_bins = 32,
  num_threads = 1,
  precision_type = "double",
  random_seed = NULL,
  spline_distance = 26,
  transform_type = "s",
  use_histogram_matching = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- fixed_image:

  Character or numeric vector. Fixed image or source image or reference
  image **Required.**

- moving_image:

  Character or numeric vector. Moving image or target image
  **Required.**

- output_prefix:

  Character. A prefix that is prepended to all output files
  **Required.**

- args:

  Character. Additional parameters to the command

- dimension:

  Character; one of: "3", "2". image dimension (2 or 3)

- histogram_bins:

  Integer. histogram bins for mutual information in SyN stage (default =
  32)

- num_threads:

  Integer. Number of threads (default = 1)

- precision_type:

  Character; one of: "double", "float". precision type (default =
  double)

- random_seed:

  Integer. fixed random seed

- spline_distance:

  Integer. spline distance for deformable B-spline SyN transform
  (default = 26)

- transform_type:

  Character; one of: "s", "t", "r", "a", "sr", "b", "br". Transform type
  \* t: translation \* r: rigid \* a: rigid + affine \* s: rigid +
  affine + deformable syn (default) \* sr: rigid + deformable syn \* b:
  rigid + affine + deformable b-spline syn \* br: rigid + deformable
  b-spline syn

- use_histogram_matching:

  Logical. use histogram matching

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
