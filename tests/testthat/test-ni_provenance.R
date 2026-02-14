test_that("provenance write/read roundtrip works", {
  withr::with_tempdir({
    # Create a mock ni_result
    result <- structure(list(
      spec_id = "test.tool",
      outputs = list(out_file = file.path(getwd(), "output.nii.gz")),
      runtime = list(
        exit_status = 0L,
        stdout = "",
        stderr = "",
        duration_secs = 1.5,
        start_time = Sys.time(),
        end_time = Sys.time()
      ),
      provenance = list(
        spec_id = "test.tool",
        command = "testcmd",
        args = c("arg1", "arg2"),
        exit_status = 0L,
        start_time = format(Sys.time()),
        end_time = format(Sys.time()),
        duration_secs = 1.5,
        outputs = list(out_file = file.path(getwd(), "output.nii.gz"))
      ),
      call = structure(list(
        spec = structure(list(
          id = "test.tool",
          command = "testcmd",
          inputs = list(
            in_file = list(type = "string")
          ),
          runtime = list()
        ), class = "ni_spec"),
        values = list(in_file = "test_input.txt"),
        outputs = list(out_file = file.path(getwd(), "output.nii.gz"))
      ), class = "ni_call")
    ), class = "ni_result")

    prov_path <- file.path(getwd(), "output_provenance.json")
    written <- ni_provenance_write(result, prov_path)
    expect_true(file.exists(written))

    # Read back
    prov <- ni_provenance_read(written)
    expect_equal(prov$spec_id, "test.tool")
    expect_equal(prov$command, "testcmd")
    expect_equal(prov$args, c("arg1", "arg2"))
    expect_equal(prov$exit_status, 0L)
  })
})

test_that("ni_provenance_read errors on missing file", {
  expect_error(ni_provenance_read("/nonexistent/prov.json"), "not found")
})

# Tests for internal functions

test_that("get_tool_version returns NULL when no version info", {
  spec <- structure(list(
    id = "test.tool",
    command = "testcmd",
    inputs = list(),
    runtime = list()
  ), class = "ni_spec")

  result <- niflowr:::get_tool_version(spec)
  expect_null(result)
})

test_that("get_tool_version returns NULL when command not found", {
  spec <- structure(list(
    id = "test.tool",
    command = "nonexistent_command_xyz",
    inputs = list(),
    runtime = list(
      version = list(args = c("--version"))
    )
  ), class = "ni_spec")

  result <- niflowr:::get_tool_version(spec)
  expect_null(result)
})

test_that("get_tool_version returns version string for valid command", {
  spec <- structure(list(
    id = "test.tool",
    command = "echo",
    inputs = list(),
    runtime = list(
      version = list(args = c("test_version"))
    )
  ), class = "ni_spec")

  result <- niflowr:::get_tool_version(spec)
  expect_type(result, "character")
  expect_true(nzchar(result))
})

test_that("ni_provenance_write with auto-derived path", {
  withr::with_tempdir({
    out_file <- file.path(getwd(), "output.nii.gz")
    writeLines("test", out_file)

    result <- structure(list(
      spec_id = "test.tool",
      outputs = list(out_file = out_file),
      runtime = list(
        exit_status = 0L,
        stdout = "",
        stderr = "",
        duration_secs = 1.5,
        start_time = Sys.time(),
        end_time = Sys.time()
      ),
      provenance = list(
        spec_id = "test.tool",
        command = "testcmd",
        args = c("arg1"),
        exit_status = 0L,
        start_time = format(Sys.time()),
        end_time = format(Sys.time()),
        duration_secs = 1.5,
        outputs = list(out_file = out_file)
      ),
      call = structure(list(
        spec = structure(list(
          id = "test.tool",
          command = "testcmd",
          inputs = list(),
          runtime = list()
        ), class = "ni_spec"),
        values = list(),
        outputs = list(out_file = out_file)
      ), class = "ni_call")
    ), class = "ni_result")

    # Auto-derive path from primary output
    written <- ni_provenance_write(result, path = NULL)
    expect_true(file.exists(written))
    expect_true(grepl("_provenance\\.json$", written))
  })
})

test_that("ni_provenance_write with file inputs includes input_hashes", {
  withr::with_tempdir({
    in_file <- file.path(getwd(), "input.txt")
    out_file <- file.path(getwd(), "output.nii.gz")
    writeLines("test input", in_file)
    writeLines("test output", out_file)

    result <- structure(list(
      spec_id = "test.tool",
      outputs = list(out_file = out_file),
      runtime = list(
        exit_status = 0L,
        stdout = "",
        stderr = "",
        duration_secs = 1.5,
        start_time = Sys.time(),
        end_time = Sys.time()
      ),
      provenance = list(
        spec_id = "test.tool",
        command = "testcmd",
        args = c("arg1"),
        exit_status = 0L,
        start_time = format(Sys.time()),
        end_time = format(Sys.time()),
        duration_secs = 1.5,
        outputs = list(out_file = out_file)
      ),
      call = structure(list(
        spec = structure(list(
          id = "test.tool",
          command = "testcmd",
          inputs = list(
            in_file = list(type = "file")
          ),
          runtime = list()
        ), class = "ni_spec"),
        values = list(in_file = in_file),
        outputs = list(out_file = out_file)
      ), class = "ni_call")
    ), class = "ni_result")

    prov_path <- file.path(getwd(), "output_provenance.json")
    written <- ni_provenance_write(result, prov_path)

    prov <- ni_provenance_read(written)
    expect_true(!is.null(prov$input_hashes))
    expect_true("in_file" %in% names(prov$input_hashes))
  })
})
