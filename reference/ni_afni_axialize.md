# AFNI Axialize

Read in a dataset and write it out as a new dataset

## Usage

``` r
ni_afni_axialize(
  in_file,
  args = NULL,
  axial = NULL,
  coronal = NULL,
  orientation = NULL,
  out_file = NULL,
  sagittal = NULL,
  verb = NULL,
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

  Character; file path. input file to 3daxialize **Required.**

- args:

  Character. Additional parameters to the command

- axial:

  Logical. Do axial slice order \[-orient RAI\]This is the default AFNI
  axial order, andis the one currently required by thevolume rendering
  plugin; this is alsothe default orientation output by thisprogram
  (hence the program's name).

- coronal:

  Logical. Do coronal slice order \[-orient RSA\]

- orientation:

  Character. new orientation code

- out_file:

  Character; file path. output image file name

- sagittal:

  Logical. Do sagittal slice order \[-orient ASL\]

- verb:

  Logical. Print out a progerss report

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
