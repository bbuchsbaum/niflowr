# FREESURFER Register

This program registers a surface to an average surface template.

## Usage

``` r
ni_freesurfer_register(
  in_sulc,
  in_surf,
  target,
  args = NULL,
  curv = NULL,
  out_file = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- in_sulc:

  Character; file path. Undocumented mandatory input file
  \${SUBJECTS_DIR}/surf/{hemisphere}.sulc **Required.**

- in_surf:

  Character; file path. Surface to register, often {hemi}.sphere
  **Required.**

- target:

  Character; file path. The data to register to. In normal recon-all
  usage, this is a template file for average surface. **Required.**

- args:

  Character. Additional parameters to the command

- curv:

  Logical. Use smoothwm curvature for final alignment

- out_file:

  Character; file path. Output surface file to capture registration

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
