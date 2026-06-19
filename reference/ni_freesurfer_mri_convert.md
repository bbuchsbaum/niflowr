# FREESURFER MRIConvert

use fs mri_convert to manipulate files

## Usage

``` r
ni_freesurfer_mri_convert(
  in_file,
  apply_inv_transform = NULL,
  apply_transform = NULL,
  args = NULL,
  ascii = NULL,
  autoalign_matrix = NULL,
  color_file = NULL,
  conform = NULL,
  conform_min = NULL,
  conform_size = NULL,
  crop_center = NULL,
  crop_gdf = NULL,
  crop_size = NULL,
  cut_ends = NULL,
  cw256 = NULL,
  devolve_transform = NULL,
  drop_n = NULL,
  fill_parcellation = NULL,
  force_ras = NULL,
  frame = NULL,
  frame_subsample = NULL,
  fwhm = NULL,
  in_center = NULL,
  in_i_dir = NULL,
  in_i_size = NULL,
  in_info = NULL,
  in_j_dir = NULL,
  in_j_size = NULL,
  in_k_dir = NULL,
  in_k_size = NULL,
  in_like = NULL,
  in_matrix = NULL,
  in_orientation = NULL,
  in_scale = NULL,
  in_stats = NULL,
  in_type = NULL,
  invert_contrast = NULL,
  midframe = NULL,
  no_change = NULL,
  no_scale = NULL,
  no_translate = NULL,
  no_write = NULL,
  out_center = NULL,
  out_datatype = NULL,
  out_file = NULL,
  out_i_count = NULL,
  out_i_dir = NULL,
  out_i_size = NULL,
  out_info = NULL,
  out_j_count = NULL,
  out_j_dir = NULL,
  out_j_size = NULL,
  out_k_count = NULL,
  out_k_dir = NULL,
  out_k_size = NULL,
  out_matrix = NULL,
  out_orientation = NULL,
  out_scale = NULL,
  out_stats = NULL,
  out_type = NULL,
  parse_only = NULL,
  read_only = NULL,
  reorder = NULL,
  resample_type = NULL,
  reslice_like = NULL,
  sdcm_list = NULL,
  skip_n = NULL,
  slice_bias = NULL,
  slice_crop = NULL,
  slice_reverse = NULL,
  smooth_parcellation = NULL,
  sphinx = NULL,
  split = NULL,
  status_file = NULL,
  subject_name = NULL,
  te = NULL,
  template_info = NULL,
  template_type = NULL,
  ti = NULL,
  tr = NULL,
  unwarp_gradient = NULL,
  vox_size = NULL,
  zero_ge_z_offset = NULL,
  zero_outlines = NULL,
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

- apply_inv_transform:

  Character; file path. apply inverse transformation xfm file

- apply_transform:

  Character; file path. apply xfm file

- args:

  Character. Additional parameters to the command

- ascii:

  Logical. save output as ascii col\>row\>slice\>frame

- autoalign_matrix:

  Character; file path. text file with autoalign matrix

- color_file:

  Character; file path. color file

- conform:

  Logical. conform to 1mm voxel size in coronal slice direction with
  256^3 or more

- conform_min:

  Logical. conform to smallest size

- conform_size:

  Numeric. conform to size_in_mm

- crop_center:

  Character or numeric vector. crop to 256 around center (x, y, z)

- crop_gdf:

  Logical. apply GDF cropping

- crop_size:

  Character or numeric vector. crop to size \<dx, dy, dz\>

- cut_ends:

  Integer. remove ncut slices from the ends

- cw256:

  Logical. confrom to dimensions of 256^3

- devolve_transform:

  Character. subject id

- drop_n:

  Integer. drop the last n frames

- fill_parcellation:

  Logical. fill parcellation

- force_ras:

  Logical. use default when orientation info absent

- frame:

  Integer. keep only 0-based frame number

- frame_subsample:

  Character or numeric vector. start delta end : frame subsampling (end
  = -1 for end)

- fwhm:

  Numeric. smooth input volume by fwhm mm

- in_center:

  Character or numeric vector.

- in_i_dir:

  Character or numeric vector.

- in_i_size:

  Integer. input i size

- in_info:

  Logical. display input info

- in_j_dir:

  Character or numeric vector.

- in_j_size:

  Integer. input j size

- in_k_dir:

  Character or numeric vector.

- in_k_size:

  Integer. input k size

- in_like:

  Character; file path. input looks like

- in_matrix:

  Logical. display input matrix

- in_orientation:

  Character; one of: "LAI", "LIA", "ALI", "AIL", "ILA", "IAL", "LAS",
  "LSA", "ALS", "ASL", "SLA", "SAL", "LPI", "LIP", "PLI", "PIL", "ILP",
  "IPL", "LPS", "LSP", "PLS", "PSL", "SLP", "SPL", "RAI", "RIA", "ARI",
  "AIR", "IRA", "IAR", "RAS", "RSA", "ARS", "ASR", "SRA", "SAR", "RPI",
  "RIP", "PRI", "PIR", "IRP", "IPR", "RPS", "RSP", "PRS", "PSR", "SRP",
  "SPR". specify the input orientation

- in_scale:

  Numeric. input intensity scale factor

- in_stats:

  Logical. display input stats

- in_type:

  Character; one of: "cor", "mgh", "mgz", "minc", "analyze",
  "analyze4d", "spm", "afni", "brik", "bshort", "bfloat", "sdt",
  "outline", "otl", "gdf", "nifti1", "nii", "niigz", "ge", "gelx", "lx",
  "ximg", "siemens", "dicom", "siemens_dicom". input file type

- invert_contrast:

  Numeric. threshold for inversting contrast

- midframe:

  Logical. keep only the middle frame

- no_change:

  Logical. don't change type of input to that of template

- no_scale:

  Logical. dont rescale values for COR

- no_translate:

  Logical. ???

- no_write:

  Logical. do not write output

- out_center:

  Character or numeric vector.

- out_datatype:

  Character; one of: "uchar", "short", "int", "float". output data type
  \<uchar\|short\|int\|float\>

- out_file:

  Character; file path. output filename or True to generate one

- out_i_count:

  Integer. some count ?? in i direction

- out_i_dir:

  Character or numeric vector.

- out_i_size:

  Integer. output i size

- out_info:

  Logical. display output info

- out_j_count:

  Integer. some count ?? in j direction

- out_j_dir:

  Character or numeric vector.

- out_j_size:

  Integer. output j size

- out_k_count:

  Integer. some count ?? in k direction

- out_k_dir:

  Character or numeric vector.

- out_k_size:

  Integer. output k size

- out_matrix:

  Logical. display output matrix

- out_orientation:

  Character; one of: "LAI", "LIA", "ALI", "AIL", "ILA", "IAL", "LAS",
  "LSA", "ALS", "ASL", "SLA", "SAL", "LPI", "LIP", "PLI", "PIL", "ILP",
  "IPL", "LPS", "LSP", "PLS", "PSL", "SLP", "SPL", "RAI", "RIA", "ARI",
  "AIR", "IRA", "IAR", "RAS", "RSA", "ARS", "ASR", "SRA", "SAR", "RPI",
  "RIP", "PRI", "PIR", "IRP", "IPR", "RPS", "RSP", "PRS", "PSR", "SRP",
  "SPR". specify the output orientation

- out_scale:

  Numeric. output intensity scale factor

- out_stats:

  Logical. display output stats

- out_type:

  Character; one of: "cor", "mgh", "mgz", "minc", "analyze",
  "analyze4d", "spm", "afni", "brik", "bshort", "bfloat", "sdt",
  "outline", "otl", "gdf", "nifti1", "nii", "niigz". output file type

- parse_only:

  Logical. parse input only

- read_only:

  Logical. read the input volume

- reorder:

  Character or numeric vector. olddim1 olddim2 olddim3

- resample_type:

  Character; one of: "interpolate", "weighted", "nearest", "sinc",
  "cubic". \<interpolate\|weighted\|nearest\|sinc\|cubic\> (default is
  interpolate)

- reslice_like:

  Character; file path. reslice output to match file

- sdcm_list:

  Character; file path. list of DICOM files for conversion

- skip_n:

  Integer. skip the first n frames

- slice_bias:

  Numeric. apply half-cosine bias field

- slice_crop:

  Character or numeric vector. s_start s_end : keep slices s_start to
  s_end

- slice_reverse:

  Logical. reverse order of slices, update vox2ras

- smooth_parcellation:

  Logical. smooth parcellation

- sphinx:

  Logical. change orientation info to sphinx

- split:

  Logical. split output frames into separate output files.

- status_file:

  Character; file path. status file for DICOM conversion

- subject_name:

  Character. subject name ???

- te:

  Integer. TE in msec

- template_info:

  Logical. dump info about template

- template_type:

  Character; one of: "cor", "mgh", "mgz", "minc", "analyze",
  "analyze4d", "spm", "afni", "brik", "bshort", "bfloat", "sdt",
  "outline", "otl", "gdf", "nifti1", "nii", "niigz", "ge", "gelx", "lx",
  "ximg", "siemens", "dicom", "siemens_dicom". template file type

- ti:

  Integer. TI in msec (note upper case flag)

- tr:

  Integer. TR in msec

- unwarp_gradient:

  Logical. unwarp gradient nonlinearity

- vox_size:

  Character or numeric vector. \<size_x\> \<size_y\> \<size_z\> specify
  the size (mm) - useful for upsampling or downsampling

- zero_ge_z_offset:

  Logical. zero ge z offset ???

- zero_outlines:

  Logical. zero outlines

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
