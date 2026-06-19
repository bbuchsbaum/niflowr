# AFNI To3D

Create a 3D dataset from 2D image files using AFNI to3d command

## Usage

``` r
ni_afni_to3_d(
  in_folder,
  args = NULL,
  assumemosaic = NULL,
  datatype = NULL,
  filetype = NULL,
  funcparams = NULL,
  out_file = NULL,
  skipoutliers = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- in_folder:

  Character; directory path. folder with DICOM images to convert
  **Required.**

- args:

  Character. Additional parameters to the command

- assumemosaic:

  Logical. assume that Siemens image is mosaic

- datatype:

  Character; one of: "short", "float", "byte", "complex". set output
  file datatype

- filetype:

  Character; one of: "spgr", "fse", "epan", "anat", "ct", "spct", "pet",
  "mra", "bmap", "diff", "omri", "abuc", "fim", "fith", "fico", "fitt",
  "fift", "fizt", "fict", "fibt", "fibn", "figt", "fipt", "fbuc". type
  of datafile being converted

- funcparams:

  Character. parameters for functional data

- out_file:

  Character; file path. output image file name

- skipoutliers:

  Logical. skip the outliers check

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
