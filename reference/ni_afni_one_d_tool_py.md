# AFNI OneDToolPy

This program is meant to read/manipulate/write/diagnose 1D datasets.

## Usage

``` r
ni_afni_one_d_tool_py(
  in_file,
  args = NULL,
  censor_motion = NULL,
  censor_prev_TR = NULL,
  demean = NULL,
  derivative = NULL,
  out_file = NULL,
  set_nruns = NULL,
  show_censor_count = NULL,
  show_cormat_warnings = NULL,
  show_indices_interest = NULL,
  show_trs_run = NULL,
  show_trs_uncensored = NULL,
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

  Character; file path. input file to OneDTool **Required.**

- args:

  Character. Additional parameters to the command

- censor_motion:

  Character or numeric vector. Tuple of motion limit and outfile prefix.
  need to also set set_nruns -r set_run_lengths

- censor_prev_TR:

  Logical. for each censored TR, also censor previous

- demean:

  Logical. demean each run (new mean of each run = 0.0)

- derivative:

  Logical. take the temporal derivative of each vector (done as first
  backward difference)

- out_file:

  Character; file path. write the current 1D data to FILE

- set_nruns:

  Integer. treat the input data as if it has nruns

- show_censor_count:

  Logical. display the total number of censored TRs Note : if input is a
  valid xmat.1D dataset, then the count will come from the header.
  Otherwise the input is assumed to be a binary censorfile, and zeros
  are simply counted.

- show_cormat_warnings:

  Character; file path. Write cormat warnings to a file

- show_indices_interest:

  Logical. display column indices for regs of interest

- show_trs_run:

  Integer. restrict -show_trs\_\[un\]censored to the given 1-based run

- show_trs_uncensored:

  Character; one of: "comma", "space", "encoded", "verbose". display a
  list of TRs which were not censored in the specified style

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
