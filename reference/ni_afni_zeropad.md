# AFNI Zeropad

Adds planes of zeros to a dataset (i.e., pads it out).

## Usage

``` r
ni_afni_zeropad(
  in_files,
  A = NULL,
  AP = NULL,
  I = NULL,
  IS = NULL,
  L = NULL,
  P = NULL,
  R = NULL,
  RL = NULL,
  S = NULL,
  args = NULL,
  master = NULL,
  mm = NULL,
  out_file = NULL,
  z = NULL,
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

  Character; file path. input dataset **Required.**

- A:

  Integer. adds 'n' planes of zero at the Anterior edge

- AP:

  Integer. specify that planes should be added or cut symmetrically to
  make the resulting volume haveN slices in the anterior-posterior
  direction

- I:

  Integer. adds 'n' planes of zero at the Inferior edge

- IS:

  Integer. specify that planes should be added or cut symmetrically to
  make the resulting volume haveN slices in the inferior-superior
  direction

- L:

  Integer. adds 'n' planes of zero at the Left edge

- P:

  Integer. adds 'n' planes of zero at the Posterior edge

- R:

  Integer. adds 'n' planes of zero at the Right edge

- RL:

  Integer. specify that planes should be added or cut symmetrically to
  make the resulting volume haveN slices in the right-left direction

- S:

  Integer. adds 'n' planes of zero at the Superior edge

- args:

  Character. Additional parameters to the command

- master:

  Character; file path. match the volume described in dataset 'mset',
  where mset must have the same orientation and grid spacing as dataset
  to be padded. the goal of -master is to make the output dataset from
  3dZeropad match the spatial 'extents' of mset by adding or subtracting
  slices as needed. You can't use -I,-S,..., or -mm with -master

- mm:

  Logical. pad counts 'n' are in mm instead of slices, where each 'n' is
  an integer and at least 'n' mm of slices will be added/removed; e.g.,
  n = 3 and slice thickness = 2.5 mm ==\> 2 slices added

- out_file:

  Character; file path. output dataset prefix name (default 'zeropad')

- z:

  Integer. adds 'n' planes of zero on EACH of the dataset z-axis
  (slice-direction) faces

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
