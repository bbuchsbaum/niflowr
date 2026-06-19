# FSL ConvertWarp

Use FSL
`convertwarp <http://fsl.fmrib.ox.ac.uk/fsl/fsl-4.1.9/fnirt/warp_utils.html>`\_

## Usage

``` r
ni_fsl_convert_warp(
  reference,
  abswarp = NULL,
  args = NULL,
  cons_jacobian = NULL,
  jacobian_max = NULL,
  jacobian_min = NULL,
  midmat = NULL,
  out_abswarp = NULL,
  out_file = NULL,
  out_relwarp = NULL,
  postmat = NULL,
  premat = NULL,
  relwarp = NULL,
  shift_direction = NULL,
  shift_in_file = NULL,
  warp1 = NULL,
  warp2 = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- reference:

  Character; file path. Name of a file in target space of the full
  transform. **Required.**

- abswarp:

  Logical. If set it indicates that the warps in –warp1 and –warp2
  should be interpreted as absolute. I.e. the values in –warp1/2 are the
  coordinates in the next space, rather than displacements. This flag is
  ignored if –warp1/2 was created by fnirt, which always creates
  relative displacements.

- args:

  Character. Additional parameters to the command

- cons_jacobian:

  Logical. Constrain the Jacobian of the warpfield to lie within
  specified min/max limits.

- jacobian_max:

  Numeric. Maximum acceptable Jacobian value for constraint (default
  100.0)

- jacobian_min:

  Numeric. Minimum acceptable Jacobian value for constraint (default
  0.01)

- midmat:

  Character; file path. Name of file containing mid-warp-affine
  transform

- out_abswarp:

  Logical. If set it indicates that the warps in –out should be
  absolute, i.e. the values in –out are displacements from the
  coordinates in –ref.

- out_file:

  Character; file path. Name of output file, containing warps that are
  the combination of all those given as arguments. The format of this
  will be a field-file (rather than spline coefficients) with any affine
  components included.

- out_relwarp:

  Logical. If set it indicates that the warps in –out should be
  relative, i.e. the values in –out are displacements from the
  coordinates in –ref.

- postmat:

  Character; file path. Name of file containing an affine transform
  (applied last). It could e.g. be an affine transform that maps the
  MNI152-space into a better approximation to the Talairach-space (if
  indeed there is one).

- premat:

  Character; file path. filename for pre-transform (affine matrix)

- relwarp:

  Logical. If set it indicates that the warps in –warp1/2 should be
  interpreted as relative. I.e. the values in –warp1/2 are displacements
  from the coordinates in the next space.

- shift_direction:

  Character; one of: "y-", "y", "x", "x-", "z", "z-". Indicates the
  direction that the distortions from –shiftmap goes. It depends on the
  direction and polarity of the phase-encoding in the EPI sequence.

- shift_in_file:

  Character; file path. Name of file containing a "shiftmap", a
  non-linear transform with displacements only in one direction (applied
  first, before premat). This would typically be a fieldmap that has
  been pre-processed using fugue that maps a subjects functional (EPI)
  data onto an undistorted space (i.e. a space that corresponds to
  his/her true anatomy).

- warp1:

  Character; file path. Name of file containing initial
  warp-fields/coefficients (follows premat). This could e.g. be a
  fnirt-transform from a subjects structural scan to an average of a
  group of subjects.

- warp2:

  Character; file path. Name of file containing secondary
  warp-fields/coefficients (after warp1/midmat but before postmat). This
  could e.g. be a fnirt-transform from the average of a group of
  subjects to some standard space (e.g. MNI152).

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
