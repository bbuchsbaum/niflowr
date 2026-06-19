# FREESURFER Tkregister2

Examples

## Usage

``` r
ni_freesurfer_tkregister2(
  moving_image,
  reg_file,
  args = NULL,
  fsl_in_matrix = NULL,
  fsl_out = NULL,
  fstal = NULL,
  fstarg = NULL,
  invert_lta_out = NULL,
  lta_in = NULL,
  lta_out = NULL,
  movscale = NULL,
  noedit = TRUE,
  reg_header = NULL,
  subject_id = NULL,
  target_image = NULL,
  xfm = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- moving_image:

  Character; file path. moving volume **Required.**

- reg_file:

  Character; file path. freesurfer-style registration file **Required.**

- args:

  Character. Additional parameters to the command

- fsl_in_matrix:

  Character; file path. fsl-style registration input matrix

- fsl_out:

  Character or numeric vector. compute an FSL-compatible resgitration
  matrix

- fstal:

  Logical. set mov to be tal and reg to be tal xfm

- fstarg:

  Logical. use subject's T1 as reference

- invert_lta_out:

  Logical. Invert input LTA before applying

- lta_in:

  Character; file path. use a matrix in MNI coordinates as initial
  registration

- lta_out:

  Character or numeric vector. output registration file (LTA format)

- movscale:

  Numeric. adjust registration matrix to scale mov

- noedit:

  Logical. do not open edit window (exit)

- reg_header:

  Logical. compute registration from headers

- subject_id:

  Character. freesurfer subject ID

- target_image:

  Character; file path. target volume

- xfm:

  Character; file path. use a matrix in MNI coordinates as initial
  registration

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
