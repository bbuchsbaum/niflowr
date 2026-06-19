# FSL EpiReg

Runs FSL epi_reg script for simultaneous coregistration and fieldmap

## Usage

``` r
ni_fsl_epi_reg(
  epi,
  t1_brain,
  t1_head,
  args = NULL,
  echospacing = NULL,
  fmap = NULL,
  fmapmag = NULL,
  fmapmagbrain = NULL,
  no_clean = TRUE,
  no_fmapreg = NULL,
  out_base = "epi2struct",
  pedir = NULL,
  weight_image = NULL,
  wmseg = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- epi:

  Character; file path. EPI image **Required.**

- t1_brain:

  Character; file path. brain extracted T1 image **Required.**

- t1_head:

  Character; file path. wholehead T1 image **Required.**

- args:

  Character. Additional parameters to the command

- echospacing:

  Numeric. Effective EPI echo spacing (sometimes called dwell time) - in
  seconds

- fmap:

  Character; file path. fieldmap image (in rad/s)

- fmapmag:

  Character; file path. fieldmap magnitude image - wholehead

- fmapmagbrain:

  Character; file path. fieldmap magnitude image - brain extracted

- no_clean:

  Logical. do not clean up intermediate files

- no_fmapreg:

  Logical. do not perform registration of fmap to T1 (use if fmap
  already registered)

- out_base:

  Character. output base name

- pedir:

  Character; one of: "x", "y", "z", "-x", "-y", "-z". phase encoding
  direction, dir = x/y/z/-x/-y/-z

- weight_image:

  Character; file path. weighting image (in T1 space)

- wmseg:

  Character; file path. white matter segmentation of T1 image, has to be
  named like the t1brain and end on \_wmseg

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
