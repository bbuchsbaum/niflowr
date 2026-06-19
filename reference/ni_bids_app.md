# Create a bidsappr-based BIDS App pre-configured with niflowr

Scaffolds a BIDS App using `bidsappr::new_app()` and creates a template
`app.R` with niflowr integration. The generated app includes example
usage of niflowr functions and can be customized with tool-specific
examples.

## Usage

``` r
ni_bids_app(path, app_name = basename(path), tools = NULL)
```

## Arguments

- path:

  Directory path where the app will be created.

- app_name:

  Name of the BIDS App. Default: basename of `path`.

- tools:

  Optional character vector of spec IDs (e.g.,
  `c("fsl.bet", "ants.registration")`) to include as commented-out
  examples in the generated app.

## Value

Invisibly returns the path to the created app directory.

## Examples

``` r
if (FALSE) { # \dontrun{
# Create a basic BIDS App
ni_bids_app("~/my_bids_app", app_name = "MyApp")

# Create an app with tool examples
ni_bids_app("~/my_bids_app", tools = c("fsl.bet", "ants.registration"))
} # }
```
