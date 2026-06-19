# Read an output from an ni_result as a neuroim2 object

Loads an output file using `neuroim2::read_vol()` or
`neuroim2::read_vec()` based on file dimensionality.

## Usage

``` r
ni_read_output(result, output_name = NULL, ...)
```

## Arguments

- result:

  An `ni_result` object.

- output_name:

  Name of the output to read. If `NULL`, reads the first output.

- ...:

  Additional arguments passed to the neuroim2 reader.

## Value

A neuroim2 object (`NeuroVol` or `NeuroVec`).
