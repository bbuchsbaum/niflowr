# Probe whether a Docker profile image executes the payload command.

Only runs against images already present locally
(`docker image inspect`). Does not pull. Detects shell ENTRYPOINTs that
exit 0 while ignoring CMD.

## Usage

``` r
ni_doctor_probe_docker_payload(
  cfg,
  profile_name,
  profile,
  marker = "NIFLOWR_PROBE_OK",
  timeout = 30
)
```
