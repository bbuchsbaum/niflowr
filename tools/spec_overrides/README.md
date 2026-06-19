# Spec overrides

Nipype-derived specs are regenerated from `nipype` by
[`../import_nipype_specs.py`](../import_nipype_specs.py), and the
`Nipype Spec Drift` CI check fails if the committed specs differ from a fresh
regeneration. That keeps the imported interfaces honest, but Nipype cannot
express **niflowr-only** fields — custom renderers (`render`), declared
`outputs`, or input tweaks like `required`.

Each `<spec_id>.json` file here is **deep-merged onto the generated spec** for
that id during import (see `apply_spec_override()` in the importer). This lets
niflowr-specific additions survive regeneration instead of being overwritten.

The full pipeline that must reproduce the committed specs is:

```sh
python tools/import_nipype_specs.py \
  --discover-root nipype.interfaces.fsl \
  --discover-root nipype.interfaces.afni \
  --discover-root nipype.interfaces.ants \
  --discover-root nipype.interfaces.freesurfer \
  --overwrite --omit-imported-at        # stage 1: import + override merge
Rscript -e 'pkgload::load_all("."); ni_lint_specs("inst/specs", fix = TRUE, write = TRUE)'
                                        # stage 2: normalize (argstr/xor/position)
```

An override is a partial spec; only the keys you set are merged. Examples:

- `ants.registration.json` — adds the staged `render` hook.
- `ants.registration_syn_quick.json` — declares prefix-derived `outputs` and marks `output_prefix` required.
- `freesurfer.mp_rto_mni305.json` — restores a hand-written input description Nipype doesn't provide.

To customize a Nipype spec, add or edit the matching file here, rerun the
pipeline above, and commit the regenerated `inst/specs/<id>.json`.
