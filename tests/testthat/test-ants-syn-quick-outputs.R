# Tests for ants.registration_syn_quick declared, conditional outputs (issue #4)

test_that("syn_quick exposes prefix-derived outputs for deformable presets (#4)", {
  call <- ni_call("ants.registration_syn_quick",
    fixed_image = "f.nii.gz",
    moving_image = "m.nii.gz",
    output_prefix = "x_",
    .validate = FALSE
  )
  # transform_type defaults to "s" (deformable) -> all five artifacts present
  expect_equal(call$outputs$out_matrix, "x_0GenericAffine.mat")
  expect_equal(call$outputs$warped_image, "x_Warped.nii.gz")
  expect_equal(call$outputs$inverse_warped_image, "x_InverseWarped.nii.gz")
  expect_equal(call$outputs$forward_warp_field, "x_1Warp.nii.gz")
  expect_equal(call$outputs$inverse_warp_field, "x_1InverseWarp.nii.gz")
})

test_that("syn_quick omits warp fields for affine-only transform types (#4)", {
  call <- ni_call("ants.registration_syn_quick",
    fixed_image = "f.nii.gz",
    moving_image = "m.nii.gz",
    output_prefix = "x_",
    transform_type = "a",
    .validate = FALSE
  )
  expect_equal(call$outputs$out_matrix, "x_0GenericAffine.mat")
  expect_equal(call$outputs$warped_image, "x_Warped.nii.gz")
  expect_equal(call$outputs$inverse_warped_image, "x_InverseWarped.nii.gz")
  expect_null(call$outputs$forward_warp_field)
  expect_null(call$outputs$inverse_warp_field)
  expect_length(call$outputs, 3L)
})

test_that("syn_quick requires output_prefix so outputs match the command (#4)", {
  # output_prefix is required: omitting it errors rather than silently
  # declaring `transform*` outputs that the command would not request.
  expect_error(
    ni_call("ants.registration_syn_quick",
      fixed_image = "f.nii.gz", moving_image = "m.nii.gz"),
    "output_prefix"
  )
})

test_that("syn_quick declared outputs match the rendered -o argument (#4)", {
  call <- ni_call("ants.registration_syn_quick",
    fixed_image = "f.nii.gz",
    moving_image = "m.nii.gz",
    output_prefix = "x_",
    .validate = FALSE
  )
  a <- ni_cmd(call)$args
  # the command actually requests the prefix the outputs are derived from
  oi <- which(a == "-o")
  expect_length(oi, 1)
  expect_equal(a[oi + 1], "x_")
  expect_equal(call$outputs$out_matrix, "x_0GenericAffine.mat")
})
