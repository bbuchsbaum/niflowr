# AFNI LocalBistat

3dLocalBistat - computes statistics between 2 datasets, at each voxel,

## Usage

``` r
ni_afni_local_bistat(
  in_file1,
  in_file2,
  neighborhood,
  stat,
  args = NULL,
  automask = NULL,
  mask_file = NULL,
  out_file = NULL,
  weight_file = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- in_file1:

  Character; file path. Filename of the first image **Required.**

- in_file2:

  Character; file path. Filename of the second image **Required.**

- neighborhood:

  Character or numeric vector. The region around each voxel that will be
  extracted for the statistics calculation. Possible regions are:
  'SPHERE', 'RHDD' (rhombic dodecahedron), 'TOHD' (truncated octahedron)
  with a given radius in mm or 'RECT' (rectangular block) with
  dimensions to specify in mm. **Required.**

- stat:

  Character or numeric vector. Statistics to compute. Possible names
  are: \* pearson = Pearson correlation coefficient \* spearman =
  Spearman correlation coefficient \* quadrant = Quadrant correlation
  coefficient \* mutinfo = Mutual Information \* normuti = Normalized
  Mutual Information \* jointent = Joint entropy \* hellinger= Hellinger
  metric \* crU = Correlation ratio (Unsymmetric) \* crM = Correlation
  ratio (symmetrized by Multiplication) \* crA = Correlation ratio
  (symmetrized by Addition) \* L2slope = slope of least-squares (L2)
  linear regression of the data from dataset1 vs. the dataset2 (i.e., d2
  = a + b\*d1 ==\> this is 'b') \* L1slope = slope of least-absolute-sum
  (L1) linear regression of the data from dataset1 vs. the dataset2 \*
  num = number of the values in the region: with the use of -mask or
  -automask, the size of the region around any given voxel will vary;
  this option lets you map that size. \* ALL = all of the above, in that
  order More than one option can be used. **Required.**

- args:

  Character. Additional parameters to the command

- automask:

  Logical. Compute the mask as in program 3dAutomask.

- mask_file:

  Character; file path. mask image file name. Voxels NOT in the mask
  will not be used in the neighborhood of any voxel. Also, a voxel NOT
  in the mask will have its statistic(s) computed as zero (0).

- out_file:

  Character; file path. Output dataset.

- weight_file:

  Character; file path. File name of an image to use as a weight. Only
  applies to 'pearson' statistics.

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
