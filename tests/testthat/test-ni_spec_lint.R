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

test_that("output prefixes are typed as paths so containers rewrite them", {
  files <- list.files(system.file("specs", package = "niflowr"), "[.]json$", full.names = TRUE)
  if (!length(files)) files <- list.files(testthat::test_path("..", "..", "inst", "specs"), "[.]json$", full.names = TRUE)
  bad <- character()
  for (f in files) {
    s <- jsonlite::read_json(f)
    for (nm in names(s$inputs)) {
      v <- s$inputs[[nm]]
      if (!niflowr:::is_output_prefix_name(nm)) next
      if (!identical(v$type, "file")) bad <- c(bad, paste0(basename(f), ":", nm))
    }
  }
  expect_identical(bad, character())
})

test_that("FSL image outs declare cli.strip_ext", {
  files <- list.files(system.file("specs", package = "niflowr"), "^fsl\\..*[.]json$", full.names = TRUE)
  if (!length(files)) {
    files <- list.files(testthat::test_path("..", "..", "inst", "specs"), "^fsl\\..*[.]json$", full.names = TRUE)
  }
  missing <- character()
  for (f in files) {
    s <- jsonlite::read_json(f)
    for (nm in names(s$inputs)) {
      v <- s$inputs[[nm]]
      a <- v$cli$argstr %||% ""
      if (!niflowr:::fsl_needs_strip_ext(nm, a, v$desc)) next
      if (!isTRUE(v$cli$strip_ext)) missing <- c(missing, paste0(basename(f), ":", nm))
    }
  }
  expect_identical(missing, character())
})

test_that("FSL text/matrix outs do not declare cli.strip_ext", {
  files <- list.files(system.file("specs", package = "niflowr"), "^fsl\\..*[.]json$", full.names = TRUE)
  if (!length(files)) {
    files <- list.files(testthat::test_path("..", "..", "inst", "specs"), "^fsl\\..*[.]json$", full.names = TRUE)
  }
  bad <- character()
  for (f in files) {
    s <- jsonlite::read_json(f)
    for (nm in names(s$inputs)) {
      v <- s$inputs[[nm]]
      a <- v$cli$argstr %||% ""
      if (niflowr:::fsl_needs_strip_ext(nm, a, v$desc)) next
      if (isTRUE(v$cli$strip_ext)) bad <- c(bad, paste0(basename(f), ":", nm))
    }
  }
  expect_identical(bad, character())
})
