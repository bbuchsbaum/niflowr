# From fMRIPrep to post-processing with niflowr

## Introduction

The **fmriprepper** package orchestrates fMRIPrep execution — it builds
commands, handles batch submission, and integrates with HPC schedulers.
The **niflowr** package handles post-fMRIPrep processing — additional
skull stripping, registration to custom templates, ROI extraction, and
building reproducible pipelines with targets.

This vignette shows how to chain them together for a complete
preprocessing and analysis workflow.

## The workflow

    Raw BIDS data
        ↓
    fmriprepper (orchestrate fMRIPrep)
        ↓
    fMRIPrep derivatives (preprocessed data)
        ↓
    niflowr (post-processing)
        ↓
    Final results

## Step 1: Preprocess with fmriprepper

Use the fmriprepper fluent API to configure and run fMRIPrep:

``` r

library(fmriprepper)

plan <- fmriprep()$
  bids("/data/bids")$
  out("/data/derivatives")$
  engine_singularity(image = "/images/fmriprep.sif")$
  participant_labels(c("01", "02", "03"))$
  nprocs(16)$
  omp_nthreads(8)$
  spaces_all()

# Run locally (or use plan$write_slurm_array("submit.sbatch") for HPC)
plan$run()
```

## Step 2: Inspect fMRIPrep outputs

Once fMRIPrep completes, use niflowr to explore the derivatives:

``` r

library(niflowr)

# List all derivatives for a subject
ni_fmriprep_derivatives("/data/derivatives/fmriprep")

# Get preprocessed anatomical and functional files
preproc <- ni_fmriprep_preproc(
  "/data/derivatives/fmriprep",
  subid = "01",
  space = "MNI152NLin2009cAsym"
)

print(preproc)
```

## Step 3: Read confounds

Extract motion and nuisance regressors for denoising:

``` r

confounds <- ni_fmriprep_confounds(
  "/data/derivatives/fmriprep",
  subid = "01",
  task = "rest",
  select = c("trans_x", "trans_y", "trans_z", "rot_x", "rot_y", "rot_z")
)

head(confounds)
```

## Step 4: Post-process with niflowr

Register fMRIPrep output to a custom template:

``` r

preproc <- ni_fmriprep_preproc(
  "/data/derivatives/fmriprep",
  subid = "01",
  suffix = "T1w",
  space = "MNI152NLin2009cAsym"
)

result <- ni_ants_registration(
  fixed_image = "custom_template.nii.gz",
  moving_image = preproc$path[1],
  output_transform_prefix = ni_deriv_path(preproc$path[1], desc = "customreg")
)
```

Extract ROI timeseries from functional data:

``` r

func_preproc <- ni_fmriprep_preproc(
  "/data/derivatives/fmriprep",
  subid = "01",
  task = "rest",
  suffix = "bold",
  space = "MNI152NLin2009cAsym"
)

roi_data <- ni_extract_roi(
  func_preproc$path[1],
  mask = "atlas_roi_001.nii.gz",
  method = "mean"
)
```

## Full pipeline with targets

Here’s a complete pipeline that combines fmriprepper and niflowr using
the targets package:

``` r

# _targets.R
library(targets)
library(niflowr)

list(
  tar_target(deriv_dir, "/data/derivatives/fmriprep"),

  tar_target(subjects, ni_fmriprep_derivatives(deriv_dir)$subject),

  tar_target(
    preproc,
    ni_fmriprep_preproc(deriv_dir, subid = subjects, suffix = "T1w"),
    pattern = map(subjects)
  ),

  tar_ni_step(
    registered,
    "ants.registration",
    fixed_image = "template.nii.gz",
    moving_image = preproc$path[1],
    output_transform_prefix = ni_deriv_path(preproc$path[1], desc = "customreg"),
    pattern = map(preproc)
  ),

  tar_target(
    func_preproc,
    ni_fmriprep_preproc(deriv_dir, subid = subjects, task = "rest", suffix = "bold"),
    pattern = map(subjects)
  ),

  tar_target(
    confounds,
    ni_fmriprep_confounds(
      deriv_dir,
      subid = subjects,
      task = "rest",
      select = c("trans_x", "trans_y", "trans_z", "rot_x", "rot_y", "rot_z")
    ),
    pattern = map(subjects)
  )
)
```

## Tips

**Check completion status:** Before starting niflowr post-processing,
verify that fMRIPrep completed successfully for all subjects. The
fmriprepper package provides `is_completed()` to check for expected
output files.

**Handle missing subjects:** Not all subjects may complete successfully.
Use
[`ni_fmriprep_derivatives()`](https://bbuchsbaum.github.io/niflowr/reference/ni_fmriprep_derivatives.md)
to discover which subjects have valid outputs, then filter your subject
list accordingly.

**HPC considerations:** For large datasets, use fmriprepper’s SLURM
array integration (`write_slurm_array()`) to parallelize fMRIPrep across
subjects. Once derivatives are ready, use targets with a parallel
backend (`tar_make_future()`) to scale niflowr post-processing.

**Version tracking:** Both packages write provenance metadata. Check
`dataset_description.json` in fMRIPrep derivatives and niflowr’s
container runtime metadata to ensure reproducibility.
