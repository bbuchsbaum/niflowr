# AFNI MaskTool

3dmask_tool - for combining/dilating/eroding/filling masks

## Usage

``` r
ni_afni_mask_tool(
  in_file,
  args = NULL,
  count = NULL,
  datum = NULL,
  dilate_inputs = NULL,
  dilate_results = NULL,
  fill_dirs = NULL,
  fill_holes = NULL,
  frac = NULL,
  inter = NULL,
  out_file = NULL,
  union = NULL,
  verbose = NULL,
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

  Character or numeric vector. input file or files to 3dmask_tool
  **Required.**

- args:

  Character. Additional parameters to the command

- count:

  Logical. Instead of created a binary 0/1 mask dataset, create one with
  counts of voxel overlap, i.e., each voxel will contain the number of
  masks that it is set in.

- datum:

  Character; one of: "byte", "short", "float". specify data type for
  output.

- dilate_inputs:

  Character. Use this option to dilate and/or erode datasets as they are
  read. ex. '5 -5' to dilate and erode 5 times

- dilate_results:

  Character. dilate and/or erode combined mask at the given levels.

- fill_dirs:

  Character. fill holes only in the given directions. This option is for
  use with -fill holes. should be a single string that specifies 1-3 of
  the axes using {x,y,z} labels (i.e. dataset axis order), or using the
  labels in {R,L,A,P,I,S}.

- fill_holes:

  Logical. This option can be used to fill holes in the resulting mask,
  i.e. after all other processing has been done.

- frac:

  Numeric. When combining masks (across datasets and sub-bricks), use
  this option to restrict the result to a certain fraction of the set of
  volumes

- inter:

  Logical. intersection, this means -frac 1.0

- out_file:

  Character; file path. output image file name

- union:

  Logical. union, this means -frac 0

- verbose:

  Integer. specify verbosity level, for 0 to 3

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
