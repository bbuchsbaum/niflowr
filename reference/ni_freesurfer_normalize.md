# FREESURFER Normalize

Normalize the white-matter, optionally based on control points. The

## Usage

``` r
ni_freesurfer_normalize(
  in_file,
  args = NULL,
  gradient = NULL,
  mask = NULL,
  out_file = NULL,
  segmentation = NULL,
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

  Character; file path. The input file for Normalize **Required.**

- args:

  Character. Additional parameters to the command

- gradient:

  Integer. use max intensity/mm gradient g (default=1)

- mask:

  Character; file path. The input mask file for Normalize

- out_file:

  Character; file path. The output file for Normalize

- segmentation:

  Character; file path. The input segmentation for Normalize

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
