# Nipype Spec Import

`niflowr` specs can be generated from Nipype interface metadata.

## Quick start

```bash
python tools/import_nipype_specs.py \
  --manifest tools/nipype_manifest.json \
  --overwrite
```

## Single-interface import

```bash
python tools/import_nipype_specs.py \
  --interface nipype.interfaces.fsl.preprocess:BET \
  --interface nipype.interfaces.fsl.preprocess:FLIRT \
  --overwrite
```

## Discover many interfaces automatically

Generate specs by scanning Nipype module roots:

```bash
python tools/import_nipype_specs.py \
  --discover-root nipype.interfaces.fsl \
  --discover-root nipype.interfaces.afni \
  --discover-root nipype.interfaces.ants \
  --discover-root nipype.interfaces.freesurfer \
  --overwrite \
  --omit-imported-at
```

Optional filters:

```bash
# Keep only classes whose fully-qualified name matches regex
python tools/import_nipype_specs.py \
  --discover-root nipype.interfaces.fsl \
  --discover-regex "preprocess\\.(BET|FLIRT|FAST)$" \
  --overwrite

# Limit discovered interfaces
python tools/import_nipype_specs.py \
  --discover-root nipype.interfaces.fsl \
  --discover-max 25 \
  --overwrite
```

## Notes

- The script sets `origin.source = "nipype"` and records `nipype_class`,
  `nipype_version`, and `imported_at`.
- Output path inference is best-effort; unresolved outputs are skipped unless
  `--include-unresolved-outputs` is set.
- By default, non-CLI optional inputs are skipped to reduce spec noise.
- For deterministic CI output, use:

```bash
python tools/import_nipype_specs.py \
  --manifest tools/nipype_manifest.json \
  --overwrite \
  --omit-imported-at
```

## Lint + Golden Cmdline Fixtures

After import, normalize specs and regenerate command snapshots:

```bash
Rscript tools/lint_specs.R --fix
Rscript tools/gen_golden_cmdline.R
```

- `tools/lint_specs.R --fix` rewrites shell-style arg strings (e.g. `> %s`,
  `|& tee %s`) into runner-level redirects.
- `tools/gen_golden_cmdline.R` writes
  `tests/golden/cmdline_golden.json` for regression testing.
