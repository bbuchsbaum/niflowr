test_that("print.ni_result shows stderr for failed result", {
  result <- structure(list(
    spec_id = "test.fail",
    outputs = list(),
    runtime = list(
      exit_status = 1L,
      stdout = "",
      stderr = "Error: something went wrong\nDetails here",
      duration_secs = 0.1,
      start_time = Sys.time(),
      end_time = Sys.time()
    ),
    provenance = list(),
    call = list()
  ), class = "ni_result")

  output <- capture.output(print(result), type = "message")
  expect_true(any(grepl("FAILED", output)))
  expect_true(any(grepl("Stderr", output)))
})

test_that("ni_provenance extracts provenance from result", {
  result <- structure(list(
    provenance = list(spec_id = "test", engine = "native"),
    outputs = list(),
    runtime = list(),
    call = list()
  ), class = "ni_result")

  prov <- ni_provenance(result)
  expect_equal(prov$spec_id, "test")
  expect_equal(prov$engine, "native")
})
