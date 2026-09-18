# Normalise a nested list input to one atomic vector per element

Matrix rows are elements
([`jsonlite::fromJSON()`](https://jeroen.r-universe.dev/jsonlite/reference/fromJSON.html)
simplifies equal-length ladders to a matrix), and `NULL` entries inside
an element become `NA` so they keep their position (`read_json()` yields
`NULL` for JSON `null`).

## Usage

``` r
ni_nested_items(value)
```
