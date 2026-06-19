# FSL XFibres5

Perform model parameters estimation for local (voxelwise) diffusion

## Usage

``` r
ni_fsl_x_fibres5(
  bvals,
  bvecs,
  dwi,
  mask,
  n_fibres,
  all_ard = NULL,
  args = NULL,
  burn_in = 0,
  burn_in_no_ard = 0,
  cnlinear = NULL,
  f0_ard = NULL,
  f0_noard = NULL,
  force_dir = TRUE,
  fudge = NULL,
  gradnonlin = NULL,
  logdir = ".",
  model = NULL,
  n_jumps = 5000,
  no_ard = NULL,
  no_spat = NULL,
  non_linear = NULL,
  rician = NULL,
  sample_every = 1,
  seed = NULL,
  update_proposal_every = 40,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- bvals:

  Character; file path. b values file **Required.**

- bvecs:

  Character; file path. b vectors file **Required.**

- dwi:

  Character; file path. diffusion weighted image data file **Required.**

- mask:

  Character; file path. brain binary mask file (i.e. from BET)
  **Required.**

- n_fibres:

  Character. Maximum number of fibres to fit in each voxel **Required.**

- all_ard:

  Logical. Turn ARD on on all fibres

- args:

  Character. Additional parameters to the command

- burn_in:

  Character. Total num of jumps at start of MCMC to be discarded

- burn_in_no_ard:

  Character. num of burnin jumps before the ard is imposed

- cnlinear:

  Logical. Initialise with constrained nonlinear fitting

- f0_ard:

  Logical. Noise floor model: add to the model an unattenuated signal
  compartment f0

- f0_noard:

  Logical. Noise floor model: add to the model an unattenuated signal
  compartment f0

- force_dir:

  Logical. use the actual directory name given (do not add + to make a
  new directory)

- fudge:

  Integer. ARD fudge factor

- gradnonlin:

  Character; file path. gradient file corresponding to slice

- logdir:

  Character; directory path

- model:

  Character; one of: "1", "2", "3". use monoexponential (1, default,
  required for single-shell) or multiexponential (2, multi-shell) model

- n_jumps:

  Integer. Num of jumps to be made by MCMC

- no_ard:

  Logical. Turn ARD off on all fibres

- no_spat:

  Logical. Initialise with tensor, not spatially

- non_linear:

  Logical. Initialise with nonlinear fitting

- rician:

  Logical. use Rician noise modeling

- sample_every:

  Character. Num of jumps for each sample (MCMC)

- seed:

  Integer. seed for pseudo random number generator

- update_proposal_every:

  Character. Num of jumps for each update to the proposal density std
  (MCMC)

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
