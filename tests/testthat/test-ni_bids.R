test_that("ni_deriv_path generates BIDS derivatives path", {
  result <- ni_deriv_path("sub-01_T1w.nii.gz", desc = "brain")
  expect_match(result, "derivatives/niflowr")
  expect_match(result, "sub-01")
  expect_match(result, "desc-brain")
  expect_match(result, "\\.nii\\.gz$")
})

test_that("ni_deriv_path handles session entity", {
  result <- ni_deriv_path("sub-01_ses-pre_T1w.nii.gz", desc = "preproc")
  expect_match(result, "sub-01")
  expect_match(result, "ses-pre")
  expect_match(result, "desc-preproc")
})

test_that("ni_deriv_path handles space entity", {
  result <- ni_deriv_path("sub-01_T1w.nii.gz",
                          desc = "brain", space = "MNI152")
  expect_match(result, "space-MNI152")
  expect_match(result, "desc-brain")
})

test_that("ni_deriv_path handles suffix override", {
  result <- ni_deriv_path("sub-01_T1w.nii.gz",
                          desc = "brain", suffix = "mask")
  expect_match(result, "mask")
})

test_that("ni_deriv_path detects modality from suffix", {
  anat <- ni_deriv_path("sub-01_T1w.nii.gz")
  expect_match(anat, "anat")

  func <- ni_deriv_path("sub-01_bold.nii.gz", suffix = "bold")
  expect_match(func, "func")
})

test_that("ni_deriv_path uses custom derivatives_dir", {
  result <- ni_deriv_path("sub-01_T1w.nii.gz",
                          derivatives_dir = "output/custom")
  expect_match(result, "^output/custom")
})

# Edge case tests

test_that("ni_deriv_path handles space entity with complex name", {
  path <- ni_deriv_path(
    "sub-01_ses-pre_T1w.nii.gz",
    desc = "brain",
    space = "MNI152NLin2009cAsym"
  )
  expect_match(path, "space-MNI152NLin2009cAsym")
  expect_match(path, "desc-brain")
})

test_that("ni_deriv_path with suffix override changes modality", {
  path <- ni_deriv_path(
    "sub-01_T1w.nii.gz",
    desc = "preproc",
    suffix = "bold"
  )
  expect_match(path, "bold")
  expect_match(path, "func")  # bold triggers func modality
})

test_that("ni_deriv_path includes session in directory structure correctly", {
  path <- ni_deriv_path("sub-01_ses-pre_T1w.nii.gz", desc = "brain")
  expect_match(path, "ses-pre")
  expect_match(path, "sub-01")
})

test_that("ni_deriv_path respects custom extension", {
  path <- ni_deriv_path("sub-01_T1w.nii.gz", desc = "brain", extension = ".mgz")
  expect_match(path, "\\.mgz$")
})

test_that("ni_deriv_path defaults to anat for unknown suffixes", {
  path <- ni_deriv_path("sub-01_FLAIR.nii.gz", desc = "brain")
  expect_match(path, "anat")
})
