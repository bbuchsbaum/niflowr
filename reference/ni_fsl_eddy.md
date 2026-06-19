# FSL Eddy

Interface for FSL eddy, a tool for estimating and correcting eddy

## Usage

``` r
ni_fsl_eddy(
  in_acqp,
  in_bval,
  in_bvec,
  in_file,
  in_index,
  in_mask,
  args = NULL,
  cnr_maps = NULL,
  dont_peas = NULL,
  dont_sep_offs_move = NULL,
  estimate_move_by_susceptibility = NULL,
  fep = NULL,
  field = NULL,
  field_mat = NULL,
  flm = "quadratic",
  fudge_factor = 10,
  fwhm = NULL,
  in_topup_fieldcoef = NULL,
  initrand = NULL,
  interp = "spline",
  is_shelled = NULL,
  json = NULL,
  mbs_ksp = NULL,
  mbs_lambda = NULL,
  mbs_niter = NULL,
  method = "jac",
  mporder = NULL,
  multiband_factor = NULL,
  multiband_offset = NULL,
  niter = 5,
  nvoxhp = 1000,
  out_base = "eddy_corrected",
  outlier_nstd = NULL,
  outlier_nvox = NULL,
  outlier_pos = NULL,
  outlier_sqr = NULL,
  outlier_type = NULL,
  repol = NULL,
  residuals = NULL,
  session = NULL,
  slice2vol_interp = NULL,
  slice2vol_lambda = NULL,
  slice2vol_niter = NULL,
  slice_order = NULL,
  slm = "none",
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- in_acqp:

  Character; file path. File containing acquisition parameters
  **Required.**

- in_bval:

  Character; file path. File containing the b-values for all volumes in
  –imain **Required.**

- in_bvec:

  Character; file path. File containing the b-vectors for all volumes in
  –imain **Required.**

- in_file:

  Character; file path. File containing all the images to estimate
  distortions for **Required.**

- in_index:

  Character; file path. File containing indices for all volumes in
  –imain into –acqp and –topup **Required.**

- in_mask:

  Character; file path. Mask to indicate brain **Required.**

- args:

  Character. Additional parameters to the command

- cnr_maps:

  Logical. Output CNR-Maps

- dont_peas:

  Logical. Do NOT perform a post-eddy alignment of shells

- dont_sep_offs_move:

  Logical. Do NOT attempt to separate field offset from subject movement

- estimate_move_by_susceptibility:

  Logical. Estimate how susceptibility field changes with subject
  movement

- fep:

  Logical. Fill empty planes in x- or y-directions

- field:

  Character; file path. Non-topup derived fieldmap scaled in Hz

- field_mat:

  Character; file path. Matrix specifying the relative positions of the
  fieldmap, –field, and the first volume of the input file, –imain

- flm:

  Character; one of: "quadratic", "linear", "cubic". First level EC
  model

- fudge_factor:

  Numeric. Fudge factor for hyperparameter error variance

- fwhm:

  Numeric. FWHM for conditioning filter when estimating the parameters

- in_topup_fieldcoef:

  Character; file path. Topup results file containing the field
  coefficients

- initrand:

  Logical. Resets rand for when selecting voxels

- interp:

  Character; one of: "spline", "trilinear". Interpolation model for
  estimation step

- is_shelled:

  Logical. Override internal check to ensure that date are acquired on a
  set of b-value shells

- json:

  Character; file path. Name of .json text file with information about
  slice timing

- mbs_ksp:

  Integer. Knot-spacing for MBS field estimation

- mbs_lambda:

  Integer. Weighting of regularisation for MBS estimation

- mbs_niter:

  Integer. Number of iterations for MBS estimation

- method:

  Character; one of: "jac", "lsr". Final resampling method
  (jacobian/least squares)

- mporder:

  Integer. Order of slice-to-vol movement model

- multiband_factor:

  Integer. Multi-band factor

- multiband_offset:

  Character; one of: "0", "1", "-1". Multi-band offset (-1 if bottom
  slice removed, 1 if top slice removed

- niter:

  Integer. Number of iterations

- nvoxhp:

  Integer. \# of voxels used to estimate the hyperparameters

- out_base:

  Character. Basename for output image

- outlier_nstd:

  Integer. Number of std off to qualify as outlier

- outlier_nvox:

  Integer. Min \# of voxels in a slice for inclusion in outlier
  detection

- outlier_pos:

  Logical. Consider both positive and negative outliers if set

- outlier_sqr:

  Logical. Consider outliers among sums-of-squared differences if set

- outlier_type:

  Character; one of: "sw", "gw", "both". Type of outliers, slicewise
  (sw), groupwise (gw) or both (both)

- repol:

  Logical. Detect and replace outlier slices

- residuals:

  Logical. Output Residuals

- session:

  Character; file path. File containing session indices for all volumes
  in –imain

- slice2vol_interp:

  Character; one of: "trilinear", "spline". Slice-to-vol interpolation
  model for estimation step

- slice2vol_lambda:

  Integer. Regularisation weight for slice-to-vol movement (reasonable
  range 1-10)

- slice2vol_niter:

  Integer. Number of iterations for slice-to-vol

- slice_order:

  Character; file path. Name of text file completely specifying
  slice/group acquisition

- slm:

  Character; one of: "none", "linear", "quadratic". Second level EC
  model

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
