# AFNI NetCorr

Calculate correlation matrix of a set of ROIs (using mean time series of

## Usage

``` r
ni_afni_net_corr(
  in_file,
  in_rois,
  args = NULL,
  fish_z = NULL,
  ignore_LT = NULL,
  mask = NULL,
  nifti = NULL,
  out_file = NULL,
  output_mask_nonnull = NULL,
  part_corr = NULL,
  push_thru_many_zeros = NULL,
  ts_indiv = NULL,
  ts_label = NULL,
  ts_out = NULL,
  ts_wb_Z = NULL,
  ts_wb_corr = NULL,
  ts_wb_strlabel = NULL,
  weight_ts = NULL,
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

  Character; file path. input time series file (4D data set)
  **Required.**

- in_rois:

  Character; file path. input set of ROIs, each labelled with distinct
  integers **Required.**

- args:

  Character. Additional parameters to the command

- fish_z:

  Logical. switch to also output a matrix of Fisher Z-transform values
  for the corr coefs (r): Z = atanh(r) , (with Z=4 being output along
  matrix diagonals where r=1, as the r-to-Z conversion is ceilinged at Z
  = atanh(r=0.999329) = 4, which is still *quite* a high Pearson-r value

- ignore_LT:

  Logical. switch to ignore any label table labels in the '-in_rois'
  file, if there are any labels attached

- mask:

  Character; file path. can include a whole brain mask within which to
  calculate correlation. Otherwise, data should be masked already

- nifti:

  Logical. output any correlation map files as NIFTI files (default is
  BRIK/HEAD). Only useful if using '-ts_wb_corr' and/or '-ts_wb_Z'

- out_file:

  Character; file path. output file name part

- output_mask_nonnull:

  Logical. internally, this program checks for where there are nonnull
  time series, because we don't like those, in general. With this flag,
  the user can output the determined mask of non-null time series.

- part_corr:

  Logical. output the partial correlation matrix

- push_thru_many_zeros:

  Logical. by default, this program will grind to a halt and refuse to
  calculate if any ROI contains \>10 percent of voxels with null times
  series (i.e., each point is 0), as of April, 2017. This is because it
  seems most likely that hidden badness is responsible. However, if the
  user still wants to carry on the calculation anyways, then this option
  will allow one to push on through. However, if any ROI *only* has null
  time series, then the program will not calculate and the user will
  really, really, really need to address their masking

- ts_indiv:

  Logical. switch to create a directory for each network that contains
  the average time series for each ROI in individual files (each file
  has one line). The directories are labelled PREFIX_000_INDIV/,
  PREFIX_001_INDIV/, etc. (one per network). Within each directory, the
  files are labelled ROI_001.netts, ROI_002.netts, etc., with the
  numbers given by the actual ROI integer labels

- ts_label:

  Logical. additional switch when using '-ts_out'. Using this option
  will insert the integer ROI label at the start of each line of the
  \*.netts file created. Thus, for a time series of length N, each line
  will have N+1 numbers, where the first is the integer ROI label and
  the subsequent N are scientific notation values

- ts_out:

  Logical. switch to output the mean time series of the ROIs that have
  been used to generate the correlation matrices. Output filenames
  mirror those of the correlation matrix files, with a '.netts' postfix

- ts_wb_Z:

  Logical. same as above in '-ts_wb_corr', except that the maps have
  been Fisher transformed to Z-scores the relation: Z=atanh(r). To avoid
  infinities in the transform, Pearson values are effectively capped at
  \|r\| = 0.999329 (where \|Z\| = 4.0). Files are labelled
  WB_Z_ROI_001+orig, etc

- ts_wb_corr:

  Logical. switch to create a set of whole brain correlation maps.
  Performs whole brain correlation for each ROI's average time series;
  this will automatically create a directory for each network that
  contains the set of whole brain correlation maps (Pearson 'r's). The
  directories are labelled as above for '-ts_indiv' Within each
  directory, the files are labelled WB_CORR_ROI_001+orig,
  WB_CORR_ROI_002+orig, etc., with the numbers given by the actual ROI
  integer labels

- ts_wb_strlabel:

  Logical. by default, '-ts_wb\_{corr,Z}' output files are named using
  the int number of a given ROI, such as: WB_Z_ROI_001+orig. With this
  option, one can replace the int (such as '001') with the string label
  (such as 'L-thalamus') *if* one has a labeltable attached to the file

- weight_ts:

  Character; file path. input a 1D file WTS of weights that will be
  applied multiplicatively to each ROI's average time series. WTS can be
  a column- or row-file of values, but it must have the same length as
  the input time series volume. If the initial average time series was
  A\[n\] for n=0,..,(N-1) time points, then applying a set of weights
  W\[n\] of the same length from WTS would produce a new time series:
  B\[n\] = A\[n\] \* W\[n\]

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
