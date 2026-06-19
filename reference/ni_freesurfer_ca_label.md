# FREESURFER CALabel

Label subcortical structures based in GCA model.

## Usage

``` r
ni_freesurfer_ca_label(
  in_file,
  out_file,
  template,
  transform,
  align = NULL,
  args = NULL,
  aseg = NULL,
  in_vol = NULL,
  intensities = NULL,
  label = NULL,
  no_big_ventricles = NULL,
  prior = NULL,
  relabel_unlikely = NULL,
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

  Character; file path. Input volume for CALabel **Required.**

- out_file:

  Character; file path. Output file for CALabel **Required.**

- template:

  Character; file path. Input template for CALabel **Required.**

- transform:

  Character; file path. Input transform for CALabel **Required.**

- align:

  Logical. Align CALabel

- args:

  Character. Additional parameters to the command

- aseg:

  Character; file path. Undocumented flag. Autorecon3 uses
  ../mri/aseg.presurf.mgz as input file

- in_vol:

  Character; file path. set input volume

- intensities:

  Character; file path. input label intensities file(used in
  longitudinal processing)

- label:

  Character; file path. Undocumented flag. Autorecon3 uses
  ../label/{hemisphere}.cortex.label as input file

- no_big_ventricles:

  Logical. No big ventricles

- prior:

  Numeric. Prior for CALabel

- relabel_unlikely:

  Character or numeric vector. Reclassify voxels at least some std devs
  from the mean using some size Gaussian window

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
