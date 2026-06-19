# FSL BET

FSL BET wrapper for skull stripping

## Usage

``` r
ni_fsl_bet(
  in_file,
  args = NULL,
  center = NULL,
  frac = NULL,
  functional = NULL,
  mask = NULL,
  mesh = NULL,
  no_output = NULL,
  out_file = NULL,
  outline = NULL,
  padding = NULL,
  radius = NULL,
  reduce_bias = NULL,
  remove_eyes = NULL,
  robust = NULL,
  skull = NULL,
  surfaces = NULL,
  t2_guided = NULL,
  threshold = NULL,
  vertical_gradient = NULL,
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

  Character; file path. input file to skull strip **Required.**

- args:

  Character. Additional parameters to the command

- center:

  Character or numeric vector. center of gravity in voxels

- frac:

  Numeric. fractional intensity threshold

- functional:

  Logical. apply to 4D fMRI data

- mask:

  Logical. create binary mask image

- mesh:

  Logical. generate a vtk mesh brain surface

- no_output:

  Logical. Don't generate segmented output

- out_file:

  Character; file path. name of output skull stripped image

- outline:

  Logical. create surface outline image

- padding:

  Logical. improve BET if FOV is very small in Z (by temporarily padding
  end slices)

- radius:

  Integer. head radius

- reduce_bias:

  Logical. bias field and neck cleanup

- remove_eyes:

  Logical. eye & optic nerve cleanup (can be useful in SIENA)

- robust:

  Logical. robust brain centre estimation (iterates BET several times)

- skull:

  Logical. create skull image

- surfaces:

  Logical. run bet2 and then betsurf to get additional skull and scalp
  surfaces (includes registrations)

- t2_guided:

  Character; file path. as with creating surfaces, when also feeding in
  non-brain-extracted T2 (includes registrations)

- threshold:

  Logical. apply thresholding to segmented brain image and mask

- vertical_gradient:

  Numeric. vertical gradient in fractional intensity threshold (-1, 1)

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
