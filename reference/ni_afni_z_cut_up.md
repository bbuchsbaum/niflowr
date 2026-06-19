# AFNI ZCutUp

Cut z-slices from a volume using AFNI 3dZcutup command

## Usage

``` r
ni_afni_z_cut_up(
  in_file,
  args = NULL,
  keep = NULL,
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

  Character; file path. input file to 3dZcutup **Required.**

- args:

  Character. Additional parameters to the command

- keep:

  Character. slice range to keep in output

- out_file:

  Character; file path. output image file name

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
