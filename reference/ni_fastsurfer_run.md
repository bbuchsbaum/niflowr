# FastSurfer Run

FastSurfer: GPU-accelerated brain segmentation and cortical surface
reconstruction

## Usage

``` r
ni_fastsurfer_run(
  t1,
  sid,
  sd,
  fs_license = NULL,
  t2 = NULL,
  seg_only = NULL,
  surf_only = NULL,
  device = NULL,
  viewagg_device = NULL,
  threads = NULL,
  vox_size = NULL,
  three_t = NULL,
  no_asegdkt = NULL,
  no_cereb = NULL,
  no_hypothal = NULL,
  no_cc = NULL,
  no_biasfield = NULL,
  no_surfreg = NULL,
  no_fs_t1 = NULL,
  py = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- t1:

  Character; file path. Input T1-weighted image **Required.**

- sid:

  Character. Subject ID **Required.**

- sd:

  Character; directory path. Subjects directory (output root)
  **Required.**

- fs_license:

  Character; file path. FreeSurfer license file

- t2:

  Character; file path. Optional T2-weighted image for hypothalamus
  segmentation

- seg_only:

  Logical. Run segmentation only (skip surface reconstruction, ~5 min)

- surf_only:

  Logical. Run surface reconstruction only (requires prior segmentation)

- device:

  Character; one of: "auto", "cpu", "cuda", "mps". Device for DNN
  inference

- viewagg_device:

  Character; one of: "cpu", "cuda". Device for view aggregation (use cpu
  to reduce VRAM usage)

- threads:

  Integer. Number of parallel threads

- vox_size:

  Character. Voxel size for processing (0.7-1.0 or 'min')

- three_t:

  Logical. Use the 3T atlas for talairach registration

- no_asegdkt:

  Logical. Skip whole-brain DKT segmentation

- no_cereb:

  Logical. Skip cerebellum segmentation

- no_hypothal:

  Logical. Skip hypothalamus segmentation

- no_cc:

  Logical. Skip corpus callosum segmentation

- no_biasfield:

  Logical. Skip bias field correction

- no_surfreg:

  Logical. Skip surface registration (spherical registration)

- no_fs_t1:

  Logical. Skip T1.mgz generation from conformed image

- py:

  Character. Python command to use (override default)

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
