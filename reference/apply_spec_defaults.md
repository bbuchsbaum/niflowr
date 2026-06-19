# Fill missing inputs with their declared spec defaults

Defaults are intentionally NOT injected into the generic command builder
(that would change long-standing rendered output); this helper is used
only where defaults are genuinely needed, e.g. resolving output
templates and conditional outputs, and inside custom renderers.

## Usage

``` r
apply_spec_defaults(spec, values)
```
