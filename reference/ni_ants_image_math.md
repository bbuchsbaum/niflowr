# ANTS ImageMath

Operations over images.

## Usage

``` r
ni_ants_image_math(
  op1,
  operation,
  args = NULL,
  dimension = 3,
  op2 = NULL,
  output_image = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- op1:

  Character; file path. first operator **Required.**

- operation:

  Character; one of: "m", "vm", "+", "v+", "-", "v-", "/", "^", "max",
  "exp", "addtozero", "overadd", "abs", "total", "mean", "vtotal",
  "Decision", "Neg", "Project", "G", "MD", "ME", "MO", "MC", "GD", "GE",
  "GO", "GC", "ExtractContours", "Translate", "4DTensorTo3DTensor",
  "ExtractVectorComponent", "TensorColor", "TensorFA",
  "TensorFADenominator", "TensorFANumerator", "TensorMeanDiffusion",
  "TensorRadialDiffusion", "TensorAxialDiffusion", "TensorEigenvalue",
  "TensorToVector", "TensorToVectorComponent", "TensorMask", "Byte",
  "CorruptImage", "D", "MaurerDistance", "ExtractSlice", "FillHoles",
  "Convolve", "Finite", "FlattenImage", "GetLargestComponent", "Grad",
  "RescaleImage", "WindowImage", "NeighborhoodStats",
  "ReplicateDisplacement", "ReplicateImage", "LabelStats", "Laplacian",
  "Canny", "Lipschitz", "MTR", "Normalize", "PadImage", "SigmoidImage",
  "Sharpen", "UnsharpMask", "PValueImage", "ReplaceVoxelValue",
  "SetTimeSpacing", "SetTimeSpacingWarp", "stack", "ThresholdAtMean",
  "TriPlanarView", "TruncateImageIntensity". mathematical operations
  **Required.**

- args:

  Character. Additional parameters to the command

- dimension:

  Integer. dimension of output image

- op2:

  Character or numeric vector. second operator

- output_image:

  Character; file path. output image file

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
