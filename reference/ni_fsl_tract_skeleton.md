# FSL TractSkeleton

Use FSL's tbss_skeleton to skeletonise an FA image or project arbitrary

## Usage

``` r
ni_fsl_tract_skeleton(
  in_file,
  alt_data_file = NULL,
  alt_skeleton = NULL,
  args = NULL,
  project_data = NULL,
  skeleton_file = NULL,
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

  Character; file path. input image (typically mean FA volume)
  **Required.**

- alt_data_file:

  Character; file path. 4D non-FA data to project onto skeleton

- alt_skeleton:

  Character; file path. alternate skeleton to use

- args:

  Character. Additional parameters to the command

- project_data:

  Logical. project data onto skeleton

- skeleton_file:

  Character or numeric vector. write out skeleton image

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
