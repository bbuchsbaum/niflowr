# ANTS ConvertScalarImageToRGB

Convert scalar images to RGB.

## Usage

``` r
ni_ants_convert_scalar_image_to_rgb(
  colormap,
  dimension,
  input_image,
  maximum_input,
  minimum_input,
  args = NULL,
  custom_color_map_file = "none",
  mask_image = "none",
  maximum_RGB_output = 255,
  minimum_RGB_output = 0,
  output_image = "rgb.nii.gz",
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- colormap:

  Character; one of: "grey", "red", "green", "blue", "copper", "jet",
  "hsv", "spring", "summer", "autumn", "winter", "hot", "cool",
  "overunder", "custom". Select a colormap **Required.**

- dimension:

  Character; one of: "3", "2". image dimension (2 or 3) **Required.**

- input_image:

  Character; file path. Main input is a 3-D grayscale image.
  **Required.**

- maximum_input:

  Integer. maximum input **Required.**

- minimum_input:

  Integer. minimum input **Required.**

- args:

  Character. Additional parameters to the command

- custom_color_map_file:

  Character. custom color map file

- mask_image:

  Character or numeric vector. mask image

- maximum_RGB_output:

  Integer

- minimum_RGB_output:

  Integer

- output_image:

  Character. rgb output image

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
