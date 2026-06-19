# FSL Cluster

Uses FSL cluster to perform clustering on statistical output

## Usage

``` r
ni_fsl_cluster(
  in_file,
  threshold,
  args = NULL,
  connectivity = NULL,
  cope_file = NULL,
  dlh = NULL,
  find_min = FALSE,
  fractional = FALSE,
  minclustersize = FALSE,
  no_table = FALSE,
  num_maxima = NULL,
  out_index_file = NULL,
  out_localmax_txt_file = NULL,
  out_localmax_vol_file = NULL,
  out_max_file = NULL,
  out_mean_file = NULL,
  out_pval_file = NULL,
  out_size_file = NULL,
  out_threshold_file = NULL,
  peak_distance = NULL,
  pthreshold = NULL,
  std_space_file = NULL,
  use_mm = FALSE,
  volume = NULL,
  warpfield_file = NULL,
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

- in_file:

  Character; file path. input volume **Required.**

- threshold:

  Numeric. threshold for input volume **Required.**

- args:

  Character. Additional parameters to the command

- connectivity:

  Integer. the connectivity of voxels (default 26)

- cope_file:

  Character; file path. cope volume

- dlh:

  Numeric. smoothness estimate = sqrt(det(Lambda))

- find_min:

  Logical. find minima instead of maxima

- fractional:

  Logical. interprets the threshold as a fraction of the robust range

- minclustersize:

  Logical. prints out minimum significant cluster size

- no_table:

  Logical. suppresses printing of the table info

- num_maxima:

  Integer. no of local maxima to report

- out_index_file:

  Character or numeric vector. output of cluster index (in size order)

- out_localmax_txt_file:

  Character or numeric vector. local maxima text file

- out_localmax_vol_file:

  Character or numeric vector. output of local maxima volume

- out_max_file:

  Character or numeric vector. filename for output of max image

- out_mean_file:

  Character or numeric vector. filename for output of mean image

- out_pval_file:

  Character or numeric vector. filename for image output of log pvals

- out_size_file:

  Character or numeric vector. filename for output of size image

- out_threshold_file:

  Character or numeric vector. thresholded image

- peak_distance:

  Numeric. minimum distance between local maxima/minima, in mm (default
  0)

- pthreshold:

  Numeric. p-threshold for clusters

- std_space_file:

  Character; file path. filename for standard-space volume

- use_mm:

  Logical. use mm, not voxel, coordinates

- volume:

  Integer. number of voxels in the mask

- warpfield_file:

  Character; file path. file containing warpfield

- xfm_file:

  Character; file path. filename for Linear: input-\>standard-space
  transform. Non-linear: input-\>highres transform

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
