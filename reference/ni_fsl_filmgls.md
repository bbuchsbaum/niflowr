# FSL FILMGLS

Use FSL film_gls command to fit a design matrix to voxel timeseries

## Usage

``` r
ni_fsl_filmgls(
  in_file,
  args = NULL,
  autocorr_estimate_only = NULL,
  autocorr_noestimate = NULL,
  brightness_threshold = NULL,
  design_file = NULL,
  fit_armodel = NULL,
  full_data = NULL,
  mask_size = NULL,
  multitaper_product = NULL,
  output_pwdata = NULL,
  results_dir = "results",
  smooth_autocorr = NULL,
  threshold = 1000,
  tukey_window = NULL,
  use_pava = NULL,
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

  Character; file path. input data file **Required.**

- args:

  Character. Additional parameters to the command

- autocorr_estimate_only:

  Logical. perform autocorrelation estimatation only

- autocorr_noestimate:

  Logical. do not estimate autocorrs

- brightness_threshold:

  Character. susan brightness threshold, otherwise it is estimated

- design_file:

  Character; file path. design matrix file

- fit_armodel:

  Logical. fits autoregressive model - default is to use tukey with
  M=sqrt(numvols)

- full_data:

  Logical. output full data

- mask_size:

  Integer. susan mask size

- multitaper_product:

  Integer. multitapering with slepian tapers and num is the
  time-bandwidth product

- output_pwdata:

  Logical. output prewhitened data and average design matrix

- results_dir:

  Character; directory path. directory to store results in

- smooth_autocorr:

  Logical. Smooth auto corr estimates

- threshold:

  Character. threshold

- tukey_window:

  Integer. tukey window size to estimate autocorr

- use_pava:

  Logical. estimates autocorr using PAVA

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
