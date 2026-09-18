# AFNI 3dAllineate affine estimation

Estimate an affine mapping and save its AFNI base-to-source matrix
without requiring a resampled image.

## Usage

``` r
ni_afni_allineate_estimate(
  in_file,
  reference,
  out_matrix,
  out_file = "NULL",
  cost,
  warp_type = "affine_general",
  interpolation = "linear",
  floatize = TRUE,
  no_pad = FALSE,
  zclip = FALSE,
  weight_file = NULL,
  source_mask = NULL,
  overwrite = NULL,
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

  Character; file path. Source image to align. **Required.**

- reference:

  Character; file path. Fixed base image defining the reference frame.
  **Required.**

- out_matrix:

  Character; file path. Destination for AFNI base-to-source affine rows.
  **Required.**

- out_file:

  Character; file path. Optional resampled image; NULL suppresses image
  output.

- cost:

  Character; one of: "lpa+ZZ", "lpa+", "lpa", "lpc+ZZ", "lpc+", "lpc",
  "nmi", "mi", "hel", "crA", "crM", "crU", "ls". Cost function used for
  estimation. **Required.**

- warp_type:

  Character; one of: "shift_only", "shift_rotate", "shift_rotate_scale",
  "affine_general". Degrees of freedom for the estimated mapping.

- interpolation:

  Character; one of: "NN", "linear", "cubic", "quintic". Interpolation
  used during the fine estimation pass.

- floatize:

  Logical. Write a requested image output in floating-point format.

- no_pad:

  Logical. Disable base-image zero padding.

- zclip:

  Logical. Replace negative source and base values with zero.

- weight_file:

  Character; file path. Optional weight image on the reference grid.

- source_mask:

  Character; file path. Optional mask on the source grid.

- overwrite:

  Logical. Permit AFNI to overwrite existing output datasets.

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
