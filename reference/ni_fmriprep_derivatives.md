# List fMRIPrep derivatives overview

Summarizes what's available in an fMRIPrep derivatives directory by
subject.

## Usage

``` r
ni_fmriprep_derivatives(deriv_dir, subid = NULL)
```

## Arguments

- deriv_dir:

  Path to the fMRIPrep derivatives directory.

- subid:

  Subject ID filter (without "sub-" prefix). Default: `NULL` (all
  subjects).

## Value

A data.frame with columns: `subject`, `has_anat`, `has_func`,
`n_anat_files`, `n_func_files`.

## Examples

``` r
if (FALSE) { # \dontrun{
overview <- ni_fmriprep_derivatives("derivatives/fmriprep")
print(overview)
} # }
```
