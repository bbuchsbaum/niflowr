# FreeSurfer SynthMorph Register

SynthMorph image registration: deep-learning, contrast-agnostic affine
and deformable registration. Bundled with FreeSurfer 7.4+ as
'mri_synthmorph register' and distributed standalone as the
freesurfer/synthmorph Docker image.

## Usage

``` r
ni_freesurfer_synthmorph_register(
  moving,
  fixed,
  out_moving = NULL,
  out_fixed = NULL,
  trans = NULL,
  inverse = NULL,
  header_only = NULL,
  model = NULL,
  init = NULL,
  extent = NULL,
  threads = NULL,
  gpu = NULL,
  resample = NULL,
  args = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- moving:

  Character; file path. Moving image to register to the fixed image
  **Required.**

- fixed:

  Character; file path. Fixed (target) image **Required.**

- out_moving:

  Character; file path. Save moving image resampled into fixed space

- out_fixed:

  Character; file path. Save fixed image resampled into moving space

- trans:

  Character; file path. Save transform mapping moving to fixed

- inverse:

  Character; file path. Save inverse transform mapping fixed to moving

- header_only:

  Logical. Adjust voxel-to-world matrix only (no resampling)

- model:

  Character; one of: "joint", "deform", "affine", "rigid". Registration
  model

- init:

  Character; file path. Initial affine transform (LTA, mat, or txt)

- extent:

  Integer. Registration FOV side length in mm (default 256)

- threads:

  Integer. Number of CPU threads

- gpu:

  Logical. Use the GPU for inference

- resample:

  Logical. Resample fixed image to moving space

- args:

  Character. Additional parameters passed verbatim to mri_synthmorph
  register

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
