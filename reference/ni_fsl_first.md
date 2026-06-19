# FSL FIRST

FSL run_first_all wrapper for segmentation of subcortical volumes

## Usage

``` r
ni_fsl_first(
  in_file,
  out_file,
  affine_file = NULL,
  args = NULL,
  brain_extracted = NULL,
  list_of_specific_structures = NULL,
  method = "auto",
  method_as_numerical_threshold = NULL,
  no_cleanup = NULL,
  verbose = NULL,
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

  Character; file path. input data file **Required.**

- out_file:

  Character; file path. output data file **Required.**

- affine_file:

  Character; file path. Affine matrix to use (e.g. img2std.mat) (does
  not re-run registration)

- args:

  Character. Additional parameters to the command

- brain_extracted:

  Logical. Input structural image is already brain-extracted

- list_of_specific_structures:

  Character or numeric vector. Runs only on the specified structures
  (e.g. L_Hipp, R_HippL_Accu, R_Accu, L_Amyg, R_AmygL_Caud, R_Caud,
  L_Pall, R_PallL_Puta, R_Puta, L_Thal, R_Thal, BrStem

- method:

  Character; one of: "auto", "fast", "none". Method must be one of auto,
  fast, none, or it can be entered using the
  'method_as_numerical_threshold' input

- method_as_numerical_threshold:

  Numeric. Specify a numerical threshold value or use the 'method' input
  to choose auto, fast, or none

- no_cleanup:

  Logical. Input structural image is already brain-extracted

- verbose:

  Logical. Use verbose logging.

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
