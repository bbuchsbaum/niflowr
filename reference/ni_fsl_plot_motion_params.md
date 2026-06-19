# FSL PlotMotionParams

Use fsl_tsplot to plot the estimated motion parameters from a

## Usage

``` r
ni_fsl_plot_motion_params(
  in_file,
  in_source,
  plot_type,
  args = NULL,
  out_file = NULL,
  plot_size = NULL,
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

  Character or numeric vector. file with motion parameters **Required.**

- in_source:

  Character; one of: "spm", "fsl". which program generated the motion
  parameter file - fsl, spm **Required.**

- plot_type:

  Character; one of: "rotations", "translations", "displacement". which
  motion type to plot - rotations, translations, displacement
  **Required.**

- args:

  Character. Additional parameters to the command

- out_file:

  Character; file path. image to write

- plot_size:

  Character or numeric vector. plot image height and width

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
