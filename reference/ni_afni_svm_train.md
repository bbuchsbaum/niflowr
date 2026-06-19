# AFNI SVMTrain

Temporally predictive modeling with the support vector machine

## Usage

``` r
ni_afni_svm_train(
  in_file,
  ttype,
  alphas = NULL,
  args = NULL,
  censor = NULL,
  kernel = NULL,
  mask = NULL,
  max_iterations = NULL,
  model = NULL,
  nomodelmask = NULL,
  options = NULL,
  out_file = NULL,
  trainlabels = NULL,
  w_out = NULL,
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

  Character; file path. A 3D+t AFNI brik dataset to be used for
  training. **Required.**

- ttype:

  Character. tname: classification or regression **Required.**

- alphas:

  Character; file path. output alphas file name

- args:

  Character. Additional parameters to the command

- censor:

  Character; file path. .1D censor file that allows the user to ignore
  certain samples in the training data.

- kernel:

  Character. string specifying type of kernel function:linear,
  polynomial, rbf, sigmoid

- mask:

  Character; file path. byte-format brik file used to mask voxels in the
  analysis

- max_iterations:

  Integer. Specify the maximum number of iterations for the
  optimization.

- model:

  Character; file path. basename for the brik containing the SVM model

- nomodelmask:

  Logical. Flag to enable the omission of a mask file

- options:

  Character. additional options for SVM-light

- out_file:

  Character; file path. output sum of weighted linear support vectors
  file name

- trainlabels:

  Character; file path. .1D labels corresponding to the stimulus
  paradigm for the training data.

- w_out:

  Logical. output sum of weighted linear support vectors

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
