test_that("build_command renders positional args in order", {
  spec <- ni_spec_read("fsl.bet")
  call <- ni_call(spec, in_file = "/tmp/t1.nii.gz", out_file = "/tmp/brain.nii.gz",
                  .validate = FALSE)
  built <- niflowr:::build_command(call)

  expect_equal(built$command, "bet")
  # First two args should be positional (in_file at 0, out_file at 1)
  expect_equal(built$args[1], "/tmp/t1.nii.gz")
  expect_equal(built$args[2], "/tmp/brain.nii.gz")
})

test_that("build_command renders flags only when TRUE", {
  spec <- ni_spec_read("fsl.bet")

  # mask = TRUE should include -m
  call1 <- ni_call(spec, in_file = "/tmp/t1.nii.gz", out_file = "/tmp/brain.nii.gz",
                   mask = TRUE, .validate = FALSE)
  built1 <- niflowr:::build_command(call1)
  expect_true("-m" %in% built1$args)

  # mask = FALSE should not include -m
  call2 <- ni_call(spec, in_file = "/tmp/t1.nii.gz", out_file = "/tmp/brain.nii.gz",
                   mask = FALSE, .validate = FALSE)
  built2 <- niflowr:::build_command(call2)
  expect_false("-m" %in% built2$args)
})

test_that("build_command renders sprintf-formatted args", {
  spec <- ni_spec_read("fsl.bet")
  call <- ni_call(spec, in_file = "/tmp/t1.nii.gz", out_file = "/tmp/brain.nii.gz",
                  frac = 0.3, .validate = FALSE)
  built <- niflowr:::build_command(call)

  expect_true("-f" %in% built$args)
  # The value 0.3 should follow -f (format may vary: "0.3", "0.30", etc.)
  f_idx <- which(built$args == "-f")
  expect_equal(as.numeric(built$args[f_idx + 1]), 0.3)
})

test_that("build_command handles list type with sep", {
  # Create a minimal spec with a list-type param
  spec <- structure(list(
    spec_version = "0.1.0",
    id = "test.listsep",
    command = "testcmd",
    inputs = list(
      coords = list(
        type = "list",
        cli = list(argstr = "-c %s", sep = " ")
      )
    ),
    outputs = list()
  ), class = "ni_spec")

  call <- ni_call(spec, coords = c(10, 20, 30), .validate = FALSE)
  built <- niflowr:::build_command(call)
  expect_true("-c" %in% built$args)
  # Joined value should be "10 20 30"
  c_idx <- which(built$args == "-c")
  expect_equal(built$args[c_idx + 1], "10 20 30")
})

test_that("non-positional args are sorted alphabetically", {
  spec <- ni_spec_read("fsl.bet")
  call <- ni_call(spec,
                  in_file = "/tmp/t1.nii.gz",
                  out_file = "/tmp/brain.nii.gz",
                  robust = TRUE,
                  mask = TRUE,
                  frac = 0.5,
                  .validate = FALSE)
  built <- niflowr:::build_command(call)

  # Positional args come first, then non-positional sorted alphabetically
  # Non-positional: frac (-f 0.5), mask (-m), robust (-R) sorted by param name
  non_pos <- built$args[3:length(built$args)]

  # frac comes before mask which comes before robust (alphabetical)
  f_pos <- which(non_pos == "-f")[1]
  m_pos <- which(non_pos == "-m")[1]
  r_pos <- which(non_pos == "-R")[1]
  expect_true(f_pos < m_pos)
  expect_true(m_pos < r_pos)
})

test_that("build_command renders bool placeholders as numeric values", {
  spec <- structure(list(
    spec_version = "0.1.0",
    id = "test.boolfmt",
    command = "testcmd",
    inputs = list(
      switch = list(
        type = "bool",
        cli = list(argstr = "--switch %d")
      )
    ),
    outputs = list()
  ), class = "ni_spec")

  call_true <- ni_call(spec, switch = TRUE, .validate = FALSE)
  built_true <- niflowr:::build_command(call_true)
  expect_equal(built_true$args, c("--switch", "1"))

  call_false <- ni_call(spec, switch = FALSE, .validate = FALSE)
  built_false <- niflowr:::build_command(call_false)
  expect_equal(built_false$args, c("--switch", "0"))
})

test_that("coerce_for_argstr coerces values to match printf conversions (#1)", {
  # numeric enum stored as character must coerce for %d / %i
  expect_identical(niflowr:::coerce_for_argstr("3", "--dimensionality %d"), 3L)
  expect_identical(niflowr:::coerce_for_argstr("3", "-d %i"), 3L)
  # float conversions coerce to numeric
  expect_identical(niflowr:::coerce_for_argstr("0.5", "-f %f"), 0.5)
  # non-numeric value with a numeric conversion is left untouched (safe fallback)
  expect_identical(niflowr:::coerce_for_argstr("item1", "%d"), "item1")
  # %s conversions never coerce
  expect_identical(niflowr:::coerce_for_argstr("GenericLabel", "%s"), "GenericLabel")
})

test_that("coerce_for_argstr never turns non-finite or overflow values into NA (#1)", {
  # Inf / NaN must not become integer NA
  expect_identical(niflowr:::coerce_for_argstr("Inf", "--x %d"), "Inf")
  expect_identical(niflowr:::coerce_for_argstr("NaN", "--x %d"), "NaN")
  # value beyond R's integer range stays untouched (no silent NA)
  expect_identical(niflowr:::coerce_for_argstr("3000000000", "--x %d"), "3000000000")
  # in-range integral value still coerces
  expect_identical(niflowr:::coerce_for_argstr("1000000000", "--x %d"), 1000000000L)
})

test_that("multi-conversion ellipsis argstrs are left to generic handling (#2)", {
  list_def <- list(type = "list")
  # a 2-conversion tuple argstr must NOT be split into clean per-element flags
  out <- niflowr:::render_arg(c("a", "b"), list_def, "-x %d %s...")
  expect_false(identical(out, c("-x", "a", "-x", "b")))
  # single-conversion still expands
  expect_equal(
    niflowr:::render_arg(c("a", "b"), list_def, "-x %s..."),
    c("-x", "a", "-x", "b")
  )
})

test_that("numeric enum with %d argstr renders without literal placeholder (#1)", {
  spec <- structure(list(
    spec_version = "0.1.0",
    id = "test.dimcoerce",
    command = "testcmd",
    inputs = list(
      dimension = list(
        type = "enum",
        choices = c(2, 3, 4),
        cli = list(argstr = "--dimensionality %d")
      )
    ),
    outputs = list()
  ), class = "ni_spec")

  call <- ni_call(spec, dimension = 3)
  built <- niflowr:::build_command(call)
  expect_equal(built$args, c("--dimensionality", "3"))
  expect_false("%d" %in% built$args)
})

test_that("%s... argstr expands per element instead of appending an ellipsis (#2)", {
  list_def <- list(type = "list")

  # scalar value: single application, no trailing "..."
  expect_equal(
    niflowr:::render_arg("fixed.nii.gz", list_def, "-f %s..."),
    c("-f", "fixed.nii.gz")
  )

  # list value: flag repeated per element (Nipype repeat semantics)
  expect_equal(
    niflowr:::render_arg(c("a.nii.gz", "b.nii.gz"), list_def, "-f %s..."),
    c("-f", "a.nii.gz", "-f", "b.nii.gz")
  )

  # no token retains a literal trailing ellipsis
  tokens <- niflowr:::render_arg(c("a", "b"), list_def, "-m %s...")
  expect_false(any(grepl("[.][.][.]$", tokens)))
})
