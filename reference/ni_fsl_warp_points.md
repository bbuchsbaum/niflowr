# FSL WarpPoints

Use FSL
`img2imgcoord <http://fsl.fmrib.ox.ac.uk/fsl/fsl-4.1.9/flirt/overview.html>`\_

## Usage

``` r
ni_fsl_warp_points(
  dest_file,
  in_coords,
  src_file,
  args = NULL,
  coord_mm = NULL,
  coord_vox = NULL,
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

- dest_file:

  Character; file path. filename of destination image **Required.**

- in_coords:

  Character; file path. filename of file containing coordinates
  **Required.**

- src_file:

  Character; file path. filename of source image **Required.**

- args:

  Character. Additional parameters to the command

- coord_mm:

  Logical. all coordinates in mm

- coord_vox:

  Logical. all coordinates in voxels - default

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
