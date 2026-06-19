# AFNI ROIStats

Display statistics over masked regions

## Usage

``` r
ni_afni_roi_stats(
  in_file,
  args = NULL,
  debug = NULL,
  format1D = NULL,
  format1DR = NULL,
  mask = NULL,
  mask_f2short = NULL,
  mask_file = NULL,
  nobriklab = NULL,
  nomeanout = NULL,
  num_roi = NULL,
  out_file = NULL,
  quiet = NULL,
  roisel = NULL,
  stat = NULL,
  zerofill = NULL,
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

  Character; file path. input dataset **Required.**

- args:

  Character. Additional parameters to the command

- debug:

  Logical. print debug information

- format1D:

  Logical. Output results in a 1D format that includes commented labels

- format1DR:

  Logical. Output results in a 1D format that includes uncommented
  labels. May not work optimally with typical 1D functions, but is
  useful for R functions.

- mask:

  Character; file path. input mask

- mask_f2short:

  Logical. Tells the program to convert a float mask to short integers,
  by simple rounding.

- mask_file:

  Character; file path. input mask

- nobriklab:

  Logical. Do not print the sub-brick label next to its index

- nomeanout:

  Logical. Do not include the (zero-inclusive) mean among computed stats

- num_roi:

  Integer. Forces the assumption that the mask dataset's ROIs are
  denoted by 1 to n inclusive. Normally, the program figures out the
  ROIs on its own. This option is useful if a) you are certain that the
  mask dataset has no values outside the range \[0 n\], b) there may be
  some ROIs missing between \[1 n\] in the mask data-set and c) you want
  those columns in the output any-way so the output lines up with the
  output from other invocations of 3dROIstats.

- out_file:

  Character; file path. output file

- quiet:

  Logical. execute quietly

- roisel:

  Character; file path. Only considers ROIs denoted by values found in
  the specified file. Note that the order of the ROIs as specified in
  the file is not preserved. So an SEL.1D of '2 8 20' produces the same
  output as '8 20 2'

- stat:

  Character or numeric vector. Statistics to compute. Options include:
  \* mean = Compute the mean using only non_zero voxels. Implies the
  opposite for the mean computed by default. \* median = Compute the
  median of nonzero voxels \* mode = Compute the mode of nonzero voxels.
  (integral valued sets only) \* minmax = Compute the min/max of nonzero
  voxels \* sum = Compute the sum using only nonzero voxels. \* voxels =
  Compute the number of nonzero voxels \* sigma = Compute the standard
  deviation of nonzero voxels Statistics that include zero-valued
  voxels: \* zerominmax = Compute the min/max of all voxels. \*
  zerosigma = Compute the standard deviation of all voxels. \*
  zeromedian = Compute the median of all voxels. \* zeromode = Compute
  the mode of all voxels. \* summary = Only output a summary line with
  the grand mean across all briks in the input dataset. This option
  cannot be used with nomeanout. More that one option can be specified.

- zerofill:

  Character. For ROI labels not found, use the provided string instead
  of a '0' in the output file. Only active if `num_roi` is enabled.

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
