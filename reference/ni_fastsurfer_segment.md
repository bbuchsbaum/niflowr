# FastSurfer Segment

FastSurfer segmentation-only mode: fast brain segmentation (~5 min)
without surface reconstruction

## Usage

``` r
ni_fastsurfer_segment(
  t1,
  sid,
  sd,
  device = NULL,
  threads = NULL,
  vox_size = NULL,
  no_asegdkt = NULL,
  no_cereb = NULL,
  no_hypothal = NULL,
  no_cc = NULL,
  no_biasfield = NULL,
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

- device:

  Character; one of: "auto", "cpu", "cuda", "mps". Device for DNN
  inference

- threads:

  Integer. Number of parallel threads

- vox_size:

  Character. Voxel size for processing (0.7-1.0 or 'min')

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
