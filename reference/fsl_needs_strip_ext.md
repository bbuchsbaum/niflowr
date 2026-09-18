# Whether an FSL input should strip known extensions before CLI rendering

Image outs (BET/MCFLIRT `-out`, FAST basenames, …) strip `.nii.gz` so
FSL does not double-append `FSLOUTPUTTYPE`. Text/matrix outs keep the
full path (e.g. `fslmeants -o mean.txt`).

## Usage

``` r
fsl_needs_strip_ext(name, argstr, desc = NULL)
```
