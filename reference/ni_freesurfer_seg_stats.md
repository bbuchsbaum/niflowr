# FREESURFER SegStats

Use FreeSurfer mri_segstats for ROI analysis

## Usage

``` r
ni_freesurfer_seg_stats(
  annot,
  segmentation_file,
  surf_label,
  args = NULL,
  avgwf_file = NULL,
  avgwf_txt_file = NULL,
  brain_vol = NULL,
  brainmask_file = NULL,
  calc_power = NULL,
  calc_snr = NULL,
  color_table_file = NULL,
  cortex_vol_from_surf = NULL,
  default_color_table = NULL,
  empty = NULL,
  etiv = NULL,
  euler = NULL,
  exclude_ctx_gm_wm = NULL,
  exclude_id = NULL,
  frame = NULL,
  gca_color_table = NULL,
  in_file = NULL,
  in_intensity = NULL,
  intensity_units = NULL,
  mask_erode = NULL,
  mask_file = NULL,
  mask_invert = NULL,
  mask_thresh = NULL,
  multiply = NULL,
  non_empty_only = NULL,
  partial_volume_file = NULL,
  segment_id = NULL,
  sf_avg_file = NULL,
  subcort_gm = NULL,
  summary_file = NULL,
  supratent = NULL,
  total_gray = NULL,
  vox = NULL,
  wm_vol_from_surf = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- annot:

  Character or numeric vector. subject hemi parc : use surface
  parcellation **Required.**

- segmentation_file:

  Character; file path. segmentation volume path **Required.**

- surf_label:

  Character or numeric vector. subject hemi label : use surface label
  **Required.**

- args:

  Character. Additional parameters to the command

- avgwf_file:

  Character or numeric vector. Save as binary volume (bool or filename)

- avgwf_txt_file:

  Character or numeric vector. Save average waveform into file (bool or
  filename)

- brain_vol:

  Character; one of: "brain-vol-from-seg", "brainmask". Compute brain
  volume either with `brainmask` or `brain-vol-from-seg`

- brainmask_file:

  Character; file path. Load brain mask and compute the volume of the
  brain as the non-zero voxels in this volume

- calc_power:

  Character; one of: "sqr", "sqrt". Compute either the sqr or the sqrt
  of the input

- calc_snr:

  Logical. save mean/std as extra column in output table

- color_table_file:

  Character; file path. color table file with seg id names

- cortex_vol_from_surf:

  Logical. Compute cortex volume from surf

- default_color_table:

  Logical. use \$FREESURFER_HOME/FreeSurferColorLUT.txt

- empty:

  Logical. Report on segmentations listed in the color table

- etiv:

  Logical. Compute ICV from talairach transform

- euler:

  Logical. Write out number of defect holes in orig.nofix based on the
  euler number

- exclude_ctx_gm_wm:

  Logical. exclude cortical gray and white matter

- exclude_id:

  Integer. Exclude seg id from report

- frame:

  Integer. Report stats on nth frame of input volume

- gca_color_table:

  Character; file path. get color table from GCA (CMA)

- in_file:

  Character; file path. Use the segmentation to report stats on this
  volume

- in_intensity:

  Character; file path. Undocumented input norm.mgz file

- intensity_units:

  Character; one of: "MR". Intensity units

- mask_erode:

  Integer. Erode mask by some amount

- mask_file:

  Character; file path. Mask volume (same size as seg

- mask_invert:

  Logical. Invert binarized mask volume

- mask_thresh:

  Numeric. binarize mask with this threshold \<0.5\>

- multiply:

  Numeric. multiply input by val

- non_empty_only:

  Logical. Only report nonempty segmentations

- partial_volume_file:

  Character; file path. Compensate for partial voluming

- segment_id:

  Character or numeric vector. Manually specify segmentation ids

- sf_avg_file:

  Character or numeric vector. Save mean across space and time

- subcort_gm:

  Logical. Compute volume of subcortical gray matter

- summary_file:

  Character; file path. Segmentation stats summary table file

- supratent:

  Logical. Undocumented input flag

- total_gray:

  Logical. Compute volume of total gray matter

- vox:

  Character or numeric vector. Replace seg with all 0s except at C R S
  (three int inputs)

- wm_vol_from_surf:

  Logical. Compute wm volume from surf

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
