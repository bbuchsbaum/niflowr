# Coerce a value to match the printf conversion in an argstr

Enum/choice coercion stores values as character, but numeric printf
conversions (`%d`, `%f`, ...) require numeric input or
[`sprintf()`](https://rdrr.io/r/base/sprintf.html) errors and the
literal placeholder leaks into the rendered argument. Inspect the first
conversion specifier and coerce accordingly. If coercion is not safe
(would introduce `NA`, or is non-integral for an integer conversion),
the value is returned untouched so the existing fallback path still
applies.

## Usage

``` r
coerce_for_argstr(value, argstr)
```
