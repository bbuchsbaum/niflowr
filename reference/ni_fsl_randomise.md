# FSL Randomise

FSL Randomise: feeds the 4D projected FA data into GLM

## Usage

``` r
ni_fsl_randomise(
  in_file,
  args = NULL,
  base_name = "randomise",
  c_thresh = NULL,
  cm_thresh = NULL,
  demean = NULL,
  design_mat = NULL,
  f_c_thresh = NULL,
  f_cm_thresh = NULL,
  f_only = NULL,
  fcon = NULL,
  mask = NULL,
  num_perm = NULL,
  one_sample_group_mean = NULL,
  p_vec_n_dist_files = NULL,
  raw_stats_imgs = NULL,
  seed = NULL,
  show_info_parallel_mode = NULL,
  show_total_perms = NULL,
  tcon = NULL,
  tfce = NULL,
  tfce2D = NULL,
  tfce_C = NULL,
  tfce_E = NULL,
  tfce_H = NULL,
  var_smooth = NULL,
  vox_p_values = NULL,
  x_block_labels = NULL,
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

  Character; file path. 4D input file **Required.**

- args:

  Character. Additional parameters to the command

- base_name:

  Character. the rootname that all generated files will have

- c_thresh:

  Numeric. carry out cluster-based thresholding

- cm_thresh:

  Numeric. carry out cluster-mass-based thresholding

- demean:

  Logical. demean data temporally before model fitting

- design_mat:

  Character; file path. design matrix file

- f_c_thresh:

  Numeric. carry out f cluster thresholding

- f_cm_thresh:

  Numeric. carry out f cluster-mass thresholding

- f_only:

  Logical. calculate f-statistics only

- fcon:

  Character; file path. f contrasts file

- mask:

  Character; file path. mask image

- num_perm:

  Integer. number of permutations (default 5000, set to 0 for
  exhaustive)

- one_sample_group_mean:

  Logical. perform 1-sample group-mean test instead of generic
  permutation test

- p_vec_n_dist_files:

  Logical. output permutation vector and null distribution text files

- raw_stats_imgs:

  Logical. output raw ( unpermuted ) statistic images

- seed:

  Integer. specific integer seed for random number generator

- show_info_parallel_mode:

  Logical. print out information required for parallel mode and exit

- show_total_perms:

  Logical. print out how many unique permutations would be generated and
  exit

- tcon:

  Character; file path. t contrasts file

- tfce:

  Logical. carry out Threshold-Free Cluster Enhancement

- tfce2D:

  Logical. carry out Threshold-Free Cluster Enhancement with 2D
  optimisation

- tfce_C:

  Numeric. TFCE connectivity (6 or 26; default=6)

- tfce_E:

  Numeric. TFCE extent parameter (default=0.5)

- tfce_H:

  Numeric. TFCE height parameter (default=2)

- var_smooth:

  Integer. use variance smoothing (std is in mm)

- vox_p_values:

  Logical. output voxelwise (corrected and uncorrected) p-value images

- x_block_labels:

  Character; file path. exchangeability block labels file

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
