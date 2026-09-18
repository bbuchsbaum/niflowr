# AFNI 3dAllineate affine application

Apply one or more AFNI affine rows to a source series on an explicit
master grid.

## Usage

``` r
ni_afni_allineate_apply(
  in_file,
  in_matrix,
  master,
  out_file,
  final_interpolation,
  floatize = TRUE,
  no_pad = FALSE,
  zclip = FALSE,
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

  Character; file path. Source image or timeseries to resample.
  **Required.**

- in_matrix:

  Character; file path. AFNI base-to-source affine rows to apply.
  **Required.**

- master:

  Character; file path. Image defining the complete output sampling
  grid. **Required.**

- out_file:

  Character; file path. Destination image or timeseries. **Required.**

- final_interpolation:

  Character; one of: "NN", "linear", "cubic", "quintic", "wsinc5".
  Interpolation used only for final output sampling. **Required.**

- floatize:

  Logical. Write output in floating-point format.

- no_pad:

  Logical. Disable base-image zero padding.

- zclip:

  Logical. Replace negative source and base values with zero.

- overwrite:

  Logical. Permit AFNI to overwrite an existing output dataset.

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
