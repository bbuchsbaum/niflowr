# Read a pinned T1w-to-template registration preset

Presets are complete `ants.registration` schedules stored with their
provenance and cost.

## Usage

``` r
ni_ants_template_preset(preset = c("precise", "testing"))
```

## Arguments

- preset:

  Preset name: `"precise"` or `"testing"`.

## Value

A list with `name`, `title`, `intended_for`, `provenance`, `cost`, and
`values` (the `ants.registration` inputs, without images or output
paths).

## Details

- `"precise"`: the schedule measured in niflowr issue \#29 against
  fMRIPrep 25.x's T1w-to-MNI152NLin2009cAsym transform, which it matched
  within noise on two participants (about 17 min with 8 threads at 1
  mm). Tuned for a brain-extracted T1w to a brain-extracted T1w template
  at about 1 mm; not for EPI-to-T1w, low-resolution, or non-brain data.

- `"testing"`: the same stage structure with a handful of iterations,
  for exercising pipelines. Deliberately under-converged; never analyse
  its transforms.

## See also

[`ni_ants_register_to_template()`](https://bbuchsbaum.github.io/niflowr/reference/ni_ants_register_to_template.md),
[`ni_ants_registration_qa()`](https://bbuchsbaum.github.io/niflowr/reference/ni_ants_registration_qa.md)

## Examples

``` r
preset <- ni_ants_template_preset("precise")
preset$cost
#> [1] "About 17 min with 8 threads for a 1 mm T1w to MNI152NLin2009cAsym res-01, roughly 2.4 times antsRegistrationSyN.sh -t s."
preset$values$number_of_iterations
#> [[1]]
#> [[1]][[1]]
#> [1] 1000
#> 
#> [[1]][[2]]
#> [1] 500
#> 
#> [[1]][[3]]
#> [1] 250
#> 
#> [[1]][[4]]
#> [1] 100
#> 
#> 
#> [[2]]
#> [[2]][[1]]
#> [1] 1000
#> 
#> [[2]][[2]]
#> [1] 500
#> 
#> [[2]][[3]]
#> [1] 250
#> 
#> [[2]][[4]]
#> [1] 100
#> 
#> 
#> [[3]]
#> [[3]][[1]]
#> [1] 100
#> 
#> [[3]][[2]]
#> [1] 100
#> 
#> [[3]][[3]]
#> [1] 70
#> 
#> [[3]][[4]]
#> [1] 50
#> 
#> [[3]][[5]]
#> [1] 20
#> 
#> 
```
