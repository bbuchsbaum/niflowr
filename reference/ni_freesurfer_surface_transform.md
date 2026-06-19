# FREESURFER SurfaceTransform

Transform a surface file from one subject to another via a spherical
registration.

## Usage

``` r
ni_freesurfer_surface_transform(
  hemi,
  source_annot_file,
  source_file,
  source_subject,
  target_subject,
  args = NULL,
  out_file = NULL,
  reshape = NULL,
  reshape_factor = NULL,
  source_type = NULL,
  target_ico_order = NULL,
  target_type = NULL,
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

  Character; one of: "lh", "rh". hemisphere to transform **Required.**

- source_annot_file:

  Character; file path. surface annotation file **Required.**

- source_file:

  Character; file path. surface file with source values **Required.**

- source_subject:

  Character. subject id for source surface **Required.**

- target_subject:

  Character. subject id of target surface **Required.**

- args:

  Character. Additional parameters to the command

- out_file:

  Character; file path. surface file to write

- reshape:

  Logical. reshape output surface to conform with Nifti

- reshape_factor:

  Integer. number of slices in reshaped image

- source_type:

  Character; one of: "cor", "mgh", "mgz", "minc", "analyze",
  "analyze4d", "spm", "afni", "brik", "bshort", "bfloat", "sdt",
  "outline", "otl", "gdf", "nifti1", "nii", "niigz". source file format

- target_ico_order:

  Character; one of: "1", "2", "3", "4", "5", "6", "7". order of the
  icosahedron if target_subject is 'ico'

- target_type:

  Character; one of: "cor", "mgh", "mgz", "minc", "analyze",
  "analyze4d", "spm", "afni", "brik", "bshort", "bfloat", "sdt",
  "outline", "otl", "gdf", "nifti1", "nii", "niigz", "gii". output
  format

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
