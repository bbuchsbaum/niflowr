# Tests for freesurfer.synthmorph_register / _apply specs and wrappers

# ---- register ----

test_that("freesurfer.synthmorph_register spec loads with expected fields", {
  spec <- ni_spec_read("freesurfer.synthmorph_register")
  expect_s3_class(spec, "ni_spec")
  expect_equal(spec$id, "freesurfer.synthmorph_register")
  expect_equal(spec$command, c("mri_synthmorph", "register"))
  expect_equal(spec$runtime$profile, "freesurfer")
  expect_true(isTRUE(spec$inputs$moving$required))
  expect_true(isTRUE(spec$inputs$fixed$required))
})

test_that("freesurfer.synthmorph_register renders core CLI args", {
  moving <- withr::local_tempfile(fileext = ".nii.gz")
  fixed <- withr::local_tempfile(fileext = ".nii.gz")
  file.create(moving, fixed)

  call <- ni_call("freesurfer.synthmorph_register",
    moving = moving,
    fixed = fixed,
    out_moving = "/tmp/moved.nii.gz",
    trans = "/tmp/trans.lta",
    model = "affine",
    threads = 4L,
    extent = 192L,
    gpu = TRUE
  )
  cmd <- ni_cmd(call)
  expect_equal(cmd$command, "mri_synthmorph")
  expect_true(all(c("register", moving, fixed) %in% cmd$args))
  expect_true(all(c("-o", "/tmp/moved.nii.gz") %in% cmd$args))
  expect_true(all(c("-t", "/tmp/trans.lta") %in% cmd$args))
  expect_true(all(c("-m", "affine") %in% cmd$args))
  expect_true(all(c("-j", "4") %in% cmd$args))
  expect_true(all(c("-e", "192") %in% cmd$args))
  expect_true("-g" %in% cmd$args)

  # Positional ordering: moving before fixed at the tail
  args <- cmd$args
  expect_lt(match(moving, args), match(fixed, args))
})

test_that("freesurfer.synthmorph_register rejects unknown model values", {
  moving <- withr::local_tempfile(fileext = ".nii.gz")
  fixed <- withr::local_tempfile(fileext = ".nii.gz")
  file.create(moving, fixed)
  expect_error(
    ni_call("freesurfer.synthmorph_register",
      moving = moving,
      fixed = fixed,
      model = "elastic"
    ),
    "validation failed"
  )
})

# ---- apply ----

test_that("freesurfer.synthmorph_apply spec loads with expected fields", {
  spec <- ni_spec_read("freesurfer.synthmorph_apply")
  expect_s3_class(spec, "ni_spec")
  expect_equal(spec$id, "freesurfer.synthmorph_apply")
  expect_equal(spec$command, c("mri_synthmorph", "apply"))
  expect_equal(spec$runtime$profile, "freesurfer")
  expect_true(isTRUE(spec$inputs$trans$required))
  expect_true(isTRUE(spec$inputs$moving$required))
  expect_true(isTRUE(spec$inputs$moved$required))
})

test_that("freesurfer.synthmorph_apply renders correct positional CLI", {
  trans <- withr::local_tempfile(fileext = ".lta")
  moving <- withr::local_tempfile(fileext = ".nii.gz")
  file.create(trans, moving)

  call <- ni_call("freesurfer.synthmorph_apply",
    trans = trans,
    moving = moving,
    moved = "/tmp/moved.nii.gz",
    method = "nearest",
    out_type = "short"
  )
  cmd <- ni_cmd(call)
  expect_equal(cmd$command, "mri_synthmorph")
  args <- cmd$args
  expect_true("apply" %in% args)
  expect_true(all(c("-m", "nearest") %in% args))
  expect_true(all(c("-t", "short") %in% args))
  # trans, moving, moved positional order at the tail
  expect_lt(match(trans, args), match(moving, args))
  expect_lt(match(moving, args), match("/tmp/moved.nii.gz", args))
})

# ---- wrappers ----

test_that("ni_freesurfer_synthmorph_register/apply wrappers exist and dry_run", {
  expect_true(is.function(ni_freesurfer_synthmorph_register))
  expect_true(is.function(ni_freesurfer_synthmorph_apply))

  moving <- withr::local_tempfile(fileext = ".nii.gz")
  fixed <- withr::local_tempfile(fileext = ".nii.gz")
  trans <- withr::local_tempfile(fileext = ".lta")
  file.create(moving, fixed, trans)

  expect_null(ni_freesurfer_synthmorph_register(
    moving = moving, fixed = fixed,
    trans = "/tmp/trans.lta",
    .engine = "native", dry_run = TRUE
  ))
  expect_null(ni_freesurfer_synthmorph_apply(
    trans = trans, moving = moving, moved = "/tmp/moved.nii.gz",
    .engine = "native", dry_run = TRUE
  ))
})

test_that("freesurfer synthmorph specs appear in ni_spec_list()", {
  specs <- ni_spec_list()
  expect_true("freesurfer.synthmorph_register" %in% specs)
  expect_true("freesurfer.synthmorph_apply" %in% specs)
})
