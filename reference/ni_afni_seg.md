# AFNI Seg

3dSeg segments brain volumes into tissue classes. The program allows

## Usage

``` r
ni_afni_seg(
  in_file,
  mask,
  args = NULL,
  bias_classes = NULL,
  bias_fwhm = NULL,
  blur_meth = NULL,
  bmrf = NULL,
  classes = NULL,
  main_N = NULL,
  mixfloor = NULL,
  mixfrac = NULL,
  prefix = NULL,
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

  Character; file path. ANAT is the volume to segment **Required.**

- mask:

  Character or numeric vector. only non-zero voxels in mask are
  analyzed. mask can either be a dataset or the string "AUTO" which
  would use AFNI's automask function to create the mask. **Required.**

- args:

  Character. Additional parameters to the command

- bias_classes:

  Character. A semicolon delimited string of classes that contribute to
  the estimation of the bias field

- bias_fwhm:

  Numeric. The amount of blurring used when estimating the field bias
  with the Wells method

- blur_meth:

  Character; one of: "BFT", "BIM". set the blurring method for bias
  field estimation

- bmrf:

  Numeric. Weighting factor controlling spatial homogeneity of the
  classifications

- classes:

  Character. CLASS_STRING is a semicolon delimited string of class
  labels

- main_N:

  Integer. Number of iterations to perform.

- mixfloor:

  Numeric. Set the minimum value for any class's mixing fraction

- mixfrac:

  Character. MIXFRAC sets up the volume-wide (within mask) tissue
  fractions while initializing the segmentation (see IGNORE for
  exception)

- prefix:

  Character. the prefix for the output folder containing all output
  volumes

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
