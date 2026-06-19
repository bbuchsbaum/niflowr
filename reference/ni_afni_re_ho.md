# AFNI ReHo

Compute regional homogeneity for a given neighbourhood.l,

## Usage

``` r
ni_afni_re_ho(
  in_file,
  args = NULL,
  chi_sq = NULL,
  ellipsoid = NULL,
  label_set = NULL,
  mask_file = NULL,
  neighborhood = NULL,
  out_file = NULL,
  overwrite = NULL,
  sphere = NULL,
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

- chi_sq:

  Logical. Output the Friedman chi-squared value in addition to the
  Kendall's W. This option is currently compatible only with the AFNI
  (BRIK/HEAD) output type; the chi-squared value will be the second
  sub-brick of the output dataset.

- ellipsoid:

  Character or numeric vector. \\ Tuple indicating the x, y, and z
  radius of an ellipsoid defining the neighbourhood of each voxel. The
  'hood is then made according to the following relation:
  :math:`(i/A)^2 + (j/B)^2 + (k/C)^2 \\le 1.` which will have approx.
  :math:`V=4 \\pi \\, A B C/3`. The impetus for this freedom was for use
  with data having anisotropic voxel edge lengths.

- label_set:

  Character; file path. a set of ROIs, each labelled with distinct
  integers. ReHo will then be calculated per ROI.

- mask_file:

  Character; file path. Mask within which ReHo should be calculated
  voxelwise

- neighborhood:

  Character; one of: "faces", "edges", "vertices". voxels in
  neighborhood. can be: `faces` (for voxel and 6 facewise neighbors,
  only), `edges` (for voxel and 18 face- and edge-wise neighbors),
  `vertices` (for voxel and 26 face-, edge-, and node-wise neighbors).

- out_file:

  Character; file path. Output dataset.

- overwrite:

  Logical. overwrite output file if it already exists

- sphere:

  Numeric. \\ For additional voxelwise neighborhood control, the radius
  R of a desired neighborhood can be put in; R is a floating point
  number, and must be \>1. Examples of the numbers of voxels in a given
  radius are as follows (you can roughly approximate with the ol'
  :math:`4\\pi\\,R^3/3` thing): \* R=2.0 -\> V=33 \* R=2.3 -\> V=57, \*
  R=2.9 -\> V=93, \* R=3.1 -\> V=123, \* R=3.9 -\> V=251, \* R=4.5 -\>
  V=389, \* R=6.1 -\> V=949, but you can choose most any value.

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
