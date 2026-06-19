# Construct an ni_call: bind parameter values to a spec

Creates a validated call object that captures a spec plus concrete
parameter values, ready for execution or dry-run preview.

## Usage

``` r
ni_call(
  spec_id,
  ...,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  .validate = TRUE
)
```

## Arguments

- spec_id:

  A spec ID (e.g. `"fsl.bet"`), path to a JSON file, or an `ni_spec`
  object.

- ...:

  Named parameter values.

- .cwd:

  Working directory override.

- .env:

  Named character vector of environment variables.

- .engine:

  Execution engine override. One of `"auto"`, `"native"`, `"docker"`,
  `"apptainer"`.

- .profile:

  Runtime profile override (maps to `profiles` entry in `niflowr.yml`).

- .validate:

  Logical; validate inputs at construction time. Default `TRUE`.

## Value

An `ni_call` object (S3 list).
