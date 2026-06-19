# FREESURFER MPRtoMNI305

For complete details, see FreeSurfer documentation

## Usage

``` r
ni_freesurfer_mp_rto_mni305(
  reference_dir,
  target,
  args = NULL,
  in_file = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- reference_dir:

  Character; directory path. Path to FreeSurfer's MNI305 reference
  directory (commonly \$FREESURFER_HOME/average). **Required.**

- target:

  Character. input atlas file **Required.**

- args:

  Character. Additional parameters to the command

- in_file:

  Character; file path. the input file prefix for MPRtoMNI305

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
