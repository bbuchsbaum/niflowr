# FREESURFER MRIMarchingCubes

Uses Freesurfer's mri_mc to create surfaces by tessellating a given
input volume

## Usage

``` r
ni_freesurfer_mri_marching_cubes(
  in_file,
  label_value,
  args = NULL,
  connectivity_value = 1,
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

  Character; file path. Input volume to tessellate voxels from.
  **Required.**

- label_value:

  Integer. Label value which to tessellate from the input volume.
  (integer, if input is "filled.mgz" volume, 127 is rh, 255 is lh)
  **Required.**

- args:

  Character. Additional parameters to the command

- connectivity_value:

  Integer. Alter the marching cubes connectivity: 1=6+,2=18,3=6,4=26
  (default=1)

- out_file:

  Character; file path. output filename or True to generate one

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
