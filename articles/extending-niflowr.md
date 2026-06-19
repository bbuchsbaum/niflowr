# Extending niflowr: wrap a new tool

Eventually you will hit a tool niflowr does not ship a wrapper for —
yesterday’s preprint, your lab’s in-house segmenter, a flag the upstream
spec never bothered to expose. Adding it is small work: write a JSON
spec, call a generator, ship a wrapper. This vignette walks through the
loop end-to-end using FreeSurfer’s SynthStrip as the worked example.

## The mental model

Every wrapper in niflowr is built from three artefacts:

| Artefact | Where it lives | Who writes it |
|:---|:---|:---|
| **Spec** — a JSON description of inputs, outputs, and CLI rendering | `inst/specs/<id>.json` | You |
| **Wrapper** — an `ni_*()` R function | `R/wrappers_auto.R` | `tools/gen_wrappers.R` |
| **Profile** — how the binary is run (native / docker / apptainer) | `niflowr.yml` | The user, at project level |

The spec is the source of truth. Wrappers and golden command-line
fixtures are regenerated from it. Profiles are kept separate so that the
same spec can run natively in CI, in a Docker container on a laptop, and
under Apptainer on a cluster — without changes to the spec itself.

## First win: a 12-line spec

Let’s wrap `mri_synthstrip` with the bare minimum: the input volume and
the brain-mask output. We’ll write the spec to a tempfile so the
vignette can run end-to-end without touching the package source.

``` r

spec_path <- tempfile(fileext = ".json")
writeLines(c(
  '{',
  '  "spec_version": "0.1.0",',
  '  "id": "demo.synthstrip",',
  '  "title": "SynthStrip (demo)",',
  '  "command": "mri_synthstrip",',
  '  "inputs": {',
  '    "in_file":   {"type": "file", "required": true,',
  '                  "cli": {"argstr": "-i %s"}},',
  '    "mask_file": {"type": "file",',
  '                  "cli": {"argstr": "-m %s"}}',
  '  },',
  '  "outputs": {',
  '    "mask_file": {"type": "file",',
  '                  "path": {"from_input": "mask_file"},',
  '                  "must_exist": false}',
  '  },',
  '  "runtime": {"profile": "freesurfer"}',
  '}'
), spec_path)
```

Now load it and build a call:

``` r

spec <- ni_spec_read(spec_path)

call <- ni_call(spec,
  in_file   = system.file("DESCRIPTION", package = "niflowr"),
  mask_file = "/tmp/T1_mask.nii.gz",
  .engine   = "native"
)

ni_cmd(call)
#> $command
#> [1] "mri_synthstrip"
#> 
#> $args
#> [1] "-i"                                                 
#> [2] "/home/runner/work/_temp/Library/niflowr/DESCRIPTION"
#> [3] "-m"                                                 
#> [4] "/tmp/T1_mask.nii.gz"                                
#> 
#> $wd
#> NULL
#> 
#> $env
#> NULL
#> 
#> $engine
#> [1] "native"
#> 
#> $profile
#> NULL
#> 
#> $stdout
#> NULL
#> 
#> $stderr
#> NULL
```

That’s it. The spec file plus
[`ni_spec_read()`](https://bbuchsbaum.github.io/niflowr/reference/ni_spec_read.md)
plus
[`ni_call()`](https://bbuchsbaum.github.io/niflowr/reference/ni_call.md)
is enough to render a safe, validated command-line vector. No shell
strings, no `paste0` — niflowr keeps the command and its arguments
separate so they can never collide with shell metacharacters.

A `dry_run` confirms the wiring without invoking the binary:

``` r

ni_run(call, dry_run = TRUE, echo = FALSE)
```

## Anatomy of a spec

The minimal spec hides most of the moving parts. Here is what an input
definition can carry:

``` json
"frac": {
  "type": "double",
  "desc": "Fractional intensity threshold",
  "default": 0.5,
  "validate": {"min": 0, "max": 1},
  "cli": {"argstr": "-f %.2f"},
  "constraints": {"xor": ["robust"]}
}
```

The four blocks that matter:

- **`type`** — one of `file`, `dir`, `string`, `int`, `double`, `bool`,
  `flag`, `enum`, `list`. Drives R coercion and the wrapper’s `@param`
  documentation.
- **`validate`** — fail fast at
  [`ni_call()`](https://bbuchsbaum.github.io/niflowr/reference/ni_call.md)-time.
  `exists` (file/dir must be present), `min`/`max` (numeric range),
  `regex` (string pattern). Errors here surface as clean
  [`cli::cli_abort()`](https://cli.r-lib.org/reference/cli_abort.html)
  messages instead of mysterious crashes inside the binary.
- **`cli.argstr`** — a `printf`-style format string. `%s` for files /
  strings, `%d` for ints, `%.2f` etc. for doubles. Flags use a literal
  switch like `-g` (no `%`).
- **`constraints`** — `xor` (mutually exclusive) and `requires`
  (co-required). Validated at call time.

### Positional vs. switched arguments

Most CLIs mix the two. niflowr handles both with the same shape:

``` json
"in_file":  {"type": "file", "required": true,
             "cli": {"argstr": "%s", "position": 0}},
"out_file": {"type": "file",
             "cli": {"argstr": "%s", "position": 1}},
"frac":     {"type": "double",
             "cli": {"argstr": "-f %.2f"}}
```

`position` orders positional args (negative values count from the end —
useful for trailing arguments like `mri_watershed in.mgz out.mgz`).
Switched arguments render in alphabetical order before positionals, so
the shape is deterministic and golden-testable.

### Output paths come from inputs

Outputs declare *where* the artefact lands so downstream code (targets,
BIDS-aware tools, `ni_result$outputs`) can find it:

| Pattern | Use when |
|:---|:---|
| `{"from_input": "out_file"}` | the user passes the path explicitly |
| `{"template": "{sd}/{sid}/mri/aseg.mgz"}` | the path is computed from other inputs (glue interpolation) |
| `{"static": "results.txt"}` | the tool always writes to a fixed name in cwd |

Set `must_exist: false` when the output is optional (e.g. SynthStrip’s
`-m` and `-d` only produce files when the user requested them).

### Runtime profile

``` json
"runtime": {"profile": "freesurfer"}
```

The profile name is a *contract*, not a binding. Users wire profile
names to docker images / apptainer SIFs / native paths in their own
`niflowr.yml`. Pick a profile name that matches the binary’s natural
home: `freesurfer`, `fsl`, `ants`, `afni`, or a new one. If you invent a
new profile, document the docker image users will likely point it at.

## Object zoo

Three classes carry your call through the system:

| Class | Constructor | What it holds |
|:---|:---|:---|
| `ni_spec` | [`ni_spec_read()`](https://bbuchsbaum.github.io/niflowr/reference/ni_spec_read.md) | Parsed spec — inputs, outputs, command, runtime |
| `ni_call` | [`ni_call()`](https://bbuchsbaum.github.io/niflowr/reference/ni_call.md) | Spec + bound input values, validated, ready to render |
| `ni_result` | [`ni_run()`](https://bbuchsbaum.github.io/niflowr/reference/ni_run.md) | Exit status, captured stdout/stderr, resolved output paths, provenance |

You’ll write specs and read results. The `ni_call` in the middle is what
`dry_run`,
[`ni_cmd()`](https://bbuchsbaum.github.io/niflowr/reference/ni_cmd.md),
and the golden-fixture harness all operate on.

## Promoting a spec from local to bundled

Working from a tempfile is fine for one-off experiments. To ship the
wrapper as part of a package (your fork of niflowr, or a downstream
package that depends on it), promote the spec through the package
development loop:

**1. Drop the spec in `inst/specs/`.** Naming convention is
`<profile>.<tool>.json`, with the spec `id` matching the filename:

    inst/specs/freesurfer.synthstrip.json

**2. Lint it.** This catches shell metacharacters, positional
collisions, malformed flags, and constraint references that point at
inputs that don’t exist:

``` r

ni_lint_specs(strict = TRUE)
```

In `fix = TRUE` mode the linter rewrites the safe cases in place (`> %s`
→ `stdout_to`, dropped duplicate positions, normalised constraint
arrays).

**3. Regenerate the wrapper.** This produces `R/wrappers_auto.R` from
*all* specs in `inst/specs/` — your new one and the existing 300+:

``` sh
Rscript tools/gen_wrappers.R
```

A wrapper named
[`ni_freesurfer_synthstrip()`](https://bbuchsbaum.github.io/niflowr/reference/ni_freesurfer_synthstrip.md)
now exists, with one `@param` per input and `dry_run` / `echo` / `.cwd`
/ `.engine` / `.profile` controls.

**4. Update NAMESPACE and man pages.**

``` sh
Rscript -e 'roxygen2::roxygenise(".")'
```

**5. Refresh the golden command-line fixture.** This is the regression
test that protects against accidental CLI changes — every spec gets a
deterministic input/output snapshot:

``` sh
Rscript tools/gen_golden_cmdline.R
```

**6. Write a test.** Mirror the pattern from
`tests/testthat/test-fastsurfer.R` or
`tests/testthat/test-freesurfer-synthstrip.R`: load the spec, build a
call with synthetic temp files, assert the rendered `cmd$args`, and
finish with a `dry_run` smoke test.

``` r

test_that("freesurfer.synthstrip renders core CLI args", {
  in_file <- withr::local_tempfile(fileext = ".nii.gz")
  file.create(in_file)
  call <- ni_call("freesurfer.synthstrip",
    in_file = in_file,
    mask_file = "/tmp/mask.nii.gz",
    gpu = TRUE
  )
  cmd <- ni_cmd(call)
  expect_equal(cmd$command, "mri_synthstrip")
  expect_true(all(c("-i", in_file) %in% cmd$args))
  expect_true(all(c("-m", "/tmp/mask.nii.gz") %in% cmd$args))
  expect_true("-g" %in% cmd$args)
})
```

That’s the entire loop. The bundled
`inst/specs/freesurfer.synthstrip.json` is the full version of the
example we built above — about 70 lines, covering `-i`, `-o`, `-m`,
`-d`, `-b`, `-g`, `-t`, `--no-csf`, and `--model`. Read it next to this
vignette to see the moving parts in their natural habitat.

## Avoid these traps

A few things the linter will catch but are easier to get right the first
time:

- **Don’t put `%` placeholders on `flag` types.** A flag is presence /
  absence — its argstr is the literal switch (`-g`, not `-g %s`).
- **Don’t redirect with shell metacharacters.** `"argstr": "> %s"` is
  illegal because niflowr never invokes a shell. Use
  `cli.stdout_to: "out_file"` instead — the runner handles redirection
  itself.
- **Don’t use the same `position` for two required inputs.** Use
  distinct integers, or negative positions for trailing args.
- **Validate at the boundary.** Numeric ranges, regex patterns, and
  `exists: true` are far cheaper than a half-completed run that crashes
  inside the binary.

## Next steps

- The schema lives at `inst/schema/niflowr-spec-0.1.0.json` — every
  field above is documented there.
- Existing specs in `inst/specs/` are the best reference. `fsl.bet.json`
  shows `xor` constraints in anger; `fastsurfer.run.json` shows
  `template` output paths; `freesurfer.synthmorph_register.json` shows
  trailing positionals via negative `position`.
- See
  [`vignette("niflowr")`](https://bbuchsbaum.github.io/niflowr/articles/niflowr.md)
  for the user-facing workflow, including container profiles and
  [targets](https://docs.ropensci.org/targets/) integration.
