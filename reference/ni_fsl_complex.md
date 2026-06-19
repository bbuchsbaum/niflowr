# FSL Complex

fslcomplex is a tool for converting complex data

## Usage

``` r
ni_fsl_complex(
  args = NULL,
  complex_cartesian = NULL,
  complex_in_file = NULL,
  complex_in_file2 = NULL,
  complex_merge = NULL,
  complex_out_file = NULL,
  complex_polar = NULL,
  complex_split = NULL,
  end_vol = NULL,
  imaginary_in_file = NULL,
  imaginary_out_file = NULL,
  magnitude_in_file = NULL,
  magnitude_out_file = NULL,
  phase_in_file = NULL,
  phase_out_file = NULL,
  real_cartesian = NULL,
  real_in_file = NULL,
  real_out_file = NULL,
  real_polar = NULL,
  start_vol = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- args:

  Character. Additional parameters to the command

- complex_cartesian:

  Logical

- complex_in_file:

  Character; file path

- complex_in_file2:

  Character; file path

- complex_merge:

  Logical

- complex_out_file:

  Character; file path

- complex_polar:

  Logical

- complex_split:

  Logical

- end_vol:

  Integer

- imaginary_in_file:

  Character; file path

- imaginary_out_file:

  Character; file path

- magnitude_in_file:

  Character; file path

- magnitude_out_file:

  Character; file path

- phase_in_file:

  Character; file path

- phase_out_file:

  Character; file path

- real_cartesian:

  Logical

- real_in_file:

  Character; file path

- real_out_file:

  Character; file path

- real_polar:

  Logical

- start_vol:

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
