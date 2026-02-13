skip_if_no_processx <- function() {
  testthat::skip_if_not_installed("processx")
}

test_that("ni_run executes a simple command", {
  skip_on_cran()
  skip_if_no_processx()

  spec <- structure(list(
    spec_version = "0.1.0",
    id = "test.echo",
    command = "echo",
    inputs = list(
      message = list(
        type = "string",
        required = TRUE,
        cli = list(argstr = "%s", position = 0L)
      )
    ),
    outputs = list(),
    runtime = list()
  ), class = "ni_spec")

  call <- ni_call(spec, message = "hello_world", .validate = FALSE)
  result <- ni_run(call, echo = FALSE, provenance = FALSE)

  expect_s3_class(result, "ni_result")
  expect_equal(result$runtime$exit_status, 0L)
  expect_match(result$runtime$stdout, "hello_world")
})

test_that("ni_run dry_run prints but does not execute", {
  spec <- structure(list(
    spec_version = "0.1.0",
    id = "test.echo",
    command = "echo",
    inputs = list(
      message = list(
        type = "string",
        required = TRUE,
        cli = list(argstr = "%s", position = 0L)
      )
    ),
    outputs = list(),
    runtime = list()
  ), class = "ni_spec")

  call <- ni_call(spec, message = "hello", .validate = FALSE)
  result <- ni_run(call, dry_run = TRUE)
  expect_null(result)
})

test_that("ni_run warns on non-zero exit when error_on_status = FALSE", {
  skip_on_cran()
  skip_if_no_processx()

  spec <- structure(list(
    spec_version = "0.1.0",
    id = "test.fail",
    command = "false",
    inputs = list(),
    outputs = list(),
    runtime = list()
  ), class = "ni_spec")

  call <- ni_call(spec, .validate = FALSE)
  expect_warning(
    result <- ni_run(call, echo = FALSE, provenance = FALSE, error_on_status = FALSE),
    "exited with status"
  )
  expect_true(result$runtime$exit_status != 0)
})

test_that("ni_run errors on non-zero exit by default", {
  skip_on_cran()
  skip_if_no_processx()

  spec <- structure(list(
    spec_version = "0.1.0",
    id = "test.fail",
    command = "false",
    inputs = list(),
    outputs = list(),
    runtime = list()
  ), class = "ni_spec")

  call <- ni_call(spec, .validate = FALSE)
  expect_error(
    ni_run(call, echo = FALSE, provenance = FALSE),
    "exited with status"
  )
})

test_that("ni_run with file output writes provenance sidecar", {
  skip_on_cran()
  skip_if_no_processx()

  withr::with_tempdir({
    # Create a command that produces an output file
    out_path <- file.path(getwd(), "output.txt")

    spec <- structure(list(
      spec_version = "0.1.0",
      id = "test.touch",
      command = "touch",
      inputs = list(
        out_file = list(
          type = "file",
          required = TRUE,
          cli = list(argstr = "%s", position = 0L)
        )
      ),
      outputs = list(
        out_file = list(
          type = "file",
          path = list(from_input = "out_file"),
          must_exist = TRUE
        )
      ),
      runtime = list()
    ), class = "ni_spec")

    call <- ni_call(spec, out_file = out_path, .validate = FALSE)
    result <- ni_run(call, echo = FALSE, provenance = TRUE)

    expect_equal(result$runtime$exit_status, 0L)
    expect_true(file.exists(out_path))

    prov_path <- paste0(fs::path_ext_remove(out_path), "_provenance.json")
    expect_true(file.exists(prov_path))
  })
})

test_that("ni_outputs extracts output paths", {
  result <- structure(list(
    spec_id = "test",
    outputs = list(out_file = "/tmp/out.nii.gz", mask = "/tmp/mask.nii.gz"),
    runtime = list(),
    provenance = list(),
    call = list()
  ), class = "ni_result")

  outs <- ni_outputs(result)
  expect_equal(names(outs), c("out_file", "mask"))
  expect_equal(outs$out_file, "/tmp/out.nii.gz")
})

test_that("print.ni_result runs without error", {
  result <- structure(list(
    spec_id = "test.tool",
    outputs = list(out_file = "/tmp/out.nii.gz"),
    runtime = list(
      exit_status = 0L,
      stdout = "ok",
      stderr = "",
      duration_secs = 0.5,
      start_time = Sys.time(),
      end_time = Sys.time()
    ),
    provenance = list(),
    call = list()
  ), class = "ni_result")

  expect_no_error(capture.output(print(result), type = "message"))
})
