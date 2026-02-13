test_that("ni_lint_specs rewrites shell redirection patterns", {
  withr::with_tempdir({
    spec_path <- file.path(getwd(), "tmp_spec.json")
    spec <- list(
      spec_version = "0.1.0",
      id = "test.shell_fix",
      title = "Shell Fix Test",
      command = "echo",
      inputs = list(
        out_file = list(
          type = "file",
          cli = list(argstr = "> %s", position = -1)
        ),
        in_file = list(
          type = "file",
          required = TRUE,
          cli = list(argstr = "%s", position = 0)
        )
      ),
      outputs = list(
        out_file = list(
          type = "file",
          path = list(from_input = "out_file"),
          must_exist = FALSE
        )
      )
    )
    jsonlite::write_json(spec, spec_path, pretty = TRUE, auto_unbox = TRUE, null = "null")

    findings <- ni_lint_specs(spec_paths = spec_path, fix = TRUE, write = TRUE, strict = FALSE)
    expect_true(any(findings$code == "shell_argstr"))
    expect_true(any(findings$fixed))

    fixed <- jsonlite::read_json(spec_path, simplifyVector = TRUE)
    expect_null(fixed$inputs$out_file$cli$argstr)
    expect_equal(fixed$inputs$out_file$cli$stdout_to, "out_file")
  })
})

test_that("ni_lint_specs reports clean shell syntax for bundled specs", {
  findings <- ni_lint_specs(spec_dir = "inst/specs", strict = FALSE, fix = FALSE)
  shell_errors <- findings[findings$code == "shell_argstr" & findings$level == "error", , drop = FALSE]
  expect_equal(nrow(shell_errors), 0)
})

test_that("golden cmdline fixtures are up to date", {
  fixture <- testthat::test_path("../golden/cmdline_golden.json")
  if (!file.exists(fixture)) {
    skip("Golden fixture not present.")
  }

  withr::with_tempfile("tmp", fileext = ".json", {
    ni_golden_cmdline_generate(output = tmp)

    expected <- jsonlite::read_json(fixture, simplifyVector = FALSE)
    actual <- jsonlite::read_json(tmp, simplifyVector = FALSE)
    expect_identical(actual, expected)
  })
})
