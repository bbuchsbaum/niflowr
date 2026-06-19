# ANTS CreateTiledMosaic

The program CreateTiledMosaic in conjunction with
ConvertScalarImageToRGB

## Usage

``` r
ni_ants_create_tiled_mosaic(
  input_image,
  rgb_image,
  alpha_value = NULL,
  args = NULL,
  direction = NULL,
  flip_slice = NULL,
  mask_image = NULL,
  output_image = "output.png",
  pad_or_crop = NULL,
  permute_axes = NULL,
  slices = NULL,
  tile_geometry = NULL,
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

  Character; file path. Main input is a 3-D grayscale image.
  **Required.**

- rgb_image:

  Character; file path. An optional Rgb image can be added as an
  overlay.It must have the same imagegeometry as the input grayscale
  image. **Required.**

- alpha_value:

  Numeric. If an Rgb image is provided, render the overlay using the
  specified alpha parameter.

- args:

  Character. Additional parameters to the command

- direction:

  Integer. Specifies the direction of the slices. If no direction is
  specified, the direction with the coarsest spacing is chosen.

- flip_slice:

  Character. flipXxflipY

- mask_image:

  Character; file path. Specifies the ROI of the RGB voxels used.

- output_image:

  Character. The output consists of the tiled mosaic image.

- pad_or_crop:

  Character. argument passed to -p
  flag:\[padVoxelWidth,\<constantValue=0\>\]\[lowerPadding\[0\]xlowerPadding\[1\],upperPadding\[0\]xupperPadding\[1\],constantValue\]The
  user can specify whether to pad or crop a specified voxel-width
  boundary of each individual slice. For this program, cropping is
  simply padding with negative voxel-widths.If one pads (+), the user
  can also specify a constant pad value (default = 0). If a mask is
  specified, the user can use the mask to define the region, by using
  the keyword "mask" plus an offset, e.g. "-p mask+3".

- permute_axes:

  Logical. doPermute

- slices:

  Character. Number of slices to increment
  Slice1xSlice2xSlice3\[numberOfSlicesToIncrement,\<minSlice=0\>,\<maxSlice=lastSlice\>\]

- tile_geometry:

  Character. The tile geometry specifies the number of rows and
  columnsin the output image. For example, if the user specifies "5x10",
  then 5 rows by 10 columns of slices are rendered. If R \< 0 and C \> 0
  (or vice versa), the negative value is selectedbased on direction.

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
