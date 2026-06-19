# dcm2niix Convert

Convert DICOM folders to NIfTI (and optional BIDS sidecars) using
dcm2niix.

## Usage

``` r
ni_dcm2niix_convert(
  in_folder,
  args = NULL,
  compression_level = NULL,
  adjacent = NULL,
  bids_sidecar = NULL,
  anon_bids = NULL,
  bids_subject = NULL,
  bids_session = NULL,
  comment = NULL,
  depth = NULL,
  export_format = NULL,
  filename = NULL,
  ignore_derived = NULL,
  lossless_scale = NULL,
  merge_2d_slices = NULL,
  series_crc = NULL,
  out_dir = NULL,
  philips_float = NULL,
  search_only = NULL,
  rename = NULL,
  single_file = NULL,
  verbose = NULL,
  write_conflicts = NULL,
  crop = NULL,
  compression = NULL,
  big_endian = NULL,
  progress = NULL,
  ignore_trigger_times = NULL,
  terse = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- in_folder:

  Character; directory path. Folder with DICOM images to convert.
  **Required.**

- args:

  Character. Additional parameters to the command

- compression_level:

  Integer. Gzip compression level (1=fastest..9=smallest).

- adjacent:

  Character; one of: "n", "y". Assume adjacent DICOMs from a series are
  stored in the same folder (n/y).

- bids_sidecar:

  Character; one of: "y", "n", "o". BIDS sidecar mode (y/n/o; o=JSON
  only, no NIfTI).

- anon_bids:

  Character; one of: "y", "n". Anonymize BIDS sidecars (y/n).

- bids_subject:

  Character. Set BIDS subject label (equivalent to -bi).

- bids_session:

  Character. Set BIDS session label (equivalent to -bv).

- comment:

  Character. Comment stored in NIfTI aux_file (up to 24 characters).

- depth:

  Integer. Directory search depth for recursive discovery (0..9).

- export_format:

  Character; one of: "n", "y", "o", "j", "b". Export format (n=NIfTI,
  y=NRRD, o=MGH, j=JNIfTI, b=BJNIfTI).

- filename:

  Character. Output filename template (e.g. %p\_%t\_%s).

- ignore_derived:

  Character; one of: "y", "n". Ignore derived/localizer/2D images (y/n).

- lossless_scale:

  Character; one of: "y", "n", "o". Lossless scaling for 16-bit integers
  (y/n/o).

- merge_2d_slices:

  Character; one of: "0", "1", "2", "n", "y". Merge slices from same
  series despite differing properties (0/1/2 or n/y).

- series_crc:

  Character or numeric vector. Only convert specific series CRC numbers;
  repeatable.

- out_dir:

  Character; directory path. Output directory (omit to write into input
  directory).

- philips_float:

  Character; one of: "y", "n". Use Philips precise floating-point
  scaling (y/n).

- search_only:

  Character; one of: "y", "l", "n". Directory search mode (y=count,
  l=list, n=off).

- rename:

  Character; one of: "y", "n". Rename DICOMs instead of converting
  (y/n).

- single_file:

  Character; one of: "y", "n". Single-file mode: convert only one file
  in folder (y/n).

- verbose:

  Character; one of: "0", "1", "2", "n", "y". Verbosity (0/1/2 or n/y).

- write_conflicts:

  Character; one of: "0", "1", "2". Name conflict behavior (0=skip,
  1=overwrite, 2=add suffix).

- crop:

  Character; one of: "y", "n", "i". Crop 3D acquisitions (y/n/i where
  i=ignore crop and rotate).

- compression:

  Character; one of: "y", "o", "i", "n", "3". Compression mode
  (y/o/i/n/3).

- big_endian:

  Character; one of: "y", "n", "o". Output byte order (y=big-endian,
  n=little-endian, o=native/optimal).

- progress:

  Character; one of: "y", "n". Progress reporting (y/n).

- ignore_trigger_times:

  Logical. Ignore trigger time DICOM fields (0018,1060 and 0020,9153).

- terse:

  Logical. Omit filename postfixes (can increase overwrite risk).

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
