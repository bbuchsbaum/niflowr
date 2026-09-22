# applyxfm4D adapter qualification

Date: 2026-09-22. Fastprep ticket: FP-071.

The manual `fsl.applyxfm4d` specification generates
`ni_fsl_applyxfm4d()` with `tools/gen_wrappers.R`. The command golden includes
its positional argument vector. The Nipype importer writes imported spec IDs;
this manual specification is maintained separately.

Exactly one of `mat_dir` and `single_matrix` is accepted. With a directory,
RNifti reads the source header and requires a 4D input with 1–10,000 volumes.
The directory must contain exactly `MAT_0000` through the final volume index;
extra entries, missing indices, and five-digit names fail. Every matrix must
be a finite, nonsingular 4-by-4 affine. Single-matrix mode uses the same matrix
validation. The adapter validates at construction and again before execution,
including a call constructed with `.validate = FALSE` for preview. RNifti is
an optional package dependency but is required to execute this adapter.

Typed image, directory, and matrix inputs use niflowr's existing path rewriting
and provenance. The default output environment explicitly sets
`FSLOUTPUTTYPE=NIFTI_GZ`; `.env = c(FSLOUTPUTTYPE="NIFTI")` selects `.nii`.
Other output formats fail. Rendering strips a supplied NIfTI suffix and the
resolver declares the actual required nonempty output.

## Real binary evidence

The tests used local Docker image
`sha256:0b5835425886a5d0eaebd7d18667a436281d79bf5afd1639a5bab41e36077bc3`
(`neurotransform-fsl:6.0.7.22`, linux/amd64 under Docker on an arm64 Mac).
This differs from the image in the unavailable historical FP-071 source.
Its `/usr/local/fsl/bin/applyxfm4D -h` advertises `-interp`, `-singlematrix`,
`-fourdigit`, and `-userprefix`. This adapter exposes only the two matrix modes
and uses the documented default sinc interpolation. It does not accept arbitrary
AFNI interpolation kernels or expose the additional interpolation modes.

The real test writes two identical 9-by-9-by-9 volumes with explicit unit RAS
qform and sform (code 1). Matrix zero is identity; matrix one translates by
+2 mm on FSL's x axis. Both `NIFTI` and `NIFTI_GZ` produce the declared 4D
artifact. Volume zero matches the original within 1e-4 absolute intensity;
volume one matches the independently constructed two-voxel shift toward smaller
array x within 1e-3 (the object has intensity 100). This checks ordering and
actual image contents, not just a process exit. Single-matrix identity preserves
both volumes. Removing `MAT_0001` after constructing a valid call fails before
launch and produces no output. Container previews verify directory and image
paths with spaces map to `/in` and `/out`.

Run the adapter unit and real-image checks with:

```sh
NIFLOWR_TEST_FSL_IMAGE=sha256:0b5835425886a5d0eaebd7d18667a436281d79bf5afd1639a5bab41e36077bc3 \
  Rscript -e 'testthat::test_local(filter="fsl-applyxfm4d")'
```

The adapter run passed 39 assertions with no failures, errors, or skips.
Ordinary unit runs skip the real-container test unless the image is explicitly
selected. This evidence does not qualify a fastprep FSL recipe, general transform
conversion, scientific accuracy, other platforms, or other FSL builds.

The full niflowr suite at this source passed 1,394 assertions with no failures
or errors, six conditional skips, and the existing targets `priority`
deprecation warning. The real FSL test was enabled in that run; the AFNI binary
integration was not enabled. A source build and
`R CMD check --no-manual --no-tests --ignore-vignettes` completed with no errors
or warnings and one note for unavailable optional `bidsappr`, `fmriprepper`,
`openneuroR`, and `tarchetypes`. Tests were run separately; vignettes were not
rebuilt or qualified by this adapter change.
