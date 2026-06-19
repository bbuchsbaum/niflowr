# FREESURFER Surface2VolTransform

Use FreeSurfer mri_surf2vol to apply a transform.

## Usage

``` r
ni_freesurfer_surface2_vol_transform(
  hemi,
  reg_file,
  source_file,
  args = NULL,
  mkmask = NULL,
  projfrac = NULL,
  subject_id = NULL,
  subjects_dir = NULL,
  surf_name = NULL,
  template_file = NULL,
  transformed_file = NULL,
  vertexvol_file = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- hemi:

  Character. hemisphere of data **Required.**

- reg_file:

  Character; file path. tkRAS-to-tkRAS matrix (tkregister2 format)
  **Required.**

- source_file:

  Character; file path. This is the source of the surface values
  **Required.**

- args:

  Character. Additional parameters to the command

- mkmask:

  Logical. make a mask instead of loading surface values

- projfrac:

  Numeric. thickness fraction

- subject_id:

  Character. subject id

- subjects_dir:

  Character. freesurfer subjects directory defaults to \$SUBJECTS_DIR

- surf_name:

  Character. surfname (default is white)

- template_file:

  Character; file path. Output template volume

- transformed_file:

  Character; file path. Output volume

- vertexvol_file:

  Character; file path. Path name of the vertex output volume, which is
  the same as output volume except that the value of each voxel is the
  vertex-id that is mapped to that voxel.

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
