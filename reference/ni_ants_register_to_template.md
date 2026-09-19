# Register a T1w image to a T1w template with a pinned preset

Runs `antsRegistration` (Rigid, Affine, then SyN) with a schedule from
[`ni_ants_template_preset()`](https://bbuchsbaum.github.io/niflowr/reference/ni_ants_template_preset.md),
writing the moving image resampled into the template and the ITK
composite transforms (`<prefix>Composite.h5` and
`<prefix>InverseComposite.h5`), the form fMRIPrep writes.

## Usage

``` r
ni_ants_register_to_template(
  fixed_image,
  moving_image,
  output_prefix,
  preset = c("precise", "testing"),
  ...,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  timeout = Inf,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- fixed_image:

  The template (reference) image, usually brain-extracted.

- moving_image:

  The T1w image to register, brain-extracted like the template.

- output_prefix:

  Path prefix for the transforms and the warped image
  (`<prefix>Warped.nii.gz`).

- preset:

  Preset name; see
  [`ni_ants_template_preset()`](https://bbuchsbaum.github.io/niflowr/reference/ni_ants_template_preset.md).

- ...:

  Named `ants.registration` inputs that replace preset values whole,
  e.g. `random_seed = 1` or `fixed_image_mask = "mask.nii.gz"`. `NULL`
  removes a preset value. Related values are not adjusted: replacing
  `metric` keeps the preset's `radius_or_number_of_bins`. Giving
  `initial_moving_transform` drops the preset's
  `initial_moving_transform_com`, since only one initialisation applies.

- .cwd:

  Working directory override.

- .env:

  Named character vector of environment variables.

- .engine:

  Execution engine override.

- .profile:

  Runtime profile override.

- timeout:

  Seconds before the registration is stopped.

- dry_run:

  Logical; preview command without executing.

- echo:

  Logical; echo stdout/stderr in real time.

## Value

An `ni_result` (or an execution plan when `dry_run = TRUE`).

## Details

This is a named preset, not the default of
[`ni_ants_registration()`](https://bbuchsbaum.github.io/niflowr/reference/ni_ants_registration.md):
the `"precise"` schedule is tuned for about 1 mm T1w-to-template
registration and is the wrong schedule for other modalities or
resolutions. A registration can run, write a transform, and not fold
while still stopping at a poor optimum, so check it with
[`ni_ants_registration_qa()`](https://bbuchsbaum.github.io/niflowr/reference/ni_ants_registration_qa.md).

## See also

[`ni_ants_registration_qa()`](https://bbuchsbaum.github.io/niflowr/reference/ni_ants_registration_qa.md)

## Examples

``` r
if (FALSE) { # \dontrun{
reg <- ni_ants_register_to_template(
  fixed_image = "/data/tpl-MNI152NLin2009cAsym_res-01_desc-brain_T1w.nii.gz",
  moving_image = "/data/sub-01_desc-brain_T1w.nii.gz",
  output_prefix = "/data/out/sub-01_from-T1w_to-MNI_"
)
ni_ants_registration_qa(reg,
  fixed_mask = "/data/tpl-MNI152NLin2009cAsym_res-01_desc-brain_mask.nii.gz",
  moving_mask = "/data/sub-01_desc-brain_mask.nii.gz"
)
} # }
```
