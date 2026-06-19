# FSL PercentileImage

Use fslmaths to generate a percentile image across a given dimension.

## Usage

``` r
ni_fsl_percentile_image(
  in_file,
  args = NULL,
  dimension = "T",
  internal_datatype = NULL,
  nan2zeros = NULL,
  out_file = NULL,
  output_datatype = NULL,
  perc = NULL,
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

- args:

  Character. Additional parameters to the command

- dimension:

  Character; one of: "T", "X", "Y", "Z". dimension to percentile across

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

- perc:

  Character. nth percentile (0-100) of FULL RANGE across dimension

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
