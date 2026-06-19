# ANTS KellyKapowski

Nipype Interface to ANTs' KellyKapowski, also known as DiReCT.

## Usage

``` r
ni_ants_kelly_kapowski(
  segmentation_image,
  args = NULL,
  convergence = "[50,0.001,10]",
  cortical_thickness = NULL,
  dimension = 3,
  gradient_step = 0.025,
  gray_matter_prob_image = NULL,
  max_invert_displacement_field_iters = 20,
  number_integration_points = 10,
  smoothing_variance = 1,
  smoothing_velocity_field = 1.5,
  thickness_prior_estimate = 10,
  thickness_prior_image = NULL,
  use_bspline_smoothing = NULL,
  white_matter_prob_image = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- segmentation_image:

  Character; file path. A segmentation image must be supplied labeling
  the gray and white matters. Default values = 2 and 3, respectively.
  **Required.**

- args:

  Character. Additional parameters to the command

- convergence:

  Character. Convergence is determined by fitting a line to the
  normalized energy profile of the last N iterations (where N is
  specified by the window size) and determining the slope which is then
  compared with the convergence threshold.

- cortical_thickness:

  Character; file path. Filename for the cortical thickness.

- dimension:

  Character; one of: "3", "2". image dimension (2 or 3)

- gradient_step:

  Numeric. Gradient step size for the optimization.

- gray_matter_prob_image:

  Character; file path. In addition to the segmentation image, a gray
  matter probability image can be used. If no such image is supplied,
  one is created using the segmentation image and a variance of 1.0 mm.

- max_invert_displacement_field_iters:

  Integer. Maximum number of iterations for estimating the
  invertdisplacement field.

- number_integration_points:

  Integer. Number of compositions of the diffeomorphism per iteration.

- smoothing_variance:

  Numeric. Defines the Gaussian smoothing of the hit and total images.

- smoothing_velocity_field:

  Numeric. Defines the Gaussian smoothing of the velocity field (default
  = 1.5). If the b-spline smoothing option is chosen, then this defines
  the isotropic mesh spacing for the smoothing spline (default = 15).

- thickness_prior_estimate:

  Numeric. Provides a prior constraint on the final thickness
  measurement in mm.

- thickness_prior_image:

  Character; file path. An image containing spatially varying prior
  thickness values.

- use_bspline_smoothing:

  Logical. Sets the option for B-spline smoothing of the velocity field.

- white_matter_prob_image:

  Character; file path. In addition to the segmentation image, a white
  matter probability image can be used. If no such image is supplied,
  one is created using the segmentation image and a variance of 1.0 mm.

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
