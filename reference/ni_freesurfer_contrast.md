# FREESURFER Contrast

Compute surface-wise gray/white contrast

## Usage

``` r
ni_freesurfer_contrast(
  annotation,
  cortex,
  hemisphere,
  orig,
  rawavg,
  subject_id,
  thickness,
  white,
  args = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- annotation:

  Character; file path. Input annotation file must be
  \<subject_id\>/label/.aparc.annot **Required.**

- cortex:

  Character; file path. Input cortex label must be
  \<subject_id\>/label/.cortex.label **Required.**

- hemisphere:

  Character; one of: "lh", "rh". Hemisphere being processed
  **Required.**

- orig:

  Character; file path. Implicit input file mri/orig.mgz **Required.**

- rawavg:

  Character; file path. Implicit input file mri/rawavg.mgz **Required.**

- subject_id:

  Character. Subject being processed **Required.**

- thickness:

  Character; file path. Input file must be
  \<subject_id\>/surf/?h.thickness **Required.**

- white:

  Character; file path. Input file must be \<subject_id\>/surf/.white
  **Required.**

- args:

  Character. Additional parameters to the command

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
