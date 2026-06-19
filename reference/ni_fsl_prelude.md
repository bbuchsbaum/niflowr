# FSL PRELUDE

FSL prelude wrapper for phase unwrapping

## Usage

``` r
ni_fsl_prelude(
  complex_phase_file,
  magnitude_file,
  phase_file,
  args = NULL,
  end = NULL,
  label_file = NULL,
  labelprocess2d = NULL,
  mask_file = NULL,
  num_partitions = NULL,
  process2d = NULL,
  process3d = NULL,
  rawphase_file = NULL,
  removeramps = NULL,
  savemask_file = NULL,
  start = NULL,
  threshold = NULL,
  unwrapped_phase_file = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- complex_phase_file:

  Character; file path. complex phase input volume **Required.**

- magnitude_file:

  Character; file path. file containing magnitude image **Required.**

- phase_file:

  Character; file path. raw phase file **Required.**

- args:

  Character. Additional parameters to the command

- end:

  Integer. final image number to process (default Inf)

- label_file:

  Character; file path. saving the area labels output

- labelprocess2d:

  Logical. does label processing in 2D (slice at a time)

- mask_file:

  Character; file path. filename of mask input volume

- num_partitions:

  Integer. number of phase partitions to use

- process2d:

  Logical. does all processing in 2D (slice at a time)

- process3d:

  Logical. forces all processing to be full 3D

- rawphase_file:

  Character; file path. saving the raw phase output

- removeramps:

  Logical. remove phase ramps during unwrapping

- savemask_file:

  Character; file path. saving the mask volume

- start:

  Integer. first image number to process (default 0)

- threshold:

  Numeric. intensity threshold for masking

- unwrapped_phase_file:

  Character; file path. file containing unwrapepd phase

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
