# FSL FilterRegressor

Data de-noising by regressing out part of a design matrix

## Usage

``` r
ni_fsl_filter_regressor(
  design_file,
  filter_all,
  filter_columns,
  in_file,
  args = NULL,
  mask = NULL,
  out_file = NULL,
  out_vnscales = NULL,
  var_norm = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- design_file:

  Character; file path. name of the matrix with time courses (e.g. GLM
  design or MELODIC mixing matrix) **Required.**

- filter_all:

  Logical. use all columns in the design file in denoising **Required.**

- filter_columns:

  Character or numeric vector. (1-based) column indices to filter out of
  the data **Required.**

- in_file:

  Character; file path. input file name (4D image) **Required.**

- args:

  Character. Additional parameters to the command

- mask:

  Character; file path. mask image file name

- out_file:

  Character; file path. output file name for the filtered data

- out_vnscales:

  Logical. output scaling factors for variance normalization

- var_norm:

  Logical. perform variance-normalization on data

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
