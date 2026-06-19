# FSL DilateImage

Use fslmaths to perform a spatial dilation of an image.

## Usage

``` r
ni_fsl_dilate_image(
  in_file,
  operation,
  args = NULL,
  internal_datatype = NULL,
  kernel_file = NULL,
  kernel_shape = NULL,
  kernel_size = NULL,
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

- operation:

  Character; one of: "mean", "modal", "max". filtering operation to
  perform in dilation **Required.**

- args:

  Character. Additional parameters to the command

- internal_datatype:

  Character; one of: "float", "char", "int", "short", "double", "input".
  datatype to use for calculations (default is float)

- kernel_file:

  Character; file path. use external file for kernel

- kernel_shape:

  Character; one of: "3D", "2D", "box", "boxv", "gauss", "sphere",
  "file". kernel shape to use

- kernel_size:

  Numeric. kernel size - voxels for box/boxv, mm for sphere, mm sigma
  for gauss

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
