test_that("merging an empty override keeps the base config", {
  base <- list(paths = list(in_root = "in"), profiles = list(fsl = list(docker_image = "img")))
  expect_identical(niflowr:::ni_config_merge(base, list()), base)
  expect_identical(niflowr:::ni_config_merge(base, NULL), base)
})

test_that("a project niflowr.yml is read when no session overrides are set", {
  dir <- withr::local_tempdir()
  withr::local_dir(dir)
  writeLines(c("paths:", "  in_root: data", "profiles:", "  fsl: { docker_image: \"brainlife/fsl:6.0.4\" }"), "niflowr.yml")
  ni_config(.reset = TRUE)
  withr::defer(ni_config(.reset = TRUE, auto_read = FALSE))
  cfg <- niflowr:::ni_config_resolve()
  expect_identical(cfg$paths$in_root, "data")
  expect_identical(cfg$profiles$fsl$docker_image, "brainlife/fsl:6.0.4")
})
