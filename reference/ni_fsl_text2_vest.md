# FSL Text2Vest

Use FSL
Text2Vest`https://web.mit.edu/fsl_v5.0.10/fsl/doc/wiki/GLM(2f)CreatingDesignMatricesByHand.html`\_

## Usage

``` r
ni_fsl_text2_vest(
  in_file,
  out_file,
  args = NULL,
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

  Character; file path. plain text file representing your design,
  contrast, or f-test matrix **Required.**

- out_file:

  Character; file path. file name to store matrix data in the format
  used by FSL tools (e.g., design.mat, design.con design.fts)
  **Required.**

- args:

  Character. Additional parameters to the command

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
