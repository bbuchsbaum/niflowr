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
