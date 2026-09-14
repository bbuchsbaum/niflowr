# Imaging smoke tests

Run from the repository root with R package dependencies, Python (NumPy 2.2.6,
NiBabel 5.3.2), Docker, and the images in `images.json` already pulled:

```sh
Rscript tests/smoke/run.R /tmp/niflowr-smoke-new-run
```

The destination must be fresh. `NIFLOWR_SMOKE_IMAGES` optionally selects another
manifest for explicitly scoped compatibility runs. The default pins ANTs 2.6.5
and FSL 6.0.7.22 by registry digest on Linux amd64. CI pulls those references;
the harness uses `--pull=never`, per-step working directories, one thread, and
five-minute workload limits. It preserves logs and failure provenance.

The deterministic 48-cubed tissue phantom exercises N4 -> BET -> FAST -> FLIRT ->
epi_reg, plus three-frame MCFLIRT. FAST's actual segmentation supplies the WM
input. The independent Python checker reads image bytes, dimensions, affines,
frame counts, finite values, probability ranges, and matrices. It also checks
that N4's corrected image multiplied by its bias field reconstructs the input
inside the mask with intensity rescaling explicitly disabled. Every declared artifact must exist. These are mechanical
contracts, not anatomical accuracy or scientific efficacy tests.

`results.json` contains output sets and full provenance, including source hashes
and image identity. `verification.json` records the independent checks and an explicit passed/failed
status; file presence alone does not mean the check passed.
The GitHub Actions job uploads evidence even when the run fails.

The initial local compatibility run used FSL 5.0.9 (digest
`sha256:fbd262c385e9de22aa58bf7b6311cbd5cd96c7b4eaff151f879191e869bf224e`)
because the FSL 6 image exceeded available local disk capacity. Every declared
artifact was produced, but the independent checker found two invalid negative
background voxels in a FAST probability map. That run is **not a passing
qualification**. The default FSL 6 workflow must pass before claiming that
version's full smoke coverage.

Output contracts were checked against the primary interface sources:

- [FSL FAST documentation](https://fsl.fmrib.ox.ac.uk/fsl/docs/structural/fast.html)
- [Nipype FAST interface and output definitions](https://github.com/nipy/nipype/blob/master/nipype/interfaces/fsl/preprocess.py)
- [Nipype epi_reg output definitions](https://github.com/nipy/nipype/blob/master/nipype/interfaces/fsl/epi.py)
- [ANTs N4 source and argument definitions](https://github.com/ANTsX/ANTs/blob/master/Examples/N4BiasFieldCorrection.cxx)
