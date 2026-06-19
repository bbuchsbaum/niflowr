# FSL ChangeDataType

Use fslmaths to change the datatype of an image.

## Usage

``` r
ni_fsl_change_data_type(
  in_file,
  output_datatype,
  args = NULL,
  internal_datatype = NULL,
  nan2zeros = NULL,
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

  Character; file path. image to operate on **Required.**

- output_datatype:

  Character; one of: "float", "char", "int", "short", "double", "input".
  output data type **Required.**

- args:

  Character. Additional parameters to the command

- internal_datatype:

  Character; one of: "float", "char", "int", "short", "double", "input".
  datatype to use for calculations (default is float)

- nan2zeros:

  Logical. change NaNs to zeros before doing anything

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
