# AFNI Hist

Computes average of all voxels in the input dataset

## Usage

``` r
ni_afni_hist(
  in_file,
  args = NULL,
  bin_width = NULL,
  mask = NULL,
  max_value = NULL,
  min_value = NULL,
  nbin = NULL,
  out_file = NULL,
  out_show = NULL,
  showhist = FALSE,
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

  Character; file path. input file to 3dHist **Required.**

- args:

  Character. Additional parameters to the command

- bin_width:

  Numeric. bin width

- mask:

  Character; file path. matrix to align input file

- max_value:

  Numeric. maximum intensity value

- min_value:

  Numeric. minimum intensity value

- nbin:

  Integer. number of bins

- out_file:

  Character; file path. Write histogram to niml file with this prefix

- out_show:

  Character; file path. output image file name

- showhist:

  Logical. write a text visual histogram

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
