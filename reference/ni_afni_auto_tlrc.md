# AFNI AutoTLRC

A minimal wrapper for the AutoTLRC script

## Usage

``` r
ni_afni_auto_tlrc(
  base,
  in_file,
  args = NULL,
  no_ss = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- base:

  Character. Reference anatomical volume. Usually this volume is in some
  standard space like TLRC or MNI space and with afni dataset view of
  (+tlrc). Preferably, this reference volume should have had the skull
  removed but that is not mandatory. AFNI's distribution contains
  several templates. For a longer list, use "whereami -show_templates"
  TT_N27+tlrc –\> Single subject, skull stripped volume. This volume is
  also known as N27_SurfVol_NoSkull+tlrc elsewhere in AFNI and SUMA
  land. (www.loni.ucla.edu, www.bic.mni.mcgill.ca) This template has a
  full set of FreeSurfer (surfer.nmr.mgh.harvard.edu) surface models
  that can be used in SUMA. For details, see Talairach-related link:
  https://afni.nimh.nih.gov/afni/suma TT_icbm452+tlrc –\> Average volume
  of 452 normal brains. Skull Stripped. (www.loni.ucla.edu)
  TT_avg152T1+tlrc –\> Average volume of 152 normal brains. Skull
  Stripped.(www.bic.mni.mcgill.ca) TT_EPI+tlrc –\> EPI template from
  spm2, masked as TT_avg152T1 TT_avg152 and TT_EPI volume sources are
  from SPM's distribution. (www.fil.ion.ucl.ac.uk/spm/) If you do not
  specify a path for the template, the script will attempt to locate the
  template AFNI's binaries directory. NOTE: These datasets have been
  slightly modified from their original size to match the standard TLRC
  dimensions (Jean Talairach and Pierre Tournoux Co-Planar Stereotaxic
  Atlas of the Human Brain Thieme Medical Publishers, New York, 1988).
  That was done for internal consistency in AFNI. You may use the
  original form of these volumes if you choose but your TLRC coordinates
  will not be consistent with AFNI's TLRC database (San Antonio
  Talairach Daemon database), for example. **Required.**

- in_file:

  Character; file path. Original anatomical volume (+orig).The skull is
  removed by this scriptunless instructed otherwise (-no_ss).
  **Required.**

- args:

  Character. Additional parameters to the command

- no_ss:

  Logical. Do not strip skull of input data set (because skull has
  already been removed or because template still has the skull) NOTE:
  The `-no_ss` option is not all that optional. Here is a table of when
  you should and should not use `-no_ss` +——————+————+—————+ \| Dataset
  \| Template \| +==================+============+===============+ \| \|
  w/ skull \| wo/ skull \| +——————+————+—————+ \| WITH skull \| `-no_ss`
  \| xxx \| +——————+————+—————+ \| WITHOUT skull \| No Cigar \| `-no_ss`
  \| +——————+————+—————+ Template means: Your template of choice Dset.
  means: Your anatomical dataset `-no_ss` means: Skull stripping should
  not be attempted on Dset xxx means: Don't put anything, the script
  will strip Dset No Cigar means: Don't try that combination, it makes
  no sense.

- .cwd:

  Working directory override.

- .env:

  Named character vector of environment variables.

- .engine:

  Execution engine override.

- .profile:

  Runtime profile override.

- dry_run:

  Logical; preview command without executing.

- echo:

  Logical; echo stdout/stderr in real time.

## Value

An `ni_result` object.
