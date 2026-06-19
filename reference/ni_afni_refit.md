# AFNI Refit

Changes some of the information inside a 3D dataset's header

## Usage

``` r
ni_afni_refit(
  in_file,
  args = NULL,
  atrcopy = NULL,
  atrfloat = NULL,
  atrint = NULL,
  atrstring = NULL,
  deoblique = NULL,
  duporigin_file = NULL,
  nosaveatr = NULL,
  saveatr = NULL,
  space = NULL,
  xdel = NULL,
  xorigin = NULL,
  xyzscale = NULL,
  ydel = NULL,
  yorigin = NULL,
  zdel = NULL,
  zorigin = NULL,
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

  Character; file path. input file to 3drefit **Required.**

- args:

  Character. Additional parameters to the command

- atrcopy:

  Character or numeric vector. Copy AFNI header attribute from the given
  file into the header of the dataset(s) being modified. For more
  information on AFNI header attributes, see documentation file
  README.attributes. More than one '-atrcopy' option can be used. For
  AFNI advanced users only. Do NOT use -atrcopy or -atrstring with other
  modification options. See also -copyaux.

- atrfloat:

  Character or numeric vector. Create or modify floating point
  attributes. The input values may be specified as a single string in
  quotes or as a 1D filename or string, example '1 0.2 0 0 -0.2 1 0 0 0
  0 1 0' or flipZ.1D or '1D:1,0.2,2@0,-0.2,1,2@0,2@0,1,0'

- atrint:

  Character or numeric vector. Create or modify integer attributes. The
  input values may be specified as a single string in quotes or as a 1D
  filename or string, example '1 0 0 0 0 1 0 0 0 0 1 0' or flipZ.1D or
  '1D:1,0,2@0,-0,1,2@0,2@0,1,0'

- atrstring:

  Character or numeric vector. Copy the last given string into the
  dataset(s) being modified, giving it the attribute name given by the
  last string.To be safe, the last string should be in quotes.

- deoblique:

  Logical. replace current transformation matrix with cardinal matrix

- duporigin_file:

  Character; file path. Copies the xorigin, yorigin, and zorigin values
  from the header of the given dataset

- nosaveatr:

  Logical. Opposite of -saveatr

- saveatr:

  Logical. (default) Copy the attributes that are known to AFNI into the
  dset-\>dblk structure thereby forcing changes to known attributes to
  be present in the output. This option only makes sense with -atrcopy.

- space:

  Character; one of: "TLRC", "MNI", "ORIG". Associates the dataset with
  a specific template type, e.g. TLRC, MNI, ORIG

- xdel:

  Numeric. new x voxel dimension in mm

- xorigin:

  Character. x distance for edge voxel offset

- xyzscale:

  Numeric. Scale the size of the dataset voxels by the given factor

- ydel:

  Numeric. new y voxel dimension in mm

- yorigin:

  Character. y distance for edge voxel offset

- zdel:

  Numeric. new z voxel dimension in mm

- zorigin:

  Character. z distance for edge voxel offset

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
