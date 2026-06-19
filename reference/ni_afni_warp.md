# AFNI Warp

Use 3dWarp for spatially transforming a dataset.

## Usage

``` r
ni_afni_warp(
  in_file,
  args = NULL,
  deoblique = NULL,
  gridset = NULL,
  interp = NULL,
  matparent = NULL,
  mni2tta = NULL,
  newgrid = NULL,
  oblique_parent = NULL,
  out_file = NULL,
  tta2mni = NULL,
  verbose = NULL,
  zpad = NULL,
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

  Character; file path. input file to 3dWarp **Required.**

- args:

  Character. Additional parameters to the command

- deoblique:

  Logical. transform dataset from oblique to cardinal

- gridset:

  Character; file path. copy grid of specified dataset

- interp:

  Character; one of: "linear", "cubic", "NN", "quintic". spatial
  interpolation methods \[default = linear\]

- matparent:

  Character; file path. apply transformation from 3dWarpDrive

- mni2tta:

  Logical. transform dataset from MNI152 to Talaraich

- newgrid:

  Numeric. specify grid of this size (mm)

- oblique_parent:

  Character; file path. Read in the oblique transformation matrix from
  an oblique dataset and make cardinal dataset oblique to match

- out_file:

  Character; file path. output image file name

- tta2mni:

  Logical. transform dataset from Talairach to MNI152

- verbose:

  Logical. Print out some information along the way.

- zpad:

  Integer. pad input dataset with N planes of zero on all sides.

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
