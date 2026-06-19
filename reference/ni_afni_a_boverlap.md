# AFNI ABoverlap

Output (to screen) is a count of various things about how

## Usage

``` r
ni_afni_a_boverlap(
  in_file_a,
  in_file_b,
  args = NULL,
  no_automask = NULL,
  out_file = NULL,
  quiet = NULL,
  verb = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- in_file_a:

  Character; file path. input file A **Required.**

- in_file_b:

  Character; file path. input file B **Required.**

- args:

  Character. Additional parameters to the command

- no_automask:

  Logical. consider input datasets as masks

- out_file:

  Character; file path. collect output to a file

- quiet:

  Logical. be as quiet as possible (without being entirely mute)

- verb:

  Logical. print out some progress reports (to stderr)

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
