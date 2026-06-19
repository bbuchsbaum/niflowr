# FREESURFER CARegister

Generates a multi-dimensional talairach transform from a gca file and
talairach.lta file

## Usage

``` r
ni_freesurfer_ca_register(
  in_file,
  A = NULL,
  align = NULL,
  args = NULL,
  invert_and_save = NULL,
  l_files = NULL,
  levels = NULL,
  mask = NULL,
  no_big_ventricles = NULL,
  out_file = NULL,
  template = NULL,
  transform = NULL,
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

  Character; file path. The input volume for CARegister **Required.**

- A:

  Integer. undocumented flag used in longitudinal processing

- align:

  Character. Specifies when to perform alignment

- args:

  Character. Additional parameters to the command

- invert_and_save:

  Logical. Invert and save the .m3z multi-dimensional talaraich
  transform to x, y, and z .mgz files

- l_files:

  Character or numeric vector. undocumented flag used in longitudinal
  processing

- levels:

  Integer. defines how many surrounding voxels will be used in
  interpolations, default is 6

- mask:

  Character; file path. Specifies volume to use as mask

- no_big_ventricles:

  Logical. No big ventricles

- out_file:

  Character; file path. The output volume for CARegister

- template:

  Character; file path. The template file in gca format

- transform:

  Character; file path. Specifies transform in lta format

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
