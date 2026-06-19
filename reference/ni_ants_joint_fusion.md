# ANTS JointFusion

An image fusion algorithm.

## Usage

``` r
ni_ants_joint_fusion(
  atlas_image,
  atlas_segmentation_image,
  target_image,
  alpha = 0.1,
  args = NULL,
  beta = 2,
  constrain_nonnegative = FALSE,
  dimension = NULL,
  exclusion_image_label = NULL,
  mask_image = NULL,
  out_label_fusion = NULL,
  patch_metric = NULL,
  patch_radius = NULL,
  retain_atlas_voting_images = FALSE,
  retain_label_posterior_images = FALSE,
  search_radius = c(3, 3, 3),
  verbose = NULL,
  .cwd = NULL,
  .env = NULL,
  .engine = NULL,
  .profile = NULL,
  dry_run = FALSE,
  echo = interactive()
)
```

## Arguments

- atlas_image:

  Character or numeric vector. The atlas image (or multimodal atlas
  images) assumed to be aligned to a common image domain. **Required.**

- atlas_segmentation_image:

  Character or numeric vector. The atlas segmentation images. For
  performing label fusion the number of specified segmentations should
  be identical to the number of atlas image sets. **Required.**

- target_image:

  Character or numeric vector. The target image (or multimodal target
  images) assumed to be aligned to a common image domain. **Required.**

- alpha:

  Numeric. Regularization term added to matrix Mx for calculating the
  inverse. Default = 0.1

- args:

  Character. Additional parameters to the command

- beta:

  Numeric. Exponent for mapping intensity difference to the joint error.
  Default = 2.0

- constrain_nonnegative:

  Logical. Constrain solution to non-negative weights.

- dimension:

  Character; one of: "3", "2", "4". This option forces the image to be
  treated as a specified-dimensional image. If not specified, the
  program tries to infer the dimensionality from the input image.

- exclusion_image_label:

  Character or numeric vector. Specify a label for the exclusion region.

- mask_image:

  Character; file path. If a mask image is specified, fusion is only
  performed in the mask region.

- out_label_fusion:

  Character; file path. The output label fusion image.

- patch_metric:

  Character; one of: "PC", "MSQ". Metric to be used in determining the
  most similar neighborhood patch. Options include Pearson's correlation
  (PC) and mean squares (MSQ). Default = PC (Pearson correlation).

- patch_radius:

  Character or numeric vector. Patch radius for similarity measures.
  Default: 2x2x2

- retain_atlas_voting_images:

  Logical. Retain atlas voting images. Default = false

- retain_label_posterior_images:

  Logical. Retain label posterior probability images. Requires atlas
  segmentations to be specified. Default = false

- search_radius:

  Character or numeric vector. Search radius for similarity measures.
  Default = 3x3x3. One can also specify an image where the value at the
  voxel specifies the isotropic search radius at that voxel.

- verbose:

  Logical. Verbose output.

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
