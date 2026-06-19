# FSL PlotTimeSeries

Use fsl_tsplot to create images of time course plots.

## Usage

``` r
ni_fsl_plot_time_series(
  in_file,
  args = NULL,
  labels = NULL,
  legend_file = NULL,
  out_file = NULL,
  plot_finish = NULL,
  plot_range = NULL,
  plot_size = NULL,
  plot_start = NULL,
  sci_notation = NULL,
  title = NULL,
  x_precision = NULL,
  x_units = 1,
  y_max = NULL,
  y_min = NULL,
  y_range = NULL,
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

  Character or numeric vector. file or list of files with columns of
  timecourse information **Required.**

- args:

  Character. Additional parameters to the command

- labels:

  Character or numeric vector. label or list of labels

- legend_file:

  Character; file path. legend file

- out_file:

  Character; file path. image to write

- plot_finish:

  Integer. final column from in-file to plot

- plot_range:

  Character or numeric vector. first and last columns from the in-file
  to plot

- plot_size:

  Character or numeric vector. plot image height and width

- plot_start:

  Integer. first column from in-file to plot

- sci_notation:

  Logical. switch on scientific notation

- title:

  Character. plot title

- x_precision:

  Integer. precision of x-axis labels

- x_units:

  Integer. scaling units for x-axis (between 1 and length of in file)

- y_max:

  Numeric. maximum y value

- y_min:

  Numeric. minimum y value

- y_range:

  Character or numeric vector. min and max y axis values

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
