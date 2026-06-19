# ANTS CompositeTransformUtil

ANTs utility which can combine or break apart transform files into their
individual

## Usage

``` r
ni_ants_composite_transform_util(
  in_file,
  args = NULL,
  out_file = NULL,
  output_prefix = "transform",
  process = "assemble",
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

  Character or numeric vector. Input transform file(s) **Required.**

- args:

  Character. Additional parameters to the command

- out_file:

  Character; file path. Output file path (only used for disassembly).

- output_prefix:

  Character. A prefix that is prepended to all output files (only used
  for assembly).

- process:

  Character; one of: "assemble", "disassemble". What to do with the
  transform inputs (assemble or disassemble)

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
