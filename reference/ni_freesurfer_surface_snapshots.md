# FREESURFER SurfaceSnapshots

Use Tksurfer to save pictures of the cortical surface.

## Usage

``` r
ni_freesurfer_surface_snapshots(
  hemi,
  subject_id,
  surface,
  annot_file = NULL,
  annot_name = NULL,
  args = NULL,
  colortable = NULL,
  demean_overlay = NULL,
  identity_reg = NULL,
  invert_overlay = NULL,
  label_file = NULL,
  label_name = NULL,
  label_outline = NULL,
  label_under = NULL,
  mni152_reg = NULL,
  orig_suffix = NULL,
  overlay = NULL,
  overlay_range = NULL,
  overlay_range_offset = NULL,
  overlay_reg = NULL,
  patch_file = NULL,
  reverse_overlay = NULL,
  show_color_scale = NULL,
  show_color_text = NULL,
  show_curv = NULL,
  show_gray_curv = NULL,
  sphere_suffix = NULL,
  tcl_script = NULL,
  truncate_overlay = NULL,
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

  Character; one of: "lh", "rh". hemisphere to visualize **Required.**

- subject_id:

  Character. subject to visualize **Required.**

- surface:

  Character. surface to visualize **Required.**

- annot_file:

  Character; file path. path to annotation file to display

- annot_name:

  Character. name of annotation to display (must be in \$subject/label
  directory

- args:

  Character. Additional parameters to the command

- colortable:

  Character; file path. load colortable file

- demean_overlay:

  Logical. remove mean from overlay

- identity_reg:

  Logical. use the identity matrix to register the overlay to the
  surface

- invert_overlay:

  Logical. invert the overlay display

- label_file:

  Character; file path. path to label file to display

- label_name:

  Character. name of label to display (must be in \$subject/label
  directory

- label_outline:

  Logical. draw label/annotation as outline

- label_under:

  Logical. draw label/annotation under overlay

- mni152_reg:

  Logical. use to display a volume in MNI152 space on the average
  subject

- orig_suffix:

  Character. set the orig surface suffix string

- overlay:

  Character; file path. load an overlay volume/surface

- overlay_range:

  Character or numeric vector. overlay range–either min, (min, max) or
  (min, mid, max)

- overlay_range_offset:

  Numeric. overlay range will be symmetric around offset value

- overlay_reg:

  Character; file path. registration matrix file to register overlay to
  surface

- patch_file:

  Character; file path. load a patch

- reverse_overlay:

  Logical. reverse the overlay display

- show_color_scale:

  Logical. display the color scale bar

- show_color_text:

  Logical. display text in the color scale bar

- show_curv:

  Logical. show curvature

- show_gray_curv:

  Logical. show curvature in gray

- sphere_suffix:

  Character. set the sphere.reg suffix string

- tcl_script:

  Character; file path. override default screenshot script

- truncate_overlay:

  Logical. truncate the overlay display

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
