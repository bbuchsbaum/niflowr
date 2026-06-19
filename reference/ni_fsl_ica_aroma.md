# FSL ICA_AROMA

Interface for the ICA_AROMA.py script.

## Usage

``` r
ni_fsl_ica_aroma(
  denoise_type,
  feat_dir,
  in_file,
  motion_parameters,
  out_dir,
  TR = NULL,
  args = NULL,
  dim = NULL,
  fnirt_warp_file = NULL,
  mask = NULL,
  mat_file = NULL,
  melodic_dir = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- denoise_type:

  Character; one of: "nonaggr", "aggr", "both", "no". Type of denoising
  strategy: -no: only classification, no denoising -nonaggr (default):
  non-aggresssive denoising, i.e. partial component regression -aggr:
  aggressive denoising, i.e. full component regression -both: both
  aggressive and non-aggressive denoising (two outputs) **Required.**

- feat_dir:

  Character; directory path. If a feat directory exists and temporal
  filtering has not been run yet, ICA_AROMA can use the files in this
  directory. **Required.**

- in_file:

  Character; file path. volume to be denoised **Required.**

- motion_parameters:

  Character; file path. motion parameters file **Required.**

- out_dir:

  Character; directory path. output directory **Required.**

- TR:

  Numeric. TR in seconds. If this is not specified the TR will be
  extracted from the header of the fMRI nifti file.

- args:

  Character. Additional parameters to the command

- dim:

  Integer. Dimensionality reduction when running MELODIC (default is
  automatic estimation)

- fnirt_warp_file:

  Character; file path. File name of the warp-file describing the
  non-linear registration (e.g. FSL FNIRT) of the structural data to
  MNI152 space (.nii.gz)

- mask:

  Character; file path. path/name volume mask

- mat_file:

  Character; file path. path/name of the mat-file describing the affine
  registration (e.g. FSL FLIRT) of the functional data to structural
  space (.mat file)

- melodic_dir:

  Character; directory path. path to MELODIC directory if MELODIC has
  already been run

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
