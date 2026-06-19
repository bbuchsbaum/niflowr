# AFNI TSmooth

Smooths each voxel time series in a 3D+time dataset and produces

## Usage

``` r
ni_afni_t_smooth(
  in_file,
  adaptive = NULL,
  args = NULL,
  blackman = NULL,
  custom = NULL,
  datum = NULL,
  hamming = NULL,
  lin = NULL,
  lin3 = NULL,
  med = NULL,
  osf = NULL,
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

- in_file:

  Character; file path. input file to 3dTSmooth **Required.**

- adaptive:

  Integer. use adaptive mean filtering of width N (where N must be odd
  and bigger than 3).

- args:

  Character. Additional parameters to the command

- blackman:

  Integer. Use N point Blackman windows. (N must be odd and bigger than
  1.)

- custom:

  Character; file path. odd \# of coefficients must be in a single
  column in ASCII file

- datum:

  Character. Sets the data type of the output dataset

- hamming:

  Integer. Use N point Hamming windows. (N must be odd and bigger than
  1.)

- lin:

  Logical. 3 point linear filter: :math:`0.15\\,a + 0.70\\,b + 0.15\\,c`
  \[This is the default smoother\]

- lin3:

  Integer. 3 point linear filter:
  :math:`0.5\\,(1-m)\\,a + m\\,b + 0.5\\,(1-m)\\,c`. Here, 'm' is a
  number strictly between 0 and 1.

- med:

  Logical. 3 point median filter: median(a,b,c)

- osf:

  Logical. 3 point order statistics
  filter::math:`0.15\\,min(a,b,c) + 0.70\\,median(a,b,c) + 0.15\\,max(a,b,c)`

- out_file:

  Character; file path. output file from 3dTSmooth

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
