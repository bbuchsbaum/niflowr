# FREESURFER LTAConvert

Convert different transformation formats.

## Usage

``` r
ni_freesurfer_lta_convert(
  in_fsl,
  in_itk,
  in_lta,
  in_mni,
  in_niftyreg,
  in_reg,
  args = NULL,
  invert = NULL,
  ltavox2vox = NULL,
  out_fsl = NULL,
  out_itk = NULL,
  out_lta = NULL,
  out_mni = NULL,
  out_reg = NULL,
  source_file = NULL,
  target_conform = NULL,
  target_file = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- in_fsl:

  Character; file path. input transform of FSL type **Required.**

- in_itk:

  Character; file path. input transform of ITK type **Required.**

- in_lta:

  Character or numeric vector. input transform of LTA type **Required.**

- in_mni:

  Character; file path. input transform of MNI/XFM type **Required.**

- in_niftyreg:

  Character; file path. input transform of Nifty Reg type (inverse
  RAS2RAS) **Required.**

- in_reg:

  Character; file path. input transform of TK REG type (deprecated
  format) **Required.**

- args:

  Character. Additional parameters to the command

- invert:

  Logical

- ltavox2vox:

  Logical

- out_fsl:

  Character or numeric vector. output transform in FSL format

- out_itk:

  Character or numeric vector. output transform in ITK format

- out_lta:

  Character or numeric vector. output linear transform (LTA Freesurfer
  format)

- out_mni:

  Character or numeric vector. output transform in MNI/XFM format

- out_reg:

  Character or numeric vector. output transform in reg dat format

- source_file:

  Character; file path

- target_conform:

  Logical

- target_file:

  Character; file path

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
