test_that("point transforms each get one flag and keep their CLI order", {
  build <- function(transforms, ...) {
    ni_cmd(ni_call("ants.apply_transforms_to_points", dimension = 3L,
      input_file = "input points.csv", transforms = transforms, ...))$args
  }
  prefix <- c("--dimensionality", "3", "--input", "input points.csv")
  expect_identical(build("warp.h5", output_file = "mapped.csv"),
    c(prefix, "--output", "mapped.csv", "--transform", "warp.h5"))
  expect_identical(build(list("warp.h5", "[my affine.mat,1]")),
    c(prefix, "--transform", "warp.h5", "--transform", "[my affine.mat,1]"))
  expect_error(build(character()), "non-empty transform")
  expect_error(build("[affine.mat,2]"), "Expected an ANTs transform")
})

test_that("point transform filenames are mounted and hashed inside inversion syntax", {
  wd <- withr::local_tempdir()
  cfg <- contract_container_cfg(wd, "docker")
  input <- c("plain warp.h5", "inverse affine.mat", "forward.mat")
  files <- file.path(normalizePath(wd), "in", input)
  for (i in seq_along(files)) writeLines(input[[i]], files[[i]])
  call <- ni_call("ants.apply_transforms_to_points", dimension = 3L,
    input_file = "in/points.csv", output_file = "out/mapped.csv", .cwd = wd,
    transforms = c("in/plain warp.h5", "[in/inverse affine.mat,1]", "[in/forward.mat,0]", "identity"))
  identities <- ni_input_identities(call)$transforms
  expect_identical(vapply(identities, "[[", "", "path"), files)
  expect_identical(vapply(identities, "[[", "", "hash"),
    vapply(files, function(path) digest::digest(file = path, algo = "sha256"), "", USE.NAMES = FALSE))
  call$values <- ni_rewrite_values_for_container(call$spec, call$values, cfg)
  expect_identical(ni_cmd(call)$args, c("--dimensionality", "3", "--input", "/in/points.csv",
    "--output", "/out/mapped.csv", "--transform", "/in/plain warp.h5",
    "--transform", "[/in/inverse affine.mat,1]", "--transform", "[/in/forward.mat,0]",
    "--transform", "identity"))
})

test_that("a successful process must produce the requested point CSV", {
  wd <- withr::local_tempdir()
  call <- ni_call("ants.apply_transforms_to_points", input_file = "points.csv",
    transforms = "warp.h5", dimension = 3L, output_file = "mapped.csv", .cwd = wd, .engine = "native")
  call$spec$command <- "true"
  error <- tryCatch(ni_run(call, provenance = FALSE), ni_execution_error = identity)
  expect_s3_class(error, "ni_execution_error")
  expect_identical(error$result$runtime$exit_status, 0L)
  expect_false(error$result$runtime$success)
  expect_match(conditionMessage(error), "Expected output output_file not found")

  omitted <- ni_call("ants.apply_transforms_to_points", input_file = "points.csv", transforms = "warp.h5")
  expect_length(omitted$outputs, 0L)
  expect_length(check_outputs(omitted), 0L)
})
