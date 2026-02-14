# Tests for FastSurfer specs and wrappers

# ---- Spec loading ----

test_that("fastsurfer.run spec loads and validates", {
  spec <- ni_spec_read("fastsurfer.run")
  expect_s3_class(spec, "ni_spec")
  expect_equal(spec$id, "fastsurfer.run")
  expect_equal(spec$command, "run_fastsurfer.sh")
  expect_true("t1" %in% names(spec$inputs))
  expect_true("sid" %in% names(spec$inputs))
  expect_true("sd" %in% names(spec$inputs))
  expect_true(isTRUE(spec$inputs$t1$required))
  expect_true(isTRUE(spec$inputs$sid$required))
  expect_true(isTRUE(spec$inputs$sd$required))
})

test_that("fastsurfer.segment spec loads and validates", {
  spec <- ni_spec_read("fastsurfer.segment")
  expect_s3_class(spec, "ni_spec")
  expect_equal(spec$id, "fastsurfer.segment")
  expect_equal(spec$command, c("run_fastsurfer.sh", "--seg_only"))
  expect_true("t1" %in% names(spec$inputs))
  # segment spec should not have surf_only or fs_license

  expect_null(spec$inputs$surf_only)
  expect_null(spec$inputs$fs_license)
})

test_that("fastsurfer specs have manual origin", {
  run_spec <- ni_spec_read("fastsurfer.run")
  seg_spec <- ni_spec_read("fastsurfer.segment")
  expect_equal(run_spec$origin$source, "manual")
  expect_equal(seg_spec$origin$source, "manual")
})

test_that("fastsurfer specs have fastsurfer profile", {
  run_spec <- ni_spec_read("fastsurfer.run")
  seg_spec <- ni_spec_read("fastsurfer.segment")
  expect_equal(run_spec$runtime$profile, "fastsurfer")
  expect_equal(seg_spec$runtime$profile, "fastsurfer")
})

# ---- ni_call and CLI rendering ----

test_that("fastsurfer.run ni_call builds correctly", {
  call <- ni_call("fastsurfer.run",
    t1 = "/tmp/t1.nii.gz",
    sid = "sub01",
    sd = "/tmp/out",
    .validate = FALSE
  )
  expect_s3_class(call, "ni_call")
  expect_equal(call$values$t1, "/tmp/t1.nii.gz")
  expect_equal(call$values$sid, "sub01")
  expect_equal(call$values$sd, "/tmp/out")
})

test_that("fastsurfer.run renders correct CLI args", {
  call <- ni_call("fastsurfer.run",
    t1 = "/tmp/t1.nii.gz",
    sid = "sub01",
    sd = "/tmp/out",
    device = "cpu",
    threads = 4L,
    seg_only = TRUE,
    .validate = FALSE
  )
  cmd <- ni_cmd(call)
  expect_equal(cmd$command, "run_fastsurfer.sh")
  expect_true("--t1" %in% cmd$args)
  expect_true("/tmp/t1.nii.gz" %in% cmd$args)
  expect_true("--sid" %in% cmd$args)
  expect_true("sub01" %in% cmd$args)
  expect_true("--sd" %in% cmd$args)
  expect_true("/tmp/out" %in% cmd$args)
  expect_true("--device" %in% cmd$args)
  expect_true("cpu" %in% cmd$args)
  expect_true("--threads" %in% cmd$args)
  expect_true("4" %in% cmd$args)
  expect_true("--seg_only" %in% cmd$args)
})

test_that("fastsurfer.run flag args omitted when FALSE/NULL", {
  call <- ni_call("fastsurfer.run",
    t1 = "/tmp/t1.nii.gz",
    sid = "sub01",
    sd = "/tmp/out",
    seg_only = FALSE,
    no_cereb = FALSE,
    .validate = FALSE
  )
  cmd <- ni_cmd(call)
  expect_false("--seg_only" %in% cmd$args)
  expect_false("--no_cereb" %in% cmd$args)
})

test_that("fastsurfer.run renders --3T flag correctly", {
  call <- ni_call("fastsurfer.run",
    t1 = "/tmp/t1.nii.gz",
    sid = "sub01",
    sd = "/tmp/out",
    three_t = TRUE,
    .validate = FALSE
  )
  cmd <- ni_cmd(call)
  expect_true("--3T" %in% cmd$args)
})

test_that("fastsurfer.run renders --no_fs_T1 flag correctly", {
  call <- ni_call("fastsurfer.run",
    t1 = "/tmp/t1.nii.gz",
    sid = "sub01",
    sd = "/tmp/out",
    no_fs_t1 = TRUE,
    .validate = FALSE
  )
  cmd <- ni_cmd(call)
  expect_true("--no_fs_T1" %in% cmd$args)
})

test_that("fastsurfer.segment includes --seg_only prefix arg", {
  call <- ni_call("fastsurfer.segment",
    t1 = "/tmp/t1.nii.gz",
    sid = "sub01",
    sd = "/tmp/out",
    .validate = FALSE
  )
  cmd <- ni_cmd(call)
  expect_equal(cmd$command, "run_fastsurfer.sh")
  expect_true("--seg_only" %in% cmd$args)
})

# ---- Output template resolution ----

test_that("fastsurfer.run output paths resolve correctly", {
  call <- ni_call("fastsurfer.run",
    t1 = "/tmp/t1.nii.gz",
    sid = "sub01",
    sd = "/tmp/out",
    .validate = FALSE
  )
  expect_equal(call$outputs$subjects_dir, "/tmp/out/sub01")
  expect_equal(call$outputs$seg_file, "/tmp/out/sub01/mri/aparc.DKTatlas+aseg.deep.mgz")
  expect_equal(call$outputs$mask_file, "/tmp/out/sub01/mri/mask.mgz")
})

test_that("fastsurfer.segment output paths resolve correctly", {
  call <- ni_call("fastsurfer.segment",
    t1 = "/tmp/t1.nii.gz",
    sid = "sub01",
    sd = "/tmp/out",
    .validate = FALSE
  )
  expect_equal(call$outputs$subjects_dir, "/tmp/out/sub01")
  expect_equal(call$outputs$seg_file, "/tmp/out/sub01/mri/aparc.DKTatlas+aseg.deep.mgz")
  expect_equal(call$outputs$mask_file, "/tmp/out/sub01/mri/mask.mgz")
})

# ---- XOR constraints ----

test_that("fastsurfer.run rejects seg_only + surf_only together", {
  expect_error(
    ni_call("fastsurfer.run",
      t1 = "/tmp/t1.nii.gz",
      sid = "sub01",
      sd = "/tmp/out",
      seg_only = TRUE,
      surf_only = TRUE,
      .validate = TRUE
    ),
    "validation failed"
  )
})

# ---- Wrapper functions exist ----

test_that("ni_fastsurfer_run wrapper exists and is a function", {
  expect_true(is.function(ni_fastsurfer_run))
})

test_that("ni_fastsurfer_segment wrapper exists and is a function", {
  expect_true(is.function(ni_fastsurfer_segment))
})

# ---- Wrapper dry_run ----

test_that("ni_fastsurfer_run dry_run returns NULL invisibly", {
  result <- ni_fastsurfer_run(
    t1 = "/tmp/t1.nii.gz",
    sid = "sub01",
    sd = "/tmp/out",
    device = "cpu",
    .engine = "native",
    dry_run = TRUE
  )
  expect_null(result)
})

test_that("ni_fastsurfer_segment dry_run returns NULL invisibly", {
  result <- ni_fastsurfer_segment(
    t1 = "/tmp/t1.nii.gz",
    sid = "sub01",
    sd = "/tmp/out",
    device = "cpu",
    .engine = "native",
    dry_run = TRUE
  )
  expect_null(result)
})

# ---- Spec appears in ni_spec_list ----

test_that("fastsurfer specs appear in ni_spec_list", {
  specs <- ni_spec_list()
  expect_true("fastsurfer.run" %in% specs)
  expect_true("fastsurfer.segment" %in% specs)
})
