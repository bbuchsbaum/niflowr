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

test_that("ni_lint_specs normalizes broken constraints and position collisions", {
  withr::with_tempdir({
    spec_path <- file.path(getwd(), "tmp_constraints.json")
    spec <- list(
      spec_version = "0.1.0",
      id = "test.normalize",
      title = "Normalize Test",
      command = "echo",
      inputs = list(
        in_file = list(type = "file", required = TRUE, cli = list(argstr = "%s", position = 0)),
        mode_a = list(
          type = "flag",
          cli = list(argstr = "-A", position = 1),
          constraints = list(xor = c("mode_a", "mode_b", "ghost"))
        ),
        mode_b = list(
          type = "flag",
          cli = list(argstr = "-B", position = 1),
          constraints = list(requires = c("in_file", "missing_param"))
        )
      ),
      outputs = list(out_file = list(type = "file", path = list(template = "{in_file}"), must_exist = FALSE))
    )
    jsonlite::write_json(spec, spec_path, pretty = TRUE, auto_unbox = TRUE, null = "null")

    findings <- ni_lint_specs(spec_paths = spec_path, fix = TRUE, write = TRUE, strict = FALSE)
    expect_true(any(findings$code == "constraint_unknown_ref" & findings$fixed))
    expect_true(any(findings$code == "position_collision" & findings$fixed))

    fixed <- jsonlite::read_json(spec_path, simplifyVector = FALSE)
    expect_identical(fixed$inputs$mode_a$constraints$xor, list("mode_b"))
    expect_identical(fixed$inputs$mode_b$constraints$requires, list("in_file"))
    pos_count <- sum(vapply(fixed$inputs[c("mode_a", "mode_b")], function(x) !is.null(x$cli$position), logical(1)))
    expect_equal(pos_count, 1)
  })
})

test_that("bool placeholders are warnings, not errors", {
  withr::with_tempdir({
    spec_path <- file.path(getwd(), "tmp_bool.json")
    spec <- list(
      spec_version = "0.1.0",
      id = "test.bool_placeholder",
      title = "Bool Placeholder",
      command = "echo",
      inputs = list(
        in_file = list(type = "file", required = TRUE, cli = list(argstr = "%s", position = 0)),
        as_int = list(type = "bool", cli = list(argstr = "--flag %d"))
      ),
      outputs = list(out_file = list(type = "file", path = list(template = "{in_file}"), must_exist = FALSE))
    )
    jsonlite::write_json(spec, spec_path, pretty = TRUE, auto_unbox = TRUE, null = "null")

    findings <- ni_lint_specs(spec_paths = spec_path, fix = FALSE, write = FALSE, strict = FALSE)
    errs <- findings[findings$level == "error", , drop = FALSE]
    expect_false(any(errs$code == "flag_placeholder"))
    expect_true(any(findings$code == "bool_placeholder" & findings$level == "warning"))
  })
})

test_that("ni_lint_specs flags placeholder descriptions", {
  withr::with_tempdir({
    spec_path <- file.path(getwd(), "tmp_placeholder.json")
    spec <- list(
      spec_version = "0.1.0",
      id = "test.placeholder",
      title = "Placeholder Test",
      description = "TODO replace this text",
      command = "echo",
      inputs = list(
        in_file = list(
          type = "file",
          required = TRUE,
          desc = "TBD",
          cli = list(argstr = "%s", position = 0)
        )
      ),
      outputs = list(
        out_file = list(
          type = "file",
          path = list(template = "{in_file}"),
          must_exist = FALSE
        )
      )
    )
    jsonlite::write_json(spec, spec_path, pretty = TRUE, auto_unbox = TRUE, null = "null")

    findings <- ni_lint_specs(spec_paths = spec_path, fix = FALSE, write = FALSE, strict = FALSE)
    placeholder <- findings[findings$code == "placeholder_desc", , drop = FALSE]
    expect_true(nrow(placeholder) >= 2)
    expect_true(all(placeholder$level == "error"))
  })
})

test_that("ni_lint_specs reports clean shell syntax for bundled specs", {
  findings <- ni_lint_specs(spec_dir = "inst/specs", strict = FALSE, fix = FALSE)
  shell_errors <- findings[findings$code == "shell_argstr" & findings$level == "error", , drop = FALSE]
  expect_equal(nrow(shell_errors), 0)
})

test_that("ni_lint_specs reports no placeholder descriptions for bundled specs", {
  findings <- ni_lint_specs(spec_dir = "inst/specs", strict = FALSE, fix = FALSE)
  placeholder_errors <- findings[findings$code == "placeholder_desc" & findings$level == "error", , drop = FALSE]
  expect_equal(nrow(placeholder_errors), 0)
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
