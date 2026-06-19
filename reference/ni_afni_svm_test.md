# AFNI SVMTest

Temporally predictive modeling with the support vector machine

## Usage

``` r
ni_afni_svm_test(
  in_file,
  model,
  args = NULL,
  classout = NULL,
  multiclass = NULL,
  nodetrend = NULL,
  nopredcensord = NULL,
  options = NULL,
  out_file = NULL,
  testlabels = NULL,
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

  Character; file path. A 3D or 3D+t AFNI brik dataset to be used for
  testing. **Required.**

- model:

  Character. modname is the basename for the brik containing the SVM
  model **Required.**

- args:

  Character. Additional parameters to the command

- classout:

  Logical. Flag to specify that pname files should be integer-valued,
  corresponding to class category decisions.

- multiclass:

  Logical. Specifies multiclass algorithm for classification

- nodetrend:

  Logical. Flag to specify that pname files should not be linearly
  detrended

- nopredcensord:

  Logical. Flag to prevent writing predicted values for censored
  time-points

- options:

  Character. additional options for SVM-light

- out_file:

  Character; file path. filename for .1D prediction file(s).

- testlabels:

  Character; file path. *true* class category .1D labels for the test
  dataset. It is used to calculate the prediction accuracy performance

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
