# AFNI ClipLevel

Estimates the value at which to clip the anatomical dataset so

## Usage

``` r
ni_afni_clip_level(
  in_file,
  args = NULL,
  doall = NULL,
  grad = NULL,
  mfrac = NULL,
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

  Character; file path. input file to 3dClipLevel **Required.**

- args:

  Character. Additional parameters to the command

- doall:

  Logical. Apply the algorithm to each sub-brick separately.

- grad:

  Character; file path. Also compute a 'gradual' clip level as a
  function of voxel position, and output that to a dataset.

- mfrac:

  Numeric. Use the number ff instead of 0.50 in the algorithm

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
