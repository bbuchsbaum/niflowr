# ANTS buildtemplateparallel

Generate a optimal average template

## Usage

``` r
ni_ants_buildtemplateparallel(
  in_files,
  args = NULL,
  bias_field_correction = NULL,
  dimension = 3,
  gradient_step_size = NULL,
  iteration_limit = 4,
  max_iterations = NULL,
  num_cores = NULL,
  out_prefix = "antsTMPL_",
  parallelization = 0,
  rigid_body_registration = NULL,
  similarity_metric = NULL,
  transformation_model = "GR",
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- in_files:

  Character or numeric vector. list of images to generate template from
  **Required.**

- args:

  Character. Additional parameters to the command

- bias_field_correction:

  Logical. Applies bias field correction to moving image

- dimension:

  Character; one of: "3", "2", "4". image dimension (2, 3 or 4)

- gradient_step_size:

  Numeric. smaller magnitude results in more cautious steps (default =
  .25)

- iteration_limit:

  Integer. iterations of template construction

- max_iterations:

  Character or numeric vector. maximum number of iterations (must be
  list of integers in the form \[J,K,L...\]: J = coarsest resolution
  iterations, K = middle resolution iterations, L = fine resolution
  iterations

- num_cores:

  Integer. Requires parallelization = 2 (PEXEC). Sets number of cpu
  cores to use

- out_prefix:

  Character. Prefix that is prepended to all output files (default =
  antsTMPL\_)

- parallelization:

  Character; one of: "0", "1", "2". control for parallel processing (0 =
  serial, 1 = use PBS, 2 = use PEXEC, 3 = use Apple XGrid

- rigid_body_registration:

  Logical. registers inputs before creating template (useful if no
  initial template available)

- similarity_metric:

  Character; one of: "PR", "CC", "MI", "MSQ". Type of similartiy metric
  used for registration (CC = cross correlation, MI = mutual
  information, PR = probability mapping, MSQ = mean square difference)

- transformation_model:

  Character; one of: "GR", "EL", "SY", "S2", "EX", "DD". Type of
  transofmration model used for registration (EL = elastic
  transformation model, SY = SyN with time, arbitrary number of time
  points, S2 = SyN with time optimized for 2 time points, GR = greedy
  SyN, EX = exponential, DD = diffeomorphic demons style exponential
  mapping

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
