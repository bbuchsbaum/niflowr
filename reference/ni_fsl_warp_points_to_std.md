# FSL WarpPointsToStd

Use FSL
`img2stdcoord <http://fsl.fmrib.ox.ac.uk/fsl/fsl-4.1.9/flirt/overview.html>`\_

## Usage

``` r
ni_fsl_warp_points_to_std(
  img_file,
  in_coords,
  std_file,
  args = NULL,
  coord_mm = NULL,
  coord_vox = NULL,
  premat_file = NULL,
  warp_file = NULL,
  xfm_file = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- img_file:

  Character; file path. filename of input image **Required.**

- in_coords:

  Character; file path. filename of file containing coordinates
  **Required.**

- std_file:

  Character; file path. filename of destination image **Required.**

- args:

  Character. Additional parameters to the command

- coord_mm:

  Logical. all coordinates in mm

- coord_vox:

  Logical. all coordinates in voxels - default

- premat_file:

  Character; file path. filename of pre-warp affine transform (e.g.
  example_func2highres.mat)

- warp_file:

  Character; file path. filename of warpfield (e.g.
  intermediate2dest_warp.nii.gz)

- xfm_file:

  Character; file path. filename of affine transform (e.g.
  source2dest.mat)

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
