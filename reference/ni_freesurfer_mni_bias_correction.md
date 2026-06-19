# FREESURFER MNIBiasCorrection

Wrapper for nu_correct, a program from the Montreal Neurological
Institute (MNI)

## Usage

``` r
ni_freesurfer_mni_bias_correction(
  in_file,
  args = NULL,
  distance = NULL,
  iterations = 4,
  mask = NULL,
  no_rescale = NULL,
  out_file = NULL,
  protocol_iterations = NULL,
  shrink = NULL,
  stop = NULL,
  transform = NULL,
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

  Character; file path. input volume. Input can be any format accepted
  by mri_convert. **Required.**

- args:

  Character. Additional parameters to the command

- distance:

  Integer. N3 -distance option

- iterations:

  Integer. Number of iterations to run nu_correct. Default is 4. This is
  the number of times that nu_correct is repeated (ie, using the output
  from the previous run as the input for the next). This is different
  than the -iterations option to nu_correct.

- mask:

  Character; file path. brainmask volume. Input can be any format
  accepted by mri_convert.

- no_rescale:

  Logical. do not rescale so that global mean of output == input global
  mean

- out_file:

  Character; file path. output volume. Output can be any format accepted
  by mri_convert. If the output format is COR, then the directory must
  exist.

- protocol_iterations:

  Integer. Passes Np as argument of the -iterations flag of nu_correct.
  This is different than the –n flag above. Default is not to pass
  nu_correct the -iterations flag.

- shrink:

  Integer. Shrink parameter for finer sampling (default is 4)

- stop:

  Numeric. Convergence threshold below which iteration stops (suggest
  0.01 to 0.0001)

- transform:

  Character; file path. tal.xfm. Use mri_make_uchar instead of
  conforming

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
