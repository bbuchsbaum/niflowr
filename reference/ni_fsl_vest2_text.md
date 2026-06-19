# FSL Vest2Text

Use FSL
Vest2Text`https://web.mit.edu/fsl_v5.0.10/fsl/doc/wiki/GLM(2f)CreatingDesignMatricesByHand.html`\_

## Usage

``` r
ni_fsl_vest2_text(
  in_file,
  args = NULL,
  out_file = "design.txt",
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

  Character; file path. matrix data stored in the format used by FSL
  tools **Required.**

- args:

  Character. Additional parameters to the command

- out_file:

  Character; file path. file name to store text output from matrix

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
