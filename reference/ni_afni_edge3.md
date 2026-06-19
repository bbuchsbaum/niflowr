# AFNI Edge3

Does 3D Edge detection using the library 3DEdge

## Usage

``` r
ni_afni_edge3(
  in_file,
  args = NULL,
  datum = NULL,
  fscale = NULL,
  gscale = NULL,
  nscale = NULL,
  out_file = NULL,
  scale_floats = NULL,
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

  Character; file path. input file to 3dedge3 **Required.**

- args:

  Character. Additional parameters to the command

- datum:

  Character; one of: "byte", "short", "float". specify data type for
  output. Valid types are 'byte', 'short' and 'float'.

- fscale:

  Logical. Force scaling of the output to the maximum integer range.

- gscale:

  Logical. Same as '-fscale', but also forces each output sub-brick to
  to get the same scaling factor.

- nscale:

  Logical. Don't do any scaling on output to byte or short datasets.

- out_file:

  Character; file path. output image file name

- scale_floats:

  Numeric. Multiply input by VAL, but only if the input datum is float.
  This is needed when the input dataset has a small range, like 0 to 2.0
  for instance. With such a range, very few edges are detected due to
  what I suspect to be truncation problems. Multiplying such a dataset
  by 10000 fixes the problem and the scaling is undone at the output.

- verbose:

  Logical. Print out some information along the way.

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
