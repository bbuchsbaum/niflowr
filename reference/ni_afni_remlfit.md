# AFNI Remlfit

Performs Generalized least squares time series fit with Restricted

## Usage

``` r
ni_afni_remlfit(
  in_files,
  matrix,
  STATmask = NULL,
  addbase = NULL,
  args = NULL,
  automask = FALSE,
  dsort = NULL,
  dsort_nods = NULL,
  errts_file = NULL,
  fitts_file = NULL,
  fout = NULL,
  glt_file = NULL,
  gltsym = NULL,
  goforit = NULL,
  mask = NULL,
  matim = NULL,
  nobout = NULL,
  nodmbase = NULL,
  nofdr = NULL,
  obeta = NULL,
  obuck = NULL,
  oerrts = NULL,
  ofitts = NULL,
  oglt = NULL,
  out_file = NULL,
  ovar = NULL,
  polort = NULL,
  quiet = NULL,
  rbeta_file = NULL,
  rout = NULL,
  slibase = NULL,
  slibase_sm = NULL,
  tout = NULL,
  usetemp = NULL,
  var_file = NULL,
  verb = NULL,
  wherr_file = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- in_files:

  Character or numeric vector. Read time series dataset **Required.**

- matrix:

  Character; file path. the design matrix file, which should have been
  output from Deconvolve via the 'x1D' option **Required.**

- STATmask:

  Character; file path. filename of 3D mask dataset to be used for the
  purpose of reporting truncation-to float issues AND for computing the
  FDR curves. The actual results ARE not masked with this option (only
  with 'mask' or 'automask' options).

- addbase:

  Character or numeric vector. file(s) to add baseline model columns to
  the matrix with this option. Each column in the specified file(s) will
  be appended to the matrix. File(s) must have at least as many rows as
  the matrix does.

- args:

  Character. Additional parameters to the command

- automask:

  Logical. build a mask automatically from input data (will be slow for
  long time series datasets)

- dsort:

  Character; file path. 4D dataset to be used as voxelwise baseline
  regressor

- dsort_nods:

  Logical. if 'dsort' option is used, this command will output
  additional results files excluding the 'dsort' file

- errts_file:

  Character; file path. output dataset for REML residuals = data -
  fitted model

- fitts_file:

  Character; file path. output dataset for REML fitted model

- fout:

  Logical. output F-statistic for each stimulus

- glt_file:

  Character; file path. output dataset for beta + statistics from the
  REML estimation, but ONLY for the GLTs added on the REMLfit command
  line itself via 'gltsym'; GLTs from Deconvolve's command line will NOT
  be included.

- gltsym:

  Character or numeric vector. read a symbolic GLT from input file and
  associate it with a label. As in Deconvolve, you can also use the
  'SYM:' method to provide the definition of the GLT directly as a
  string (e.g., with 'SYM: +Label1 -Label2'). Unlike Deconvolve, you
  MUST specify 'SYM: ' if providing the GLT directly as a string instead
  of from a file

- goforit:

  Logical. With potential issues flagged in the design matrix, an
  attempt will nevertheless be made to fit the model

- mask:

  Character; file path. filename of 3D mask dataset; only data time
  series from within the mask will be analyzed; results for voxels
  outside the mask will be set to zero.

- matim:

  Character; file path. read a standard file as the matrix. You can use
  only Col as a name in GLTs with these nonstandard matrix input
  methods, since the other names come from the 'matrix' file. These
  mutually exclusive options are ignored if 'matrix' is used.

- nobout:

  Logical. do NOT add baseline (null hypothesis) regressor betas to the
  'rbeta_file' and/or 'obeta_file' output datasets.

- nodmbase:

  Logical. by default, baseline columns added to the matrix via
  'addbase' or 'slibase' or 'dsort' will each have their mean removed
  (as is done in Deconvolve); this option turns this centering off

- nofdr:

  Logical. do NOT add FDR curve data to bucket datasets; FDR curves can
  take a long time if 'tout' is used

- obeta:

  Character; file path. dataset for beta weights from the OLSQ
  estimation

- obuck:

  Character; file path. dataset for beta + statistics from the OLSQ
  estimation

- oerrts:

  Character; file path. dataset for OLSQ residuals (data - fitted model)

- ofitts:

  Character; file path. dataset for OLSQ fitted model

- oglt:

  Character; file path. dataset for beta + statistics from 'gltsym'
  options

- out_file:

  Character; file path. output dataset for beta + statistics from the
  REML estimation; also contains the results of any GLT analysis
  requested in the Deconvolve setup, similar to the 'bucket' output from
  Deconvolve. This dataset does NOT get the betas (or statistics) of
  those regressors marked as 'baseline' in the matrix file.

- ovar:

  Character; file path. dataset for OLSQ st.dev. parameter (kind of
  boring)

- polort:

  Integer. if no 'matrix' option is given, AND no 'matim' option, create
  a matrix with Legendre polynomial regressorsup to the specified order.
  The default value is 0, whichproduces a matrix with a single column of
  all ones

- quiet:

  Logical. turn off most progress messages

- rbeta_file:

  Character; file path. output dataset for beta weights from the REML
  estimation, similar to the 'cbucket' output from Deconvolve. This
  dataset will contain all the beta weights, for baseline and stimulus
  regressors alike, unless the '-nobout' option is given – in that case,
  this dataset will only get the betas for the stimulus regressors.

- rout:

  Logical. output the R^2 statistic for each stimulus

- slibase:

  Character or numeric vector. similar to 'addbase' in concept, BUT each
  specified file must have an integer multiple of the number of slices
  in the input dataset(s); then, separate regression matrices are
  generated for each slice, with the first column of the file appended
  to the matrix for the first slice of the dataset, the second column of
  the file appended to the matrix for the first slice of the dataset,
  and so on. Intended to help model physiological noise in FMRI, or
  other effects you want to regress out that might change significantly
  in the inter-slice time intervals. This will slow the program down,
  and make it use a lot more memory (to hold all the matrix stuff).

- slibase_sm:

  Character or numeric vector. similar to 'slibase', BUT each file much
  be in slice major order (i.e. all slice0 columns come first, then all
  slice1 columns, etc).

- tout:

  Logical. output the T-statistic for each stimulus; if you use
  'out_file' and do not give any of 'fout', 'tout',or 'rout', then the
  program assumes 'fout' is activated.

- usetemp:

  Logical. write intermediate stuff to disk, to economize on RAM. Using
  this option might be necessary to run with 'slibase' and with 'Grid'
  values above the default, since the program has to store a large
  number of matrices for such a problem: two for every slice and for
  every (a,b) pair in the ARMA parameter grid. Temporary files are
  written to the directory given in environment variable TMPDIR, or in
  /tmp, or in ./ (preference is in that order)

- var_file:

  Character; file path. output dataset for REML variance parameters

- verb:

  Logical. turns on more progress messages, including memory usage
  progress reports at various stages

- wherr_file:

  Character; file path. dataset for REML residual, whitened using the
  estimated ARMA(1,1) correlation matrix of the noise

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
