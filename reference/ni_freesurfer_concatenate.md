# FREESURFER Concatenate

Use Freesurfer mri_concat to combine several input volumes

## Usage

``` r
ni_freesurfer_concatenate(
  in_files,
  add_val = NULL,
  args = NULL,
  combine = NULL,
  concatenated_file = NULL,
  gmean = NULL,
  keep_dtype = NULL,
  mask_file = NULL,
  max_bonfcor = NULL,
  max_index = NULL,
  mean_div_n = NULL,
  multiply_by = NULL,
  multiply_matrix_file = NULL,
  paired_stats = NULL,
  sign = NULL,
  sort = NULL,
  stats = NULL,
  vote = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- in_files:

  Character or numeric vector. Individual volumes to be concatenated
  **Required.**

- add_val:

  Numeric. Add some amount to the input volume

- args:

  Character. Additional parameters to the command

- combine:

  Logical. Combine non-zero values into single frame volume

- concatenated_file:

  Character; file path. Output volume

- gmean:

  Integer. create matrix to average Ng groups, Nper=Ntot/Ng

- keep_dtype:

  Logical. Keep voxelwise precision type (default is float

- mask_file:

  Character; file path. Mask input with a volume

- max_bonfcor:

  Logical. Compute max and bonferroni correct (assumes -log10(ps))

- max_index:

  Logical. Compute the index of max voxel in concatenated volumes

- mean_div_n:

  Logical. compute mean/nframes (good for var)

- multiply_by:

  Numeric. Multiply input volume by some amount

- multiply_matrix_file:

  Character; file path. Multiply input by an ascii matrix in file

- paired_stats:

  Character; one of: "sum", "avg", "diff", "diff-norm", "diff-norm1",
  "diff-norm2". Compute paired sum, avg, or diff

- sign:

  Character; one of: "abs", "pos", "neg". Take only pos or neg voxles
  from input, or take abs

- sort:

  Logical. Sort each voxel by ascending frame value

- stats:

  Character; one of: "sum", "var", "std", "max", "min", "mean". Compute
  the sum, var, std, max, min or mean of the input volumes

- vote:

  Logical. Most frequent value at each voxel and fraction of occurrences

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
