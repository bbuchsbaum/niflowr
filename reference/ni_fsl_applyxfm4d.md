# FSL applyxfm4D

Apply either one FSL affine per 4D volume from a MAT_0000-style
directory, or one affine to every volume.

## Usage

``` r
ni_fsl_applyxfm4d(
  in_file,
  reference,
  out_file,
  mat_dir = NULL,
  single_matrix = NULL,
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

  Character; file path. 4D moving NIfTI image. **Required.**

- reference:

  Character; file path. 3D reference NIfTI image defining the output
  grid. **Required.**

- out_file:

  Character; file path. Requested output NIfTI path. applyxfm4D receives
  its extension-free stem and FSL appends the configured NIFTI or
  NIFTI_GZ suffix. **Required.**

- mat_dir:

  Character; directory path. Directory containing exactly MAT_0000
  through MAT_NNNN, one FSL affine matrix per input volume.

- single_matrix:

  Character; file path. One FSL affine matrix applied to every input
  volume using applyxfm4D -singlematrix.

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
