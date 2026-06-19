# ANTS N4BiasFieldCorrection

Bias field correction.

## Usage

``` r
ni_ants_n4_bias_field_correction(
  copy_header,
  input_image,
  save_bias,
  args = NULL,
  bspline_fitting_distance = NULL,
  dimension = 3,
  histogram_sharpening = NULL,
  mask_image = NULL,
  n_iterations = NULL,
  output_image = NULL,
  rescale_intensities = FALSE,
  shrink_factor = NULL,
  weight_image = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- copy_header:

  Logical. copy headers of the original image into the output
  (corrected) file **Required.**

- input_image:

  Character; file path. input for bias correction. Negative values or
  values close to zero should be processed prior to correction
  **Required.**

- save_bias:

  Logical. True if the estimated bias should be saved to file.
  **Required.**

- args:

  Character. Additional parameters to the command

- bspline_fitting_distance:

  Numeric

- dimension:

  Character; one of: "3", "2", "4". image dimension (2, 3 or 4)

- histogram_sharpening:

  Character or numeric vector. Three-values tuple of histogram
  sharpening parameters (FWHM, wienerNose, numberOfHistogramBins). These
  options describe the histogram sharpening parameters, i.e. the
  deconvolution step parameters described in the original N3 algorithm.
  The default values have been shown to work fairly well.

- mask_image:

  Character; file path. image to specify region to perform final bias
  correction in

- n_iterations:

  Character or numeric vector

- output_image:

  Character. output file name

- rescale_intensities:

  Logical. \[NOTE: Only ANTs\>=2.1.0\] At each iteration, a new
  intensity mapping is calculated and applied but there is nothing which
  constrains the new intensity range to be within certain values. The
  result is that the range can "drift" from the original at each
  iteration. This option rescales to the \[min,max\] range of the
  original image intensities within the user-specified mask.

- shrink_factor:

  Integer

- weight_image:

  Character; file path. image for relative weighting (e.g. probability
  map of the white matter) of voxels during the B-spline fitting.

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
