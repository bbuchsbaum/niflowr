# FREESURFER CheckTalairachAlignment

This program detects Talairach alignment failures

## Usage

``` r
ni_freesurfer_check_talairach_alignment(
  in_file,
  subject,
  args = NULL,
  threshold = 0.01,
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

  Character; file path. specify the talairach.xfm file to check
  **Required.**

- subject:

  Character. specify subject's name **Required.**

- args:

  Character. Additional parameters to the command

- threshold:

  Numeric. Talairach transforms for subjects with p-values \<= T are
  considered as very unlikely default=0.010

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
