# Normalize optional per-profile Docker `--entrypoint` override.

`NULL` means leave the image ENTRYPOINT unchanged. An empty string or
empty list clears the ENTRYPOINT (useful for images whose entrypoint is
a shell that silently ignores the payload command).

## Usage

``` r
ni_normalize_docker_entrypoint(entrypoint, profile = NULL)
```

## Value

List with `set` (logical) and `value` (character scalar or NULL).
