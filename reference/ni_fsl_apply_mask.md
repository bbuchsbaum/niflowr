# FSL ApplyMask

Use fslmaths to apply a binary mask to another image.

## Usage

``` r
ni_fsl_apply_mask(
  in_file,
  mask_file,
  args = NULL,
  internal_datatype = NULL,
  nan2zeros = NULL,
  out_file = NULL,
  output_datatype = NULL,
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

  Character; file path. image to operate on **Required.**

- mask_file:

  Character; file path. binary image defining mask space **Required.**

- args:

  Character. Additional parameters to the command

- internal_datatype:

  Character; one of: "float", "char", "int", "short", "double", "input".
  datatype to use for calculations (default is float)

- nan2zeros:

  Logical. change NaNs to zeros before doing anything

- out_file:

  Character; file path. image to write

- output_datatype:

  Character; one of: "float", "char", "int", "short", "double", "input".
  datatype to use for output (default uses input type)

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
