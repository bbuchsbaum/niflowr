# AFNI Volreg

Register input volumes to a base volume using AFNI 3dvolreg command

## Usage

``` r
ni_afni_volreg(
  in_file,
  args = NULL,
  basefile = NULL,
  copyorigin = NULL,
  in_weight_volume = NULL,
  interp = NULL,
  md1d_file = NULL,
  oned_file = NULL,
  oned_matrix_save = NULL,
  out_file = NULL,
  timeshift = NULL,
  verbose = NULL,
  zpad = NULL,
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

  Character; file path. input file to 3dvolreg **Required.**

- args:

  Character. Additional parameters to the command

- basefile:

  Character; file path. base file for registration

- copyorigin:

  Logical. copy base file origin coords to output

- in_weight_volume:

  Character or numeric vector. weights for each voxel specified by a
  file with an optional volume number (defaults to 0)

- interp:

  Character; one of: "Fourier", "cubic", "heptic", "quintic", "linear".
  spatial interpolation methods \[default = heptic\]

- md1d_file:

  Character; file path. max displacement output file

- oned_file:

  Character; file path. 1D movement parameters output file

- oned_matrix_save:

  Character; file path. Save the matrix transformation

- out_file:

  Character; file path. output image file name

- timeshift:

  Logical. time shift to mean slice time offset

- verbose:

  Logical. more detailed description of the process

- zpad:

  Integer. Zeropad around the edges by 'n' voxels during rotations

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
