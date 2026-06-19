# AFNI AFNItoNIFTI

Converts AFNI format files to NIFTI format. This can also convert 2D or

## Usage

``` r
ni_afni_afn_ito_nifti(
  in_file,
  args = NULL,
  denote = NULL,
  newid = NULL,
  oldid = NULL,
  out_file = NULL,
  pure = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- in_file:

  Character; file path. input file to 3dAFNItoNIFTI **Required.**

- args:

  Character. Additional parameters to the command

- denote:

  Logical. When writing the AFNI extension field, remove text notes that
  might contain subject identifying information.

- newid:

  Logical. Give the new dataset a new AFNI ID code, to distinguish it
  from the input dataset.

- oldid:

  Logical. Give the new dataset the input datasets AFNI ID code.

- out_file:

  Character; file path. output image file name

- pure:

  Logical. Do NOT write an AFNI extension field into the output file.
  Only use this option if needed. You can also use the 'nifti_tool'
  program to strip extensions from a file.

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
