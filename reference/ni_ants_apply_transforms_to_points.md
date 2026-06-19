# ANTS ApplyTransformsToPoints

ApplyTransformsToPoints, applied to an CSV file, transforms coordinates

## Usage

``` r
ni_ants_apply_transforms_to_points(
  input_file,
  transforms,
  args = NULL,
  dimension = NULL,
  output_file = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- input_file:

  Character; file path. Currently, the only input supported is a csv
  file with columns including x,y (2D), x,y,z (3D) or x,y,z,t,label (4D)
  column headers. The points should be defined in physical space. If in
  doubt how to convert coordinates from your files to the space required
  by antsApplyTransformsToPoints try creating/drawing a simple label
  volume with only one voxel set to 1 and all others set to 0. Write
  down the voxel coordinates. Then use ImageMaths LabelStats to find out
  what coordinates for this voxel antsApplyTransformsToPoints is
  expecting. **Required.**

- transforms:

  Character or numeric vector. transforms that will be applied to the
  points **Required.**

- args:

  Character. Additional parameters to the command

- dimension:

  Character; one of: "2", "3", "4". This option forces the image to be
  treated as a specified-dimensional image. If not specified, antsWarp
  tries to infer the dimensionality from the input image.

- output_file:

  Character. Name of the output CSV file

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
