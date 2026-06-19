# FSL EddyQuad

Interface for FSL eddy_quad, a tool for generating single subject
reports

## Usage

``` r
ni_fsl_eddy_quad(
  bval_file,
  idx_file,
  mask_file,
  param_file,
  args = NULL,
  base_name = "eddy_corrected",
  bvec_file = NULL,
  field = NULL,
  output_dir = NULL,
  slice_spec = NULL,
  verbose = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- bval_file:

  Character; file path. b-values file **Required.**

- idx_file:

  Character; file path. File containing indices for all volumes into
  acquisition parameters **Required.**

- mask_file:

  Character; file path. Binary mask file **Required.**

- param_file:

  Character; file path. File containing acquisition parameters
  **Required.**

- args:

  Character. Additional parameters to the command

- base_name:

  Character. Basename (including path) for EDDY output files, i.e.,
  corrected images and QC files

- bvec_file:

  Character; file path. b-vectors file - only used when
  \<base_name\>.eddy_residuals file is present

- field:

  Character; file path. TOPUP estimated field (in Hz)

- output_dir:

  Character. Output directory - default = '\<base_name\>.qc'

- slice_spec:

  Character; file path. Text file specifying slice/group acquisition

- verbose:

  Logical. Display debug messages

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
