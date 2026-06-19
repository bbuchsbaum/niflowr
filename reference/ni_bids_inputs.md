# Query a BIDS project for inputs matching a spec

Uses `bidser::bids_project` to discover files matching a spec's input
requirements.

## Usage

``` r
ni_bids_inputs(
  project,
  spec_id,
  subid = NULL,
  task = NULL,
  session = NULL,
  run = NULL,
  modality = NULL
)
```

## Arguments

- project:

  A `bids_project` object (from `bidser::bids_project()`).

- spec_id:

  Spec ID or `ni_spec` object.

- subid:

  Subject ID filter.

- task:

  Task filter.

- session:

  Session filter.

- run:

  Run filter.

- modality:

  Image modality to search for (e.g. `"T1w"`, `"bold"`).

## Value

A data.frame with a `path` column containing matched file paths.
