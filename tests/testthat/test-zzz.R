test_that("null coalescing operator works", {
  `%||%` <- niflowr:::`%||%`
  expect_equal(NULL %||% "default", "default")
  expect_equal("value" %||% "default", "value")
  expect_equal(42 %||% 0, 42)
  expect_equal(0 %||% "default", 0)  # 0 is not NULL
  expect_equal(FALSE %||% TRUE, FALSE)  # FALSE is not NULL
})

test_that(".onLoad initializes config state", {
  # After package load, config should be initialized
  cfg_env <- niflowr:::.ni_config
  expect_type(cfg_env$overrides, "list")
  expect_equal(cfg_env$config_file, "niflowr.yml")
  # auto_read defaults to TRUE on fresh load, but other tests may

  # have called ni_config(.reset=TRUE, auto_read=FALSE), so just

  # verify the field is logical rather than a specific value
  expect_type(cfg_env$auto_read, "logical")
})

test_that(".spec_registry is an environment", {
  expect_true(is.environment(niflowr:::.spec_registry))
  # Should have emptyenv as parent
  expect_identical(parent.env(niflowr:::.spec_registry), emptyenv())
})

test_that(".ni_config is an environment", {
  expect_true(is.environment(niflowr:::.ni_config))
  expect_identical(parent.env(niflowr:::.ni_config), emptyenv())
})
