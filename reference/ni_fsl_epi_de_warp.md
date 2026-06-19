# FSL EPIDeWarp

Wraps the unwarping script \`epidewarp.fsl

## Usage

``` r
ni_fsl_epi_de_warp(
  dph_file,
  mag_file,
  args = NULL,
  cleanup = NULL,
  epi_file = NULL,
  epidw = NULL,
  esp = 0.58,
  exf_file = NULL,
  exfdw = NULL,
  nocleanup = TRUE,
  sigma = 2,
  tediff = 2.46,
  tmpdir = NULL,
  vsm = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- dph_file:

  Character; file path. Phase file assumed to be scaled from 0 to 4095
  **Required.**

- mag_file:

  Character; file path. Magnitude file **Required.**

- args:

  Character. Additional parameters to the command

- cleanup:

  Logical. cleanup

- epi_file:

  Character; file path. EPI volume to unwarp

- epidw:

  Character. dewarped epi volume

- esp:

  Numeric. EPI echo spacing

- exf_file:

  Character; file path. example func volume (or use epi)

- exfdw:

  Character. dewarped example func volume

- nocleanup:

  Logical. no cleanup

- sigma:

  Integer. 2D spatial gaussing smoothing stdev (default = 2mm)

- tediff:

  Numeric. difference in B0 field map TEs

- tmpdir:

  Character. tmpdir

- vsm:

  Character. voxel shift map

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
