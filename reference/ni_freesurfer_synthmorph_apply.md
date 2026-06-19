# FreeSurfer SynthMorph Apply

Apply a SynthMorph transform to resample a moving image into the fixed
image's space. Provided by 'mri_synthmorph apply' in FreeSurfer 7.4+ and
the freesurfer/synthmorph Docker image.

## Usage

``` r
ni_freesurfer_synthmorph_apply(
  trans,
  moving,
  moved,
  method = NULL,
  out_type = NULL,
  header_only = NULL,
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

- trans:

  Character; file path. Transform produced by SynthMorph register
  **Required.**

- moving:

  Character; file path. Moving image to resample through the transform
  **Required.**

- moved:

  Character; file path. Output moved image **Required.**

- method:

  Character; one of: "linear", "nearest". Interpolation method

- out_type:

  Character; one of: "uchar", "short", "float". Output voxel type

- header_only:

  Logical. Adjust voxel-to-world matrix only (no resampling)

- args:

  Character. Additional parameters passed verbatim to mri_synthmorph
  apply

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
