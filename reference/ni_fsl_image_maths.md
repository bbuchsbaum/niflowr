# FSL ImageMaths

Use FSL fslmaths command to allow mathematical manipulation of images

## Usage

``` r
ni_fsl_image_maths(
  in_file,
  args = NULL,
  in_file2 = NULL,
  mask_file = NULL,
  op_string = NULL,
  out_data_type = NULL,
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

  Character; file path **Required.**

- args:

  Character. Additional parameters to the command

- in_file2:

  Character; file path

- mask_file:

  Character; file path. use (following image\>0) to mask current image

- op_string:

  Character. string defining the operation, i. e. -add

- out_data_type:

  Character; one of: "char", "short", "int", "float", "double", "input".
  output datatype, one of (char, short, int, float, double, input)

- out_file:

  Character; file path

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
