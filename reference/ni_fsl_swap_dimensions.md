# FSL SwapDimensions

Use fslswapdim to alter the orientation of an image.

## Usage

``` r
ni_fsl_swap_dimensions(
  in_file,
  new_dims,
  args = NULL,
  out_file = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- in_file:

  Character; file path. input image **Required.**

- new_dims:

  Character or numeric vector. 3-tuple of new dimension order
  **Required.**

- args:

  Character. Additional parameters to the command

- out_file:

  Character; file path. image to write

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
