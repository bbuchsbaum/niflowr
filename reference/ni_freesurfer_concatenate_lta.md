# FREESURFER ConcatenateLTA

Concatenates two consecutive LTA transformations into one overall

## Usage

``` r
ni_freesurfer_concatenate_lta(
  in_lta1,
  in_lta2,
  args = NULL,
  invert_1 = NULL,
  invert_2 = NULL,
  invert_out = NULL,
  out_file = NULL,
  out_type = NULL,
  subject = NULL,
  tal_source_file = NULL,
  tal_template_file = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- in_lta1:

  Character; file path. maps some src1 to dst1 **Required.**

- in_lta2:

  Character or numeric vector. maps dst1(src2) to dst2 **Required.**

- args:

  Character. Additional parameters to the command

- invert_1:

  Logical. invert in_lta1 before applying it

- invert_2:

  Logical. invert in_lta2 before applying it

- invert_out:

  Logical. invert output LTA

- out_file:

  Character; file path. the combined LTA maps: src1 to dst2 = LTA2\*LTA1

- out_type:

  Character; one of: "VOX2VOX", "RAS2RAS". set final LTA type

- subject:

  Character. set subject in output LTA

- tal_source_file:

  Character; file path. if in_lta2 is talairach.xfm, specify source for
  talairach

- tal_template_file:

  Character; file path. if in_lta2 is talairach.xfm, specify template
  for talairach

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
