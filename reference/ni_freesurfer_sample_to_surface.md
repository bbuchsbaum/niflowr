# FREESURFER SampleToSurface

Sample a volume to the cortical surface using Freesurfer's mri_vol2surf.

## Usage

``` r
ni_freesurfer_sample_to_surface(
  hemi,
  mni152reg,
  projection_stem,
  reg_file,
  reg_header,
  sampling_method,
  source_file,
  apply_rot = NULL,
  apply_trans = NULL,
  args = NULL,
  cortex_mask = NULL,
  fix_tk_reg = NULL,
  float2int_method = NULL,
  frame = NULL,
  hits_file = NULL,
  hits_type = NULL,
  ico_order = NULL,
  interp_method = NULL,
  mask_label = NULL,
  no_reshape = NULL,
  out_file = NULL,
  out_type = NULL,
  override_reg_subj = NULL,
  reference_file = NULL,
  reshape = NULL,
  reshape_slices = NULL,
  scale_input = NULL,
  smooth_surf = NULL,
  smooth_vol = NULL,
  surf_reg = NULL,
  surface = NULL,
  target_subject = NULL,
  vox_file = NULL,
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

  Character; one of: "lh", "rh". target hemisphere **Required.**

- mni152reg:

  Logical. source volume is in MNI152 space **Required.**

- projection_stem:

  Character. stem for precomputed linear estimates and volume fractions
  **Required.**

- reg_file:

  Character; file path. source-to-reference registration file
  **Required.**

- reg_header:

  Logical. register based on header geometry **Required.**

- sampling_method:

  Character; one of: "point", "max", "average". how to sample – at a
  point or at the max or average over a range **Required.**

- source_file:

  Character; file path. volume to sample values from **Required.**

- apply_rot:

  Character or numeric vector. rotation angles (in degrees) to apply to
  reg matrix

- apply_trans:

  Character or numeric vector. translation (in mm) to apply to reg
  matrix

- args:

  Character. Additional parameters to the command

- cortex_mask:

  Logical. mask the target surface with hemi.cortex.label

- fix_tk_reg:

  Logical. make reg matrix round-compatible

- float2int_method:

  Character; one of: "round", "tkregister". method to convert reg matrix
  values (default is round)

- frame:

  Integer. save only one frame (0-based)

- hits_file:

  Character or numeric vector. save image with number of hits at each
  voxel

- hits_type:

  Character; one of: "cor", "mgh", "mgz", "minc", "analyze",
  "analyze4d", "spm", "afni", "brik", "bshort", "bfloat", "sdt",
  "outline", "otl", "gdf", "nifti1", "nii", "niigz". hits file type

- ico_order:

  Integer. icosahedron order when target_subject is 'ico'

- interp_method:

  Character; one of: "nearest", "trilinear". interpolation method

- mask_label:

  Character; file path. label file to mask output with

- no_reshape:

  Logical. do not reshape surface vector (default)

- out_file:

  Character; file path. surface file to write

- out_type:

  Character; one of: "cor", "mgh", "mgz", "minc", "analyze",
  "analyze4d", "spm", "afni", "brik", "bshort", "bfloat", "sdt",
  "outline", "otl", "gdf", "nifti1", "nii", "niigz", "gii". output file
  type

- override_reg_subj:

  Logical. override the subject in the reg file header

- reference_file:

  Character; file path. reference volume (default is orig.mgz)

- reshape:

  Logical. reshape surface vector to fit in non-mgh format

- reshape_slices:

  Integer. number of 'slices' for reshaping

- scale_input:

  Numeric. multiple all intensities by scale factor

- smooth_surf:

  Numeric. smooth output surface (mm fwhm)

- smooth_vol:

  Numeric. smooth input volume (mm fwhm)

- surf_reg:

  Character or numeric vector. use surface registration to target
  subject

- surface:

  Character. target surface (default is white)

- target_subject:

  Character. sample to surface of different subject than source

- vox_file:

  Character or numeric vector. text file with the number of voxels
  intersecting the surface

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
