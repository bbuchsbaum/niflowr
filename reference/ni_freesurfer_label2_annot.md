# FREESURFER Label2Annot

Converts a set of surface labels to an annotation file

## Usage

``` r
ni_freesurfer_label2_annot(
  hemisphere,
  in_labels,
  orig,
  out_annot,
  subject_id,
  args = NULL,
  color_table = NULL,
  keep_max = NULL,
  verbose_off = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- hemisphere:

  Character; one of: "lh", "rh". Input hemisphere **Required.**

- in_labels:

  Character or numeric vector. List of input label files **Required.**

- orig:

  Character; file path. implicit {hemisphere}.orig **Required.**

- out_annot:

  Character. Name of the annotation to create **Required.**

- subject_id:

  Character. Subject name/ID **Required.**

- args:

  Character. Additional parameters to the command

- color_table:

  Character; file path. File that defines the structure names, their
  indices, and their color

- keep_max:

  Logical. Keep label with highest 'stat' value

- verbose_off:

  Logical. Turn off overlap and stat override messages

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
