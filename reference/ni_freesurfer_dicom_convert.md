# FREESURFER DICOMConvert

use fs mri_convert to convert dicom files

## Usage

``` r
ni_freesurfer_dicom_convert(
  base_output_dir,
  dicom_dir,
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

- base_output_dir:

  Character; directory path. directory in which subject directories are
  created **Required.**

- dicom_dir:

  Character; directory path. dicom directory from which to convert dicom
  files **Required.**

- args:

  Character. Additional parameters to the command

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
