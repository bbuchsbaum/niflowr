# ANTS DenoiseImage

Examples

## Usage

``` r
ni_ants_denoise_image(
  input_image,
  save_noise,
  args = NULL,
  dimension = NULL,
  noise_model = "Gaussian",
  output_image = NULL,
  shrink_factor = 1,
  verbose = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- input_image:

  Character; file path. A scalar image is expected as input for noise
  correction. **Required.**

- save_noise:

  Logical. True if the estimated noise should be saved to file.
  **Required.**

- args:

  Character. Additional parameters to the command

- dimension:

  Character; one of: "2", "3", "4". This option forces the image to be
  treated as a specified-dimensional image. If not specified, the
  program tries to infer the dimensionality from the input image.

- noise_model:

  Character; one of: "Gaussian", "Rician". Employ a Rician or Gaussian
  noise model.

- output_image:

  Character; file path. The output consists of the noise corrected
  version of the input image.

- shrink_factor:

  Integer. Running noise correction on large images can be time
  consuming. To lessen computation time, the input image can be
  resampled. The shrink factor, specified as a single integer, describes
  this resampling. Shrink factor = 1 is the default.

- verbose:

  Logical. Verbose output.

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
