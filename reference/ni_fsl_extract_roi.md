# FSL ExtractROI

Uses FSL Fslroi command to extract region of interest (ROI)

## Usage

``` r
ni_fsl_extract_roi(
  in_file,
  args = NULL,
  crop_list = NULL,
  roi_file = NULL,
  t_min = NULL,
  t_size = NULL,
  x_min = NULL,
  x_size = NULL,
  y_min = NULL,
  y_size = NULL,
  z_min = NULL,
  z_size = NULL,
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

  Character; file path. input file **Required.**

- args:

  Character. Additional parameters to the command

- crop_list:

  Character or numeric vector. list of two tuples specifying crop
  options

- roi_file:

  Character; file path. output file

- t_min:

  Integer

- t_size:

  Integer

- x_min:

  Integer

- x_size:

  Integer

- y_min:

  Integer

- y_size:

  Integer

- z_min:

  Integer

- z_size:

  Integer

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
