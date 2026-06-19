# FREESURFER ParseDICOMDir

Uses mri_parse_sdcmdir to get information from dicom directories

## Usage

``` r
ni_freesurfer_parse_dicom_dir(
  dicom_dir,
  args = NULL,
  dicom_info_file = "dicominfo.txt",
  sortbyrun = NULL,
  summarize = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- dicom_dir:

  Character; directory path. path to siemens dicom directory
  **Required.**

- args:

  Character. Additional parameters to the command

- dicom_info_file:

  Character; file path. file to which results are written

- sortbyrun:

  Logical. assign run numbers

- summarize:

  Logical. only print out info for run leaders

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
