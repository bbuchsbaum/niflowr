# FSL DTIFit

Use FSL dtifit command for fitting a diffusion tensor model at each

## Usage

``` r
ni_fsl_dti_fit(
  bvals,
  bvecs,
  dwi,
  mask,
  args = NULL,
  base_name = "dtifit_",
  cni = NULL,
  gradnonlin = NULL,
  little_bit = NULL,
  max_x = NULL,
  max_y = NULL,
  max_z = NULL,
  min_x = NULL,
  min_y = NULL,
  min_z = NULL,
  save_tensor = NULL,
  sse = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- bvals:

  Character; file path. b values file **Required.**

- bvecs:

  Character; file path. b vectors file **Required.**

- dwi:

  Character; file path. diffusion weighted image data file **Required.**

- mask:

  Character; file path. bet binary mask file **Required.**

- args:

  Character. Additional parameters to the command

- base_name:

  Character. base_name that all output files will start with

- cni:

  Character; file path. input counfound regressors

- gradnonlin:

  Character; file path. gradient non linearities

- little_bit:

  Logical. only process small area of brain

- max_x:

  Integer. max x

- max_y:

  Integer. max y

- max_z:

  Integer. max z

- min_x:

  Integer. min x

- min_y:

  Integer. min y

- min_z:

  Integer. min z

- save_tensor:

  Logical. save the elements of the tensor

- sse:

  Logical. output sum of squared errors

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
