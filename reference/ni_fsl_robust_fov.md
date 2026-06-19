# FSL RobustFOV

Automatically crops an image removing lower head and neck.

## Usage

``` r
ni_fsl_robust_fov(
  in_file,
  args = NULL,
  brainsize = NULL,
  out_roi = NULL,
  out_transform = NULL,
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

  Character; file path. input filename **Required.**

- args:

  Character. Additional parameters to the command

- brainsize:

  Integer. size of brain in z-dimension (default 170mm/150mm)

- out_roi:

  Character; file path. ROI volume output name

- out_transform:

  Character; file path. Transformation matrix in_file to out_roi output
  name

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
