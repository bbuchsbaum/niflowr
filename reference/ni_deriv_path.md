# Generate a BIDS-derivatives output path

Constructs an output path following BIDS-derivatives conventions.

## Usage

``` r
ni_deriv_path(
  input_path,
  derivatives_dir = "derivatives/niflowr",
  desc = NULL,
  space = NULL,
  suffix = NULL,
  extension = ".nii.gz"
)
```

## Arguments

- input_path:

  The input file path (a BIDS-formatted path).

- derivatives_dir:

  Base derivatives directory. Default: `"derivatives/niflowr"`.

- desc:

  Description entity (e.g. `"brain"`, `"preproc"`).

- space:

  Space entity (e.g. `"MNI152NLin2009cAsym"`).

- suffix:

  Override the BIDS suffix (e.g. `"T1w"`, `"bold"`).

- extension:

  File extension. Default: `".nii.gz"`.

## Value

A character string with the derivatives output path.
