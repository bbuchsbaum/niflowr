# FREESURFER FixTopology

This program computes a mapping from the unit sphere onto the surface

## Usage

``` r
ni_freesurfer_fix_topology(
  copy_inputs,
  hemisphere,
  in_brain,
  in_inflated,
  in_orig,
  in_wm,
  subject_id,
  args = NULL,
  ga = NULL,
  mgz = NULL,
  seed = NULL,
  sphere = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- copy_inputs:

  Logical. If running as a node, set this to True otherwise, the
  topology fixing will be done in place. **Required.**

- hemisphere:

  Character. Hemisphere being processed **Required.**

- in_brain:

  Character; file path. Implicit input brain.mgz **Required.**

- in_inflated:

  Character; file path. Undocumented input file .inflated **Required.**

- in_orig:

  Character; file path. Undocumented input file .orig **Required.**

- in_wm:

  Character; file path. Implicit input wm.mgz **Required.**

- subject_id:

  Character. Subject being processed **Required.**

- args:

  Character. Additional parameters to the command

- ga:

  Logical. No documentation. Direct questions to
  analysis-bugs@nmr.mgh.harvard.edu

- mgz:

  Logical. No documentation. Direct questions to
  analysis-bugs@nmr.mgh.harvard.edu

- seed:

  Integer. Seed for setting random number generator

- sphere:

  Character; file path. Sphere input file

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
