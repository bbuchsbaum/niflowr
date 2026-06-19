# ANTS MultiplyImages

Examples

## Usage

``` r
ni_ants_multiply_images(
  dimension,
  first_input,
  output_product_image,
  second_input,
  args = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- dimension:

  Character; one of: "3", "2". image dimension (2 or 3) **Required.**

- first_input:

  Character; file path. image 1 **Required.**

- output_product_image:

  Character; file path. Outputfname.nii.gz: the name of the resulting
  image. **Required.**

- second_input:

  Character or numeric vector. image 2 or multiplication weight
  **Required.**

- args:

  Character. Additional parameters to the command

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
