# AFNI Bucket

Concatenate sub-bricks from input datasets into one big

## Usage

``` r
ni_afni_bucket(
  in_file,
  args = NULL,
  out_file = NULL,
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

  Character or numeric vector. List of tuples of input datasets and
  subbrick selection strings as described in more detail in the
  following afni help string Input dataset specified using one of these
  forms: `prefix+view`, `prefix+view.HEAD`, or `prefix+view.BRIK`. You
  can also add a sub-brick selection list after the end of the dataset
  name. This allows only a subset of the sub-bricks to be included into
  the output (by default, all of the input dataset is copied into the
  output). A sub-brick selection list looks like one of the following
  forms:: fred+orig\[5\] ==\> use only sub-brick \#5 fred+orig\[5,9,17\]
  ==\> use \#5, \#9, and \#17 fred+orig\[5..8\] or \[5-8\] ==\> use \#5,
  \#6, \#7, and \#8 fred+orig\[5..13(2)\] or \[5-13(2)\] ==\> use \#5,
  \#7, \#9, \#11, and \#13 Sub-brick indexes start at 0. You can use the
  character '\$' to indicate the last sub-brick in a dataset; for
  example, you can select every third sub-brick by using the selection
  list `fred+orig\[0..$(3)\]` N.B.: The sub-bricks are output in the
  order specified, which may not be the order in the original datasets.
  For example, using `fred+orig\[0..$(2),1..$(2)\]` will cause the
  sub-bricks in fred+orig to be output into the new dataset in an
  interleaved fashion. Using `fred+orig\[$..0\]` will reverse the order
  of the sub-bricks in the output. N.B.: Bucket datasets have multiple
  sub-bricks, but do NOT have a time dimension. You can input sub-bricks
  from a 3D+time dataset into a bucket dataset. You can use the '3dinfo'
  program to see how many sub-bricks a 3D+time or a bucket dataset
  contains. N.B.: In non-bucket functional datasets (like the 'fico'
  datasets output by FIM, or the 'fitt' datasets output by 3dttest),
  sub-brick `\[0\]` is the 'intensity' and sub-brick \[1\] is the
  statistical parameter used as a threshold. Thus, to create a bucket
  dataset using the intensity from dataset A and the threshold from
  dataset B, and calling the output dataset C, you would type:: 3dbucket
  -prefix C -fbuc 'A+orig\[0\]' -fbuc 'B+orig\[1\] **Required.**

- args:

  Character. Additional parameters to the command

- out_file:

  Character; file path

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
