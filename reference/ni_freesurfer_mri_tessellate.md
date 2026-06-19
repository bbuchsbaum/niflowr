# FREESURFER MRITessellate

Uses Freesurfer's mri_tessellate to create surfaces by tessellating a
given input volume

## Usage

``` r
ni_freesurfer_mri_tessellate(
  in_file,
  label_value,
  args = NULL,
  out_file = NULL,
  tesselate_all_voxels = NULL,
  use_real_RAS_coordinates = NULL,
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

- out_file:

  Character; file path. output filename or True to generate one

- tesselate_all_voxels:

  Logical. Tessellate the surface of all voxels with different labels

- use_real_RAS_coordinates:

  Logical. Saves surface with real RAS coordinates where c\_(r,a,s) != 0

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
