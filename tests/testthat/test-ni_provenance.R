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
