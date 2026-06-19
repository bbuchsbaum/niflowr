# FREESURFER MRIsConvert

Uses Freesurfer's mris_convert to convert surface files to various
formats

## Usage

``` r
ni_freesurfer_mr_is_convert(
  in_file,
  out_datatype,
  out_file,
  annot_file = NULL,
  args = NULL,
  dataarray_num = NULL,
  functional_file = NULL,
  label_file = NULL,
  labelstats_outfile = NULL,
  normal = NULL,
  origname = NULL,
  parcstats_file = NULL,
  patch = NULL,
  rescale = NULL,
  scalarcurv_file = NULL,
  scale = NULL,
  talairachxfm_subjid = NULL,
  to_scanner = NULL,
  to_tkr = NULL,
  vertex = NULL,
  xyz_ascii = NULL,
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

  Character; file path. File to read/convert **Required.**

- out_datatype:

  Character; one of: "asc", "ico", "tri", "stl", "vtk", "gii", "mgh",
  "mgz". These file formats are supported: ASCII: .ascICO: .ico, .tri
  GEO: .geo STL: .stl VTK: .vtk GIFTI: .gii MGH surface-encoded
  'volume': .mgh, .mgz **Required.**

- out_file:

  Character; file path. output filename or True to generate one
  **Required.**

- annot_file:

  Character; file path. input is annotation or gifti label data

- args:

  Character. Additional parameters to the command

- dataarray_num:

  Integer. if input is gifti, 'num' specifies which data array to use

- functional_file:

  Character; file path. input is functional time-series or other
  multi-frame data (must specify surface)

- label_file:

  Character; file path. infile is .label file, label is name of this
  label

- labelstats_outfile:

  Character; file path. outfile is name of gifti file to which label
  stats will be written

- normal:

  Logical. output is an ascii file where vertex data

- origname:

  Character. read orig positions

- parcstats_file:

  Character; file path. infile is name of text file containing label/val
  pairs

- patch:

  Logical. input is a patch, not a full surface

- rescale:

  Logical. rescale vertex xyz so total area is same as group average

- scalarcurv_file:

  Character; file path. input is scalar curv overlay file (must still
  specify surface)

- scale:

  Numeric. scale vertex xyz by scale

- talairachxfm_subjid:

  Character. apply talairach xfm of subject to vertex xyz

- to_scanner:

  Logical. convert coordinates from native FS (tkr) coords to scanner
  coords

- to_tkr:

  Logical. convert coordinates from scanner coords to native FS (tkr)
  coords

- vertex:

  Logical. Writes out neighbors of a vertex in each row

- xyz_ascii:

  Logical. Print only surface xyz to ascii file

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
