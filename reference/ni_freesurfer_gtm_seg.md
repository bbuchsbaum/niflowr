# FREESURFER GTMSeg

create an anatomical segmentation for the geometric transfer matrix
(GTM).

## Usage

``` r
ni_freesurfer_gtm_seg(
  subject_id,
  args = NULL,
  colortable = NULL,
  ctx_annot = NULL,
  dmax = NULL,
  head = NULL,
  keep_cc = NULL,
  keep_hypo = NULL,
  no_pons = NULL,
  no_seg_stats = NULL,
  no_vermis = NULL,
  out_file = "gtmseg.mgz",
  output_upsampling_factor = NULL,
  subseg_cblum_wm = NULL,
  subsegwm = NULL,
  upsampling_factor = NULL,
  wm_annot = NULL,
  xcerseg = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- subject_id:

  Character. subject id **Required.**

- args:

  Character. Additional parameters to the command

- colortable:

  Character; file path. colortable

- ctx_annot:

  Character or numeric vector. annot lhbase rhbase : annotation to use
  for cortical segmentation (default is aparc 1000 2000)

- dmax:

  Numeric. distance threshold to use when subsegmenting WM (default is
  5)

- head:

  Character. use headseg instead of apas+head.mgz

- keep_cc:

  Logical. do not relabel corpus callosum as WM

- keep_hypo:

  Logical. do not relabel hypointensities as WM when subsegmenting WM

- no_pons:

  Logical. do not add pons segmentation when doing —xcerseg

- no_seg_stats:

  Logical. do not compute segmentation stats

- no_vermis:

  Logical. do not add vermis segmentation when doing —xcerseg

- out_file:

  Character; file path. output volume relative to subject/mri

- output_upsampling_factor:

  Integer. set output USF different than USF, mostly for debugging

- subseg_cblum_wm:

  Logical. subsegment cerebellum WM into core and gyri

- subsegwm:

  Logical. subsegment WM into lobes (default)

- upsampling_factor:

  Integer. upsampling factor (default is 2)

- wm_annot:

  Character or numeric vector. annot lhbase rhbase : annotation to use
  for WM segmentation (with –subsegwm, default is lobes 3200 4200)

- xcerseg:

  Logical. run xcerebralseg on this subject to create apas+head.mgz

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
