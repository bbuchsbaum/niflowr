# AFNI AlignEpiAnatPy

Align EPI to anatomical datasets or vice versa.

## Usage

``` r
ni_afni_align_epi_anat_py(
  anat,
  epi_base,
  in_file,
  anat2epi = NULL,
  args = NULL,
  epi2anat = NULL,
  epi_strip = NULL,
  save_skullstrip = NULL,
  suffix = "_al",
  tshift = "on",
  volreg = "on",
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- anat:

  Character; file path. name of structural dataset **Required.**

- epi_base:

  Character or numeric vector. the epi base used in alignmentshould be
  one of (0/mean/median/max/subbrick#) **Required.**

- in_file:

  Character; file path. EPI dataset to align **Required.**

- anat2epi:

  Logical. align anatomical to EPI dataset (default)

- args:

  Character. Additional parameters to the command

- epi2anat:

  Logical. align EPI to anatomical dataset

- epi_strip:

  Character; one of: "3dSkullStrip", "3dAutomask", "None". method to
  mask brain in EPI datashould be one
  of\[3dSkullStrip\]/3dAutomask/None)

- save_skullstrip:

  Logical. save skull-stripped (not aligned)

- suffix:

  Character. append suffix to the original anat/epi dataset to usein the
  resulting dataset names (default is "\_al")

- tshift:

  Character; one of: "on", "off". do time shifting of EPI dataset before
  alignmentshould be 'on' or 'off', defaults to 'on'

- volreg:

  Character; one of: "on", "off". do volume registration on EPI dataset
  before alignmentshould be 'on' or 'off', defaults to 'on'

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
