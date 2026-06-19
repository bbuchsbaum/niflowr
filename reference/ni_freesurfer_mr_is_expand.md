# FREESURFER MRIsExpand

Expands a surface (typically ?h.white) outwards while maintaining

## Usage

``` r
ni_freesurfer_mr_is_expand(
  distance,
  in_file,
  args = NULL,
  dt = NULL,
  nsurfaces = NULL,
  out_name = "expanded",
  pial = NULL,
  smooth_averages = NULL,
  spring = NULL,
  thickness = NULL,
  thickness_name = NULL,
  write_iterations = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- distance:

  Numeric. Distance in mm or fraction of cortical thickness
  **Required.**

- in_file:

  Character; file path. Surface to expand **Required.**

- args:

  Character. Additional parameters to the command

- dt:

  Numeric. dt (implicit: 0.25)

- nsurfaces:

  Integer. Number of surfacces to write during expansion

- out_name:

  Character. Output surface file. If no path, uses directory of
  `in_file`. If no path AND missing "lh." or "rh.", derive from
  `in_file`

- pial:

  Character. Name of pial file (implicit: "pial") If no path, uses
  directory of `in_file` If no path AND missing "lh." or "rh.", derive
  from `in_file`

- smooth_averages:

  Integer. Smooth surface with N iterations after expansion

- spring:

  Numeric. Spring term (implicit: 0.05)

- thickness:

  Logical. Expand by fraction of cortical thickness, not mm

- thickness_name:

  Character. Name of thickness file (implicit: "thickness") If no path,
  uses directory of `in_file` If no path AND missing "lh." or "rh.",
  derive from `in_file`

- write_iterations:

  Integer. Write snapshots of expansion every N iterations

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
