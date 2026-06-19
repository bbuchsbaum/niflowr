# FREESURFER UnpackSDICOMDir

Use unpacksdcmdir to convert dicom files

## Usage

``` r
ni_freesurfer_unpack_sdicom_dir(
  config,
  run_info,
  seq_config,
  source_dir,
  args = NULL,
  dir_structure = NULL,
  log_file = NULL,
  no_info_dump = NULL,
  no_unpack_err = NULL,
  output_dir = NULL,
  scan_only = NULL,
  spm_zeropad = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- config:

  Character; file path. specify unpacking rules in file **Required.**

- run_info:

  Character or numeric vector. runno subdir format name : spec unpacking
  rules on cmdline **Required.**

- seq_config:

  Character; file path. specify unpacking rules based on sequence
  **Required.**

- source_dir:

  Character; directory path. directory with the DICOM files
  **Required.**

- args:

  Character. Additional parameters to the command

- dir_structure:

  Character; one of: "fsfast", "generic". unpack to specified directory
  structures

- log_file:

  Character; file path. explicitly set log file

- no_info_dump:

  Logical. do not create infodump file

- no_unpack_err:

  Logical. do not try to unpack runs with errors

- output_dir:

  Character; directory path. top directory into which the files will be
  unpacked

- scan_only:

  Character; file path. only scan the directory and put result in file

- spm_zeropad:

  Integer. set frame number zero padding width for SPM

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
