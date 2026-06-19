# FSL FAST

FSL FAST wrapper for segmentation and bias correction

## Usage

``` r
ni_fsl_fast(
  in_files,
  args = NULL,
  bias_iters = NULL,
  bias_lowpass = NULL,
  hyper = NULL,
  img_type = NULL,
  init_seg_smooth = NULL,
  init_transform = NULL,
  iters_afterbias = NULL,
  manual_seg = NULL,
  mixel_smooth = NULL,
  no_bias = NULL,
  no_pve = NULL,
  number_classes = NULL,
  other_priors = NULL,
  out_basename = NULL,
  output_biascorrected = NULL,
  output_biasfield = NULL,
  probability_maps = NULL,
  segment_iters = NULL,
  segments = NULL,
  use_priors = NULL,
  verbose = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- in_files:

  Character or numeric vector. image, or multi-channel set of images, to
  be segmented **Required.**

- args:

  Character. Additional parameters to the command

- bias_iters:

  Character. number of main-loop iterations during bias-field removal

- bias_lowpass:

  Character. bias field smoothing extent (FWHM) in mm

- hyper:

  Character. segmentation spatial smoothness

- img_type:

  Character; one of: "1", "2", "3". int specifying type of image: (1 =
  T1, 2 = T2, 3 = PD)

- init_seg_smooth:

  Character. initial segmentation spatial smoothness (during bias field
  estimation)

- init_transform:

  Character; file path. \<standard2input.mat\> initialise using priors

- iters_afterbias:

  Character. number of main-loop iterations after bias-field removal

- manual_seg:

  Character; file path. Filename containing intensities

- mixel_smooth:

  Character. spatial smoothness for mixeltype

- no_bias:

  Logical. do not remove bias field

- no_pve:

  Logical. turn off PVE (partial volume estimation)

- number_classes:

  Character. number of tissue-type classes

- other_priors:

  Character or numeric vector. alternative prior images

- out_basename:

  Character; file path. base name of output files

- output_biascorrected:

  Logical. output restored image (bias-corrected image)

- output_biasfield:

  Logical. output estimated bias field

- probability_maps:

  Logical. outputs individual probability maps

- segment_iters:

  Character. number of segmentation-initialisation iterations

- segments:

  Logical. outputs a separate binary image for each tissue type

- use_priors:

  Logical. use priors throughout

- verbose:

  Logical. switch on diagnostic messages

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
