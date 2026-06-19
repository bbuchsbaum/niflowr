# AFNI Undump

3dUndump - Assembles a 3D dataset from an ASCII list of coordinates and

## Usage

``` r
ni_afni_undump(
  in_file,
  args = NULL,
  coordinates_specification = NULL,
  datatype = NULL,
  default_value = NULL,
  fill_value = NULL,
  head_only = NULL,
  mask_file = NULL,
  orient = NULL,
  out_file = NULL,
  srad = NULL,
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

  Character; file path. input file to 3dUndump, whose geometry will
  determinethe geometry of the output **Required.**

- args:

  Character. Additional parameters to the command

- coordinates_specification:

  Character; one of: "ijk", "xyz". Coordinates in the input file as
  index triples (i, j, k) or spatial coordinates (x, y, z) in mm

- datatype:

  Character; one of: "short", "float", "byte". set output file datatype

- default_value:

  Numeric. default value stored in each input voxel that does not have a
  value supplied in the input file

- fill_value:

  Numeric. value, used for each voxel in the output dataset that is NOT
  listed in the input file

- head_only:

  Logical. create only the .HEAD file which gets exploited by the AFNI
  matlab library function New_HEAD.m

- mask_file:

  Character; file path. mask image file name. Only voxels that are
  nonzero in the mask can be set.

- orient:

  Character or numeric vector. Specifies the coordinate order used by
  -xyz. The code must be 3 letters, one each from the pairs {R,L} {A,P}
  {I,S}. The first letter gives the orientation of the x-axis, the
  second the orientation of the y-axis, the third the z-axis: R =
  right-to-left L = left-to-right A = anterior-to-posterior P =
  posterior-to-anterior I = inferior-to-superior S =
  superior-to-inferior If -orient isn't used, then the coordinate order
  of the -master (in_file) dataset is used to interpret (x,y,z) inputs.

- out_file:

  Character; file path. output image file name

- srad:

  Numeric. radius in mm of the sphere that will be filled about each
  input (x,y,z) or (i,j,k) voxel. If the radius is not given, or is 0,
  then each input data line sets the value in only one voxel.

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
