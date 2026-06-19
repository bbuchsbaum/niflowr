# FreeSurfer SynthStrip

SynthStrip is a deep-learning skull-stripping tool that produces
accurate brain masks across MRI contrasts (T1w, T2w, FLAIR, EPI, CT).
Bundled with FreeSurfer 7.3+ as the mri_synthstrip command.

## Usage

``` r
ni_freesurfer_synthstrip(
  in_file,
  out_file = NULL,
  mask_file = NULL,
  sdt_file = NULL,
  border = NULL,
  gpu = NULL,
  threads = NULL,
  no_csf = NULL,
  model = NULL,
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

- in_file:

  Character; file path. Input volume to skull strip (any MRI contrast)
  **Required.**

- out_file:

  Character; file path. Skull-stripped image output

- mask_file:

  Character; file path. Binary brain mask output

- sdt_file:

  Character; file path. Signed distance transform output

- border:

  Integer. Mask border threshold in mm (default 1)

- gpu:

  Logical. Use the GPU for inference

- threads:

  Integer. Number of CPU threads

- no_csf:

  Logical. Exclude CSF from the brain mask (uses the SynthStrip-CSF
  model)

- model:

  Character; file path. Path to alternate model weights file

- args:

  Character. Additional parameters passed verbatim to mri_synthstrip

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
