# AFNI BlurInMask

Blurs a dataset spatially inside a mask. That's all. Experimental.

## Usage

``` r
ni_afni_blur_in_mask(
  fwhm,
  in_file,
  args = NULL,
  automask = NULL,
  float_out = NULL,
  mask = NULL,
  multimask = NULL,
  options = NULL,
  out_file = NULL,
  preserve = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- fwhm:

  Numeric. fwhm kernel size **Required.**

- in_file:

  Character; file path. input file to 3dSkullStrip **Required.**

- args:

  Character. Additional parameters to the command

- automask:

  Logical. Create an automask from the input dataset.

- float_out:

  Logical. Save dataset as floats, no matter what the input data type
  is.

- mask:

  Character; file path. Mask dataset, if desired. Blurring will occur
  only within the mask. Voxels NOT in the mask will be set to zero in
  the output.

- multimask:

  Character; file path. Multi-mask dataset – each distinct nonzero value
  in dataset will be treated as a separate mask for blurring purposes.

- options:

  Character. options

- out_file:

  Character; file path. output to the file

- preserve:

  Logical. Normally, voxels not in the mask will be set to zero in the
  output. If you want the original values in the dataset to be preserved
  in the output, use this option.

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
