# niflowr

> Spec-driven R wrappers for neuroimaging command-line tools — validated
> command building, execution, and provenance.

**niflowr** gives you typed, validated, provenance-tracked R functions
for **300+ commands** across **FSL, AFNI, ANTs, FreeSurfer**,
FastSurfer, and dcm2niix — without writing a single
[`system()`](https://rdrr.io/r/base/system.html) call. Each tool
interface is a JSON *specification*, so the wrappers are consistent,
inspectable, and easy to extend.

``` r

result <- ni_fsl_bet(
  in_file  = "sub-01_T1w.nii.gz",
  out_file = "sub-01_desc-brain_T1w.nii.gz",
  frac     = 0.5,
  mask     = TRUE
)

ni_outputs(result)
#> $out_file
#> [1] "sub-01_desc-brain_T1w.nii.gz"
```

That single call validated the inputs, built a **safe argument vector**
(no shell string), ran `bet` via
[`processx`](https://processx.r-lib.org/), confirmed the output exists,
and wrote a provenance sidecar — with no
[`paste()`](https://rdrr.io/r/base/paste.html) and no quoting bugs.

------------------------------------------------------------------------

## The problem

Neuroimaging pipelines stitch together dozens of command-line tools,
each with its own flag syntax, validation quirks, and output-naming
conventions. Wrapping them in R usually means brittle
[`system()`](https://rdrr.io/r/base/system.html) calls with
[`paste()`](https://rdrr.io/r/base/paste.html)-assembled shell strings:
no input checking, silent failures on a typo’d flag, shell-injection
hazards, and no record of what actually ran.

## What niflowr adds

- **Tools are described, not hand-wrapped.** Every interface is a
  declarative JSON spec listing inputs, outputs, CLI-rendering rules,
  and constraints. A shared engine turns those specs into R functions.
- **Commands are argument vectors, never shell strings.** Values go
  straight to `processx` as a `character` vector, without shell
  interpolation or word splitting.
- **Inputs are validated before anything runs** — required fields,
  types, enum choices, numeric ranges, and cross-argument constraints
  (`xor`, `requires`).
- **Runs carry provenance metadata.** The returned `ni_result` includes
  the exact command, engine/container, outputs, exit status, and timing;
  successful file-producing runs can also write a JSON sidecar.
- **Reproducibility hooks are explicit.** Run natively, in Docker, or in
  Apptainer/Singularity; pin image digests in a lockfile when you need a
  stricter execution record.
- **Workflow orchestration stays outside niflowr.** niflowr is the
  command-interface layer;
  [`targets`](https://docs.ropensci.org/targets/) (and `crew`) handle
  scheduling, caching, and parallelism.

## Relationship to fMRIPrep and NiPreps

For standard, end-to-end fMRI preprocessing of BIDS datasets, start with
[fMRIPrep](https://fmriprep.org/) and the broader
[NiPreps](https://www.nipreps.org/) ecosystem. Those projects provide
community-maintained preprocessing workflows, reports, BIDS App
execution, and carefully chosen defaults for anatomical and functional
MRI processing.

niflowr does **not** try to reimplement, replace, or outdo
fMRIPrep/NiPreps. It does not define a recommended preprocessing
pipeline, choose algorithms for you, or claim production-grade
preprocessing. Its narrower job is to make individual neuroimaging
command-line calls from R safer, more inspectable, and easier to compose
when you are building custom analyses, wrapping a tool that is not part
of a NiPreps workflow, using `targets`, or reading/handoffing existing
fMRIPrep derivatives.

## Installation

From the [R-universe](https://bbuchsbaum.r-universe.dev) (recommended):

``` r

install.packages("niflowr", repos = "https://bbuchsbaum.r-universe.dev")
```

Or the development version from GitHub:

``` r

# install.packages("pak")
pak::pak("bbuchsbaum/niflowr")
```

> **niflowr wraps neuroimaging tools; it does not install them.** FSL,
> AFNI, ANTs, FreeSurfer, etc. must be available on your `PATH`, or
> supplied through a Docker/Apptainer image (see [Reproducible
> execution](#reproducible-execution-engines-profiles-lockfiles)). The
> pure-R parts below —
> [`ni_cmd()`](https://bbuchsbaum.github.io/niflowr/reference/ni_cmd.md),
> [`ni_dry_run()`](https://bbuchsbaum.github.io/niflowr/reference/ni_dry_run.md),
> spec browsing, validation — work with no external binaries at all.

## A 60-second tour

**Preview the exact command** without running it — pure R, no binaries
needed:

``` r

library(niflowr)

ni_cmd(ni_call("fsl.bet",
  in_file  = "sub-01_T1w.nii.gz",
  out_file = "sub-01_desc-brain_T1w.nii.gz",
  frac     = 0.5,
  mask     = TRUE
))
#> $command
#> [1] "bet"
#> $args
#> [1] "sub-01_T1w.nii.gz" "sub-01_desc-brain_T1w.nii.gz" "-f" "0.50" "-m"
#> ...
```

**Dry-run** to see the resolved command and expected outputs together:

``` r

ni_dry_run("fsl.bet",
  in_file  = "/data/sub-01_T1w.nii.gz",
  out_file = "/out/sub-01_brain.nii.gz",
  frac     = 0.5
)
```

**Two equivalent ways to run** — a generated wrapper, or the generic
[`ni_call()`](https://bbuchsbaum.github.io/niflowr/reference/ni_call.md)
/
[`ni_run()`](https://bbuchsbaum.github.io/niflowr/reference/ni_run.md):

``` r

# Ergonomic, tab-completable wrapper
res <- ni_fsl_bet(in_file = "T1w.nii.gz", out_file = "brain.nii.gz", frac = 0.5)

# Generic equivalent — handy for programmatic / metaprogrammed pipelines
res <- ni_run(ni_call("fsl.bet",
  in_file = "T1w.nii.gz", out_file = "brain.nii.gz", frac = 0.5
))

ni_outputs(res)      # named list of produced files
ni_provenance(res)   # full record of what ran
```

**Chain steps** by piping one result into the next — niflowr pulls the
right output path automatically:

``` r

ni_fsl_bet(in_file = "T1w.nii.gz", out_file = "brain.nii.gz") |>
  ni_fsl_flirt(reference = "MNI152.nii.gz", out_file = "brain_mni.nii.gz")
```

## How it works: specs, not code

A spec is a small JSON document. This is (abridged) the one behind
[`ni_fsl_bet()`](https://bbuchsbaum.github.io/niflowr/reference/ni_fsl_bet.md):

``` json
{
  "id": "fsl.bet",
  "command": "bet",
  "inputs": {
    "in_file":  { "type": "file",   "required": true, "cli": { "argstr": "%s", "position": 0 } },
    "out_file": { "type": "file",                      "cli": { "argstr": "%s", "position": 1 } },
    "frac":     { "type": "double",                    "cli": { "argstr": "-f %.2f" } },
    "mask":     { "type": "flag",                      "cli": { "argstr": "-m" } }
  },
  "outputs": {
    "out_file": { "type": "file", "path": { "from_input": "out_file" } }
  }
}
```

From that single declaration niflowr derives the validated
[`ni_fsl_bet()`](https://bbuchsbaum.github.io/niflowr/reference/ni_fsl_bet.md)
wrapper, the argument vector, and the output path. Because the behavior
lives in data, the whole catalog is uniform — and adding or fixing a
tool is a JSON edit, not a code change.

Outputs can be taken straight from an input (`from_input`), built from a
[glue](https://glue.tidyverse.org/) `template`, or **gated on a
condition**. For instance `ants.registration_syn_quick` derives every
artifact from a single `output_prefix` and emits the warp fields only
for deformable transforms — so
[`ni_outputs()`](https://bbuchsbaum.github.io/niflowr/reference/ni_outputs.md)
always reflects what the command actually produced
(`x_0GenericAffine.mat`, `x_Warped.nii.gz`, `x_1Warp.nii.gz`, …).

## What you get

### Safe commands and real validation

Arguments are assembled as a vector and handed to `processx`, so spaces,
special characters, and paths are passed as argument values rather than
interpolated by a shell. Inputs are checked *before* execution against
the spec — types, required fields, enum choices, numeric `min`/`max`,
regex patterns, and relational constraints (`xor`, `requires`). A bad
call fails loudly in R instead of producing a cryptic tool error (or
worse, silently wrong output).

### Provenance metadata and sidecars 

When
[`ni_run()`](https://bbuchsbaum.github.io/niflowr/reference/ni_run.md)
returns an `ni_result`, that result includes provenance metadata for the
execution. Failed commands can be returned by setting
`error_on_status = FALSE`; otherwise they raise an error. When
`provenance = TRUE` (the default), the command exits successfully, and
the spec has at least one declared output, niflowr also writes a
`*_provenance.json` sidecar next to the primary output. The sidecar
captures the spec id, full command and argument vector, execution
engine/profile, input-file checksums (xxhash64), output paths, exit
status, and timing. Read it back anytime:

``` r

ni_provenance_read("sub-01_desc-brain_T1w.nii.gz_provenance.json")
```

### Reproducible execution: engines, profiles, lockfiles 

The same call runs natively or inside a container — niflowr handles path
mounting and command rewriting:

``` r

ni_fsl_bet(in_file = "T1w.nii.gz", out_file = "brain.nii.gz",
           .engine = "apptainer", .profile = "fsl")
```

`.engine` is one of `"native"`, `"docker"`, `"apptainer"`, or `"auto"`
(probe the host, then containers). A **profile** (defined in a
project-level `niflowr.yml`) maps a tool suite to a container image:

``` yaml
profiles:
  fsl:  { docker_image: "brainlife/fsl:6.0.4" }
  ants: { apptainer_uri: "docker://antsx/ants:v2.5.0" }
```

For stricter execution records,
[`ni_pin()`](https://bbuchsbaum.github.io/niflowr/reference/ni_pin.md)
records resolved image **digests** in a lockfile,
[`ni_lock_validate()`](https://bbuchsbaum.github.io/niflowr/reference/ni_lock_validate.md)
checks your environment against it, and
[`ni_doctor()`](https://bbuchsbaum.github.io/niflowr/reference/ni_doctor.md)
reports on binaries, mounts, profiles, and lock status.

### Pipelines with targets

Wrap any step as a [`targets`](https://docs.ropensci.org/targets/) file
target so outputs are tracked and only stale steps rerun:

``` r

# _targets.R
library(targets); library(niflowr)
list(
  tar_ni_step(brain, "fsl.bet",
              in_file = "sub-01_T1w.nii.gz", out_file = "sub-01_brain.nii.gz", frac = 0.5)
)
```

### BIDS-facing helpers and the neuroimaging R ecosystem

niflowr includes a small BIDS-facing adapter layer and optional
integrations with adjacent R packages:

- [`ni_deriv_path()`](https://bbuchsbaum.github.io/niflowr/reference/ni_deriv_path.md)
  — build BIDS-derivatives output paths with the right entities.
- [`ni_bids_inputs()`](https://bbuchsbaum.github.io/niflowr/reference/ni_bids_inputs.md)
  /
  [`ni_from_openneuro()`](https://bbuchsbaum.github.io/niflowr/reference/ni_from_openneuro.md)
  — query a BIDS project (via `bidser`) or pull a dataset from OpenNeuro
  (via `openneuroR`).
- [`ni_fmriprep_preproc()`](https://bbuchsbaum.github.io/niflowr/reference/ni_fmriprep_preproc.md),
  [`ni_fmriprep_confounds()`](https://bbuchsbaum.github.io/niflowr/reference/ni_fmriprep_confounds.md),
  [`ni_fmriprep_derivatives()`](https://bbuchsbaum.github.io/niflowr/reference/ni_fmriprep_derivatives.md)
  — locate and load outputs from an existing fMRIPrep derivatives
  directory.
- [`ni_bids_app()`](https://bbuchsbaum.github.io/niflowr/reference/ni_bids_app.md)
  — scaffold a BIDS App (via `bidsappr`).
- [`ni_read_output()`](https://bbuchsbaum.github.io/niflowr/reference/ni_read_output.md)
  /
  [`ni_read_transform()`](https://bbuchsbaum.github.io/niflowr/reference/ni_read_transform.md)
  — load results as `neuroim2` images or `neurotransform` transforms.

These helpers are adapters around existing BIDS datasets, derivatives,
and packages. They are not a substitute for running fMRIPrep or another
NiPreps app when that is the appropriate preprocessing tool.

### Introspection and diagnostics

``` r

ni_spec_list()           # every available spec id
ni_inputs("ants.registration")   # inputs: name, type, required, default, choices, ...
ni_constraints("ants.registration")  # xor / requires / range constraints
ni_doctor()              # environment & runtime health check
```

## Browsing the catalog

niflowr ships specs (and a matching `ni_<tool>_<command>()` wrapper) for
**300+ commands**:

| Suite | Commands | Example wrappers |
|----|---:|----|
| FSL | 96 | [`ni_fsl_bet()`](https://bbuchsbaum.github.io/niflowr/reference/ni_fsl_bet.md), [`ni_fsl_flirt()`](https://bbuchsbaum.github.io/niflowr/reference/ni_fsl_flirt.md), [`ni_fsl_eddy()`](https://bbuchsbaum.github.io/niflowr/reference/ni_fsl_eddy.md) |
| FreeSurfer | 92 | [`ni_freesurfer_recon_all()`](https://bbuchsbaum.github.io/niflowr/reference/ni_freesurfer_recon_all.md), [`ni_freesurfer_synthstrip()`](https://bbuchsbaum.github.io/niflowr/reference/ni_freesurfer_synthstrip.md) |
| AFNI | 80 | [`ni_afni_calc()`](https://bbuchsbaum.github.io/niflowr/reference/ni_afni_calc.md), [`ni_afni_volreg()`](https://bbuchsbaum.github.io/niflowr/reference/ni_afni_volreg.md) |
| ANTs | 34 | [`ni_ants_registration()`](https://bbuchsbaum.github.io/niflowr/reference/ni_ants_registration.md), [`ni_ants_apply_transforms()`](https://bbuchsbaum.github.io/niflowr/reference/ni_ants_apply_transforms.md), [`ni_ants_transform_build()`](https://bbuchsbaum.github.io/niflowr/reference/ni_ants_transform_build.md) |
| FastSurfer | 2 | [`ni_fastsurfer_run()`](https://bbuchsbaum.github.io/niflowr/reference/ni_fastsurfer_run.md), [`ni_fastsurfer_segment()`](https://bbuchsbaum.github.io/niflowr/reference/ni_fastsurfer_segment.md) |
| dcm2niix | 1 | [`ni_dcm2niix_convert()`](https://bbuchsbaum.github.io/niflowr/reference/ni_dcm2niix_convert.md) |

``` r

length(ni_spec_list())
#> [1] 305
```

## Extending niflowr

Adding a tool is writing a JSON spec — no R required. Drop a
`mytool.command.json` file in `inst/specs/` (or point
[`ni_spec_read()`](https://bbuchsbaum.github.io/niflowr/reference/ni_spec_read.md)
/
[`ni_call()`](https://bbuchsbaum.github.io/niflowr/reference/ni_call.md)
at any path), validate it, and you have a working interface:

``` r

ni_lint_specs("path/to/specs")   # schema + sanity checks (shell metachars, position clashes, ...)
ni_call("path/to/mytool.command.json", input = "x.nii.gz") |> ni_cmd()
```

Specs that need bespoke argument grammar (e.g. ANTs’ staged
`antsRegistration`) can declare a `render` hook backed by a registered
builder. See the **Extending niflowr** article for the full guide.

## What niflowr is — and isn’t

- ✅ A consistent, validated, provenance-tracked R interface to existing
  neuroimaging CLIs.
- ✅ A safe command builder and runner with native + container
  execution.
- ✅ A command layer you can use inside reproducible `targets`
  pipelines.
- ✅ A handoff layer for reading and composing existing BIDS/fMRIPrep
  derivatives.
- ❌ Not an installer or distributor of FSL/AFNI/ANTs/FreeSurfer — you
  bring the tools (or a container).
- ❌ Not an fMRIPrep/NiPreps replacement; for standard end-to-end fMRI
  preprocessing, use those projects.
- ❌ Not a recommended preprocessing pipeline or algorithm-selection
  framework — it runs the tools you ask it to run.
- ❌ Not a workflow engine — that’s what `targets`/`crew` are for.

niflowr is **experimental** (v0.1.0): the spec schema and API may still
change.

## Documentation

- **Getting started** — the core workflow end to end.
- **Extending niflowr** — authoring specs and custom renderers.
- **OpenNeuro pipeline**, **fmriprepper handoff**, **bidsappr
  integration** — ecosystem recipes.

(Run `browseVignettes("niflowr")`, or see the
[`vignettes/`](https://bbuchsbaum.github.io/niflowr/vignettes/)
directory.)

## License

MIT © Bradley Buchsbaum. See
[LICENSE](https://bbuchsbaum.github.io/niflowr/LICENSE).
