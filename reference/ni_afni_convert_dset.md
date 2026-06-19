# AFNI ConvertDset

Converts a surface dataset from one format to another.

## Usage

``` r
ni_afni_convert_dset(
  in_file,
  out_file,
  out_type,
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

- in_file:

  Character; file path. input file to ConvertDset **Required.**

- out_file:

  Character; file path. output file for ConvertDset **Required.**

- out_type:

  Character; one of: "niml", "niml_asc", "niml_bi", "1D", "1Dp", "1Dpt",
  "gii", "gii_asc", "gii_b64", "gii_b64gz". output type **Required.**

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
