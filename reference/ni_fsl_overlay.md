# FSL Overlay

Use FSL's overlay command to combine background and statistical images

## Usage

``` r
ni_fsl_overlay(
  auto_thresh_bg,
  background_image,
  bg_thresh,
  full_bg_range,
  stat_image,
  stat_thresh,
  args = NULL,
  out_file = NULL,
  out_type = "float",
  show_negative_stats = NULL,
  stat_image2 = NULL,
  stat_thresh2 = NULL,
  transparency = TRUE,
  use_checkerboard = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- auto_thresh_bg:

  Logical. automatically threshold the background image **Required.**

- background_image:

  Character; file path. image to use as background **Required.**

- bg_thresh:

  Character or numeric vector. min and max values for background
  intensity **Required.**

- full_bg_range:

  Logical. use full range of background image **Required.**

- stat_image:

  Character; file path. statistical image to overlay in color
  **Required.**

- stat_thresh:

  Character or numeric vector. min and max values for the statistical
  overlay **Required.**

- args:

  Character. Additional parameters to the command

- out_file:

  Character; file path. combined image volume

- out_type:

  Character; one of: "float", "int". write output with float or int

- show_negative_stats:

  Logical. display negative statistics in overlay

- stat_image2:

  Character; file path. second statistical image to overlay in color

- stat_thresh2:

  Character or numeric vector. min and max values for second statistical
  overlay

- transparency:

  Logical. make overlay colors semi-transparent

- use_checkerboard:

  Logical. use checkerboard mask for overlay

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
