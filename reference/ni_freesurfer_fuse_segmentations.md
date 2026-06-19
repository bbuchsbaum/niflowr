# FREESURFER FuseSegmentations

fuse segmentations together from multiple timepoints

## Usage

``` r
ni_freesurfer_fuse_segmentations(
  in_norms,
  in_segmentations,
  in_segmentations_noCC,
  out_file,
  timepoints,
  args = NULL,
  subject_id = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- in_norms:

  Character or numeric vector. -n - name of norm file to use (default:
  norm.mgs) must include the corresponding norm file for all given
  timepoints as well as for the current subject **Required.**

- in_segmentations:

  Character or numeric vector. name of aseg file to use (default:
  aseg.mgz) must include the aseg files for all the given timepoints
  **Required.**

- in_segmentations_noCC:

  Character or numeric vector. name of aseg file w/o CC labels (default:
  aseg.auto_noCCseg.mgz) must include the corresponding file for all the
  given timepoints **Required.**

- out_file:

  Character; file path. output fused segmentation file **Required.**

- timepoints:

  Character or numeric vector. subject_ids or timepoints to be processed
  **Required.**

- args:

  Character. Additional parameters to the command

- subject_id:

  Character. subject_id being processed

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
