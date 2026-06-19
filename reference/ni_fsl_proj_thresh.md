# FSL ProjThresh

Use FSL proj_thresh for thresholding some outputs of probtrack

## Usage

``` r
ni_fsl_proj_thresh(
  in_files,
  threshold,
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

- in_files:

  Character or numeric vector. a list of input volumes **Required.**

- threshold:

  Integer. threshold indicating minimum number of seed voxels entering
  this mask region **Required.**

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
