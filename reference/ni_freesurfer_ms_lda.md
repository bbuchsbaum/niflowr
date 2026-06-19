# FREESURFER MS_LDA

Perform LDA reduction on the intensity space of an arbitrary \# of FLASH
images

## Usage

``` r
ni_freesurfer_ms_lda(
  images,
  lda_labels,
  vol_synth_file,
  weight_file,
  args = NULL,
  conform = NULL,
  label_file = NULL,
  mask_file = NULL,
  shift = NULL,
  use_weights = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- images:

  Character or numeric vector. list of input FLASH images **Required.**

- lda_labels:

  Character or numeric vector. pair of class labels to optimize
  **Required.**

- vol_synth_file:

  Character; file path. filename for the synthesized output volume
  **Required.**

- weight_file:

  Character; file path. filename for the LDA weights (input or output)
  **Required.**

- args:

  Character. Additional parameters to the command

- conform:

  Logical. Conform the input volumes (brain mask typically already
  conformed)

- label_file:

  Character; file path. filename of the label volume

- mask_file:

  Character; file path. filename of the brain mask volume

- shift:

  Integer. shift all values equal to the given value to zero

- use_weights:

  Logical. Use the weights from a previously generated weight file

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
