# Spec overrides

Nipype-derived specs are regenerated from `nipype` by
[`../import_nipype_specs.py`](../import_nipype_specs.py), and the
`Nipype Spec Drift` CI check fails if the committed specs differ from a fresh
regeneration. That keeps the imported interfaces honest, but Nipype cannot
express **niflowr-only** fields — custom renderers (`render`), declared
`outputs`, or input tweaks like `required`.

Each `<spec_id>.json` file here is **deep-merged onto the generated spec** (the `outputs` and `constraints` maps are replaced as a whole to remove invalid imported declarations) for
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

- `ants.registration.json` — adds the staged `render` hook, the per-stage inputs Nipype declares without an argstr (transform parameters, iterations, convergence, metric bins, sampling), numeric winsorize quantiles, warped-image outputs, and composite-transform outputs with transform metadata.
- `ants.apply_transforms.json`, `ants.measure_image_similarity.json` — route both through custom renderers, since Nipype formats `--transform`, `--interpolation`, `--output [field,1]`, and the `--metric` token in Python rather than in argstrs; `ants.create_jacobian_determinant_image.json` declares its output image.
- `ants.registration_syn_quick.json` — declares prefix-derived `outputs` and marks `output_prefix` required.
- `fsl.mcflirt.json` — marks `out_file` with `cli.strip_ext` and declares gated side outputs (`.par`, `.mat/`, `_mean_reg`, …).
- `fsl.image_meants.json` — keeps text-matrix `-o` paths intact (`strip_ext=false`) and requires `out_file` to exist.
- `freesurfer.mp_rto_mni305.json` — restores a hand-written input description Nipype doesn't provide.
- `fsl.flirt.json`, `ants.ai.json`, `afni.allineate.json`, `freesurfer.mri_coreg.json`, … — declare `outputs.<name>.transform` (kind, format, source/target inputs) so `ni_read_transform()` never guesses a registration output's convention. Because `outputs` is replaced wholesale, these overrides carry the full outputs map.

To customize a Nipype spec, add or edit the matching file here, rerun the
pipeline above, and commit the regenerated `inst/specs/<id>.json`.

Overrides also preserve adopted path, list-element, and numeric-type corrections
that Nipype trait inference cannot reproduce. These do not broaden interface
qualification; they prevent regeneration from reverting existing fixes.
