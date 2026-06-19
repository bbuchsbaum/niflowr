# FSL TOPUP

Interface for FSL topup, a tool for estimating and correcting

## Usage

``` r
ni_fsl_topup(
  encoding_direction,
  encoding_file,
  in_file,
  readout_times,
  args = NULL,
  config = "b02b0.cnf",
  estmov = NULL,
  fwhm = NULL,
  interp = NULL,
  max_iter = NULL,
  minmet = NULL,
  numprec = NULL,
  out_base = NULL,
  out_corrected = NULL,
  out_field = NULL,
  out_jac_prefix = "jac",
  out_logfile = NULL,
  out_mat_prefix = "xfm",
  out_warp_prefix = "warpfield",
  reg_lambda = NULL,
  regmod = NULL,
  regrid = NULL,
  scale = NULL,
  splineorder = NULL,
  ssqlambda = NULL,
  subsamp = NULL,
  warp_res = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- encoding_direction:

  Character or numeric vector. encoding direction for automatic
  generation of encoding_file **Required.**

- encoding_file:

  Character; file path. name of text file with PE directions/times
  **Required.**

- in_file:

  Character; file path. name of 4D file with images **Required.**

- readout_times:

  Character or numeric vector. readout times (dwell times by \#
  phase-encode steps minus 1) **Required.**

- args:

  Character. Additional parameters to the command

- config:

  Character. Name of config file specifying command line arguments

- estmov:

  Character; one of: "1", "0". estimate movements if set

- fwhm:

  Numeric. FWHM (in mm) of gaussian smoothing kernel

- interp:

  Character; one of: "spline", "linear". Image interpolation model,
  linear or spline.

- max_iter:

  Integer. max \# of non-linear iterations

- minmet:

  Character; one of: "0", "1". Minimisation method
  0=Levenberg-Marquardt, 1=Scaled Conjugate Gradient

- numprec:

  Character; one of: "double", "float". Precision for representing
  Hessian, double or float.

- out_base:

  Character; file path. base-name of output files (spline coefficients
  (Hz) and movement parameters)

- out_corrected:

  Character; file path. name of 4D image file with unwarped images

- out_field:

  Character; file path. name of image file with field (Hz)

- out_jac_prefix:

  Character. prefix for the warpfield images

- out_logfile:

  Character; file path. name of log-file

- out_mat_prefix:

  Character. prefix for the realignment matrices

- out_warp_prefix:

  Character. prefix for the warpfield images (in mm)

- reg_lambda:

  Numeric. Weight of regularisation, default depending on –ssqlambda and
  –regmod switches.

- regmod:

  Character; one of: "bending_energy", "membrane_energy". Regularisation
  term implementation. Defaults to bending_energy. Note that the two
  functions have vastly different scales. The membrane energy is based
  on the first derivatives and the bending energy on the second
  derivatives. The second derivatives will typically be much smaller
  than the first derivatives, so input lambda will have to be larger for
  bending_energy to yield approximately the same level of
  regularisation.

- regrid:

  Character; one of: "1", "0". If set (=1), the calculations are done in
  a different grid

- scale:

  Character; one of: "0", "1". If set (=1), the images are individually
  scaled to a common mean

- splineorder:

  Integer. order of spline, 2-\>Qadratic spline, 3-\>Cubic spline

- ssqlambda:

  Character; one of: "1", "0". Weight lambda by the current value of the
  ssd. If used (=1), the effective weight of regularisation term becomes
  higher for the initial iterations, therefore initial steps are a
  little smoother than they would without weighting. This reduces the
  risk of finding a local minimum.

- subsamp:

  Integer. sub-sampling scheme

- warp_res:

  Numeric. (approximate) resolution (in mm) of warp basis for the
  different sub-sampling levels

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
