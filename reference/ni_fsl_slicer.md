# FSL Slicer

Use FSL's slicer command to output a png image from a volume.

## Usage

``` r
ni_fsl_slicer(
  in_file,
  all_axial = NULL,
  args = NULL,
  colour_map = NULL,
  dither_edges = NULL,
  image_edges = NULL,
  image_width = NULL,
  intensity_range = NULL,
  label_slices = TRUE,
  middle_slices = NULL,
  nearest_neighbour = NULL,
  out_file = NULL,
  sample_axial = NULL,
  scaling = NULL,
  show_orientation = TRUE,
  single_slice = NULL,
  slice_number = NULL,
  threshold_edges = NULL,
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

  Character; file path. input volume **Required.**

- all_axial:

  Logical. output all axial slices into one picture

- args:

  Character. Additional parameters to the command

- colour_map:

  Character; file path. use different colour map from that stored in
  nifti header

- dither_edges:

  Logical. produce semi-transparent (dithered) edges

- image_edges:

  Character; file path. volume to display edge overlay for (useful for
  checking registration

- image_width:

  Integer. max picture width

- intensity_range:

  Character or numeric vector. min and max intensities to display

- label_slices:

  Logical. display slice number

- middle_slices:

  Logical. output picture of mid-sagittal, axial, and coronal slices

- nearest_neighbour:

  Logical. use nearest neighbor interpolation for output

- out_file:

  Character; file path. picture to write

- sample_axial:

  Integer. output every n axial slices into one picture

- scaling:

  Numeric. image scale

- show_orientation:

  Logical. label left-right orientation

- single_slice:

  Character; one of: "x", "y", "z". output picture of single slice in
  the x, y, or z plane

- slice_number:

  Integer. slice number to save in picture

- threshold_edges:

  Numeric. use threshold for edges

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
