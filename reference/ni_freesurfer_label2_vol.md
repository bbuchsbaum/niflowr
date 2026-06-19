# FREESURFER Label2Vol

Make a binary volume from a Freesurfer label

## Usage

``` r
ni_freesurfer_label2_vol(
  annot_file,
  aparc_aseg,
  label_file,
  seg_file,
  template_file,
  args = NULL,
  fill_thresh = NULL,
  hemi = NULL,
  identity = NULL,
  invert_mtx = NULL,
  label_hit_file = NULL,
  label_voxel_volume = NULL,
  map_label_stat = NULL,
  native_vox2ras = NULL,
  proj = NULL,
  reg_file = NULL,
  reg_header = NULL,
  subject_id = NULL,
  surface = NULL,
  vol_label_file = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- annot_file:

  Character; file path. surface annotation file **Required.**

- aparc_aseg:

  Logical. use aparc+aseg.mgz in subjectdir as seg **Required.**

- label_file:

  Character or numeric vector. list of label files **Required.**

- seg_file:

  Character; file path. segmentation file **Required.**

- template_file:

  Character; file path. output template volume **Required.**

- args:

  Character. Additional parameters to the command

- fill_thresh:

  Character. thresh : between 0 and 1

- hemi:

  Character; one of: "lh", "rh". hemisphere to use lh or rh

- identity:

  Logical. set R=I

- invert_mtx:

  Logical. Invert the registration matrix

- label_hit_file:

  Character; file path. file with each frame is nhits for a label

- label_voxel_volume:

  Numeric. volume of each label point (def 1mm3)

- map_label_stat:

  Character; file path. map the label stats field into the vol

- native_vox2ras:

  Logical. use native vox2ras xform instead of tkregister-style

- proj:

  Character or numeric vector. project along surface normal

- reg_file:

  Character; file path. tkregister style matrix VolXYZ = R\*LabelXYZ

- reg_header:

  Character; file path. label template volume

- subject_id:

  Character. subject id

- surface:

  Character. use surface instead of white

- vol_label_file:

  Character; file path. output volume

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
