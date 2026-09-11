test_that("no spec input is typed string while rendering a numeric format", {
  files <- list.files(system.file("specs", package = "niflowr"), "[.]json$", full.names = TRUE)
  if (!length(files)) files <- list.files(testthat::test_path("..", "..", "inst", "specs"), "[.]json$", full.names = TRUE)
  bad <- character()
  for (f in files) {
    s <- jsonlite::read_json(f)
    for (nm in names(s$inputs)) {
      v <- s$inputs[[nm]]
      a <- v$cli$argstr %||% ""
      if (identical(v$type, "string") && grepl("%[dfg]", a)) bad <- c(bad, paste0(basename(f), ":", nm))
    }
  }
  expect_identical(bad, character())
})

test_that("fsl.fast in_files maps into containers as files", {
  f <- system.file("specs", "fsl.fast.json", package = "niflowr")
  if (!nzchar(f)) f <- testthat::test_path("..", "..", "inst", "specs", "fsl.fast.json")
  expect_identical(jsonlite::read_json(f)$inputs$in_files$items_type, "file")
})
