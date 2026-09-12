contract_spec <- function(command = "true", inputs = list(), outputs = list(), runtime = list()) {
  structure(list(spec_version = "0.1.0", id = "test.contract", command = command,
    inputs = inputs, outputs = outputs, runtime = runtime), class = "ni_spec")
}
contract_rscript <- function(code, ...) {
  spec <- contract_spec(c(file.path(R.home("bin"), "Rscript"), "--vanilla", "-e", code), ...)
  spec
}
contract_output <- function() list(out = list(type = "file", path = list(from_input = "out"), must_exist = TRUE))

test_that("effective environment reaches the native payload with last-wins precedence", {
  withr::local_tempdir() -> wd
  withr::defer(ni_config(.reset = TRUE, auto_read = FALSE))
  ni_config(.reset = TRUE, auto_read = FALSE)
  ni_config(config = list(env = list(NIFLOWR_VALUE = "config")))
  spec <- contract_rscript('cat(Sys.getenv("NIFLOWR_VALUE"))', runtime = list(env = list(NIFLOWR_VALUE = "spec")))
  result <- ni_run(ni_call(spec, .cwd = wd, .engine = "native", .env = c(NIFLOWR_VALUE = "call")), provenance = FALSE)
  expect_equal(result$runtime$stdout, "call")
  expect_equal(result$provenance$plan$environment$NIFLOWR_VALUE, "call")
  expect_error(ni_env_vector(list(A = c("1", "2"))), "scalars")
  expect_error(ni_env_vector(c(A = NA_character_)), "missing")
  expect_error(ni_env_vector(setNames("x", "")), "variable names")
})

test_that("public required defaults agree with generic calls", {
  wd <- withr::local_tempdir(); input <- file.path(wd, "in.nii.gz"); file.create(input)
  wrapper <- ni_ants_n4_bias_field_correction(input_image = input,
    output_image = file.path(wd, "out.nii.gz"), .engine = "native", dry_run = TRUE)
  generic <- ni_plan(ni_call("ants.n4_bias_field_correction", input_image = input,
    output_image = file.path(wd, "out.nii.gz"), dimension = 3, rescale_intensities = FALSE, .engine = "native"))
  expect_equal(wrapper$execution, generic$execution)
  expect_false(wrapper$call$values$save_bias)
  expect_error(ni_ants_n4_bias_field_correction(dry_run = TRUE), "input_image")
  spec <- ni_spec_read("fsl.eddy_correct")
  required <- names(Filter(function(d) isTRUE(d$required) && is.null(d$default), spec$inputs))
  args <- setNames(rep(list(input), length(required)), required)
  p <- do.call(ni_fsl_eddy_correct, c(args, list(.engine = "native", dry_run = TRUE)))
  g <- ni_plan(do.call(ni_call, c(list(spec), args, list(.engine = "native"))))
  expect_equal(p$call$values$ref_num, g$call$values$ref_num)
})

test_that("missing and stale outputs cannot produce success", {
  wd <- withr::local_tempdir(); out <- file.path(wd, "out.txt")
  spec <- contract_spec(inputs = list(out = list(type = "file")), outputs = contract_output())
  call <- ni_call(spec, out = out, .cwd = wd, .engine = "native")
  e <- tryCatch(ni_run(call), ni_execution_error = identity)
  expect_s3_class(e, "ni_execution_error")
  expect_equal(e$result$runtime$exit_status, 0L)
  expect_false(e$result$runtime$success)
  expect_true(file.exists(e$result$runtime$provenance_path))
  writeLines("stale", out)
  e <- tryCatch(ni_run(call), ni_execution_error = identity)
  expect_match(conditionMessage(e), "pre-existing")
  expect_identical(readLines(out), "stale")
  expect_error(ni_run(call, error_on_status = FALSE, return = "files"), class = "ni_execution_error")
})

test_that("stderr, failures, timeout and partial writes survive in the result", {
  wd <- withr::local_tempdir()
  spec <- contract_rscript('cat("unique-diagnostic", file=stderr()); quit(status=7)')
  e <- tryCatch(ni_run(ni_call(spec, .cwd = wd, .engine = "native"), echo = FALSE), ni_execution_error = identity)
  expect_match(conditionMessage(e), "unique-diagnostic")
  expect_equal(e$result$runtime$exit_status, 7L)
  expect_match(readLines(e$result$runtime$stderr_path, warn = FALSE), "unique-diagnostic")
  spec <- contract_rscript('writeLines("partial", "partial.txt"); Sys.sleep(30)')
  e <- tryCatch(ni_run(ni_call(spec, .cwd = wd, .engine = "native"), timeout = 1), ni_execution_error = identity)
  expect_true(e$result$runtime$timed_out)
  expect_lt(e$result$runtime$duration_secs, 8)
  expect_true(file.exists(file.path(wd, "partial.txt")))
  expect_true(file.exists(e$result$runtime$provenance_path))
})

test_that("collections and in-place inputs retain original identities", {
  wd <- withr::local_tempdir(); input <- file.path(wd, "data.txt"); writeLines("original", input)
  spec <- contract_rscript('writeLines("changed", "data.txt")',
    inputs = list(files = list(type = "list", items_type = "file"), out = list(type = "file", role = "inout")),
    outputs = contract_output())
  original <- digest::digest(file = input, algo = "sha256")
  r <- ni_run(ni_call(spec, files = input, out = input, .cwd = wd, .engine = "native"))
  expect_equal(r$provenance$input_identities$files[[1]]$hash, original)
  expect_equal(r$provenance$input_identities$out[[1]]$hash, original)
  expect_false(identical(r$provenance$output_identities[[1]]$hash, original))
  p <- ni_provenance_read(r$runtime$provenance_path)
  expect_true(p$success)
  expect_equal(p$plan$execution$command, r$provenance$plan$execution$command)
  expect_false(anyDuplicated(names(r$provenance$host_command)) > 0)
  writeLines("another change", input)
  expect_false(identical(ni_input_identities(r$call)$files[[1]]$hash, original))
})

test_that("FAST outputs remain typed collections and epi_reg separates supplied WM", {
  f <- ni_call("fsl.fast", in_files = "/tmp/brain.nii.gz", out_basename = "/tmp/seg", .validate = FALSE)
  expect_null(f$values$probability_maps)
  expect_equal(f$outputs$partial_volume_files, paste0("/tmp/seg_pve_", 0:2, ".nii.gz"))
  expect_false("-p" %in% ni_cmd(f)$args)
  g <- ni_call("fsl.fast", in_files = "/tmp/brain.nii.gz", out_basename = "/tmp/seg", number_classes = 4,
    probability_maps = TRUE, no_pve = TRUE, .validate = FALSE)
  expect_true(g$values$probability_maps)
  expect_length(g$outputs$probability_maps, 4)
  expect_null(g$outputs$partial_volume_files)
  expect_true("-p" %in% ni_cmd(g)$args)
  e <- ni_call("fsl.epi_reg", epi = "/tmp/epi.nii.gz", t1_head = "/tmp/t1.nii.gz", t1_brain = "/tmp/brain.nii.gz",
    wmseg = "/tmp/wm.nii.gz", out_base = "/tmp/reg", .validate = FALSE)
  expect_equal(e$outputs, list(out_file = "/tmp/reg.nii.gz", epi2str_mat = "/tmp/reg.mat"))
  expect_true("wmseg" %in% names(ni_input_identities(e)))
})

test_that("N4 emits a bias destination and rejects unsupported header copying", {
  x <- ni_call("ants.n4_bias_field_correction", input_image = "/tmp/in.nii.gz", output_image = "/tmp/out.nii.gz",
    save_bias = TRUE, .validate = FALSE)
  expect_true("[/tmp/out.nii.gz,/tmp/out_bias.nii.gz]" %in% ni_cmd(x)$args)
  expect_equal(x$outputs$bias_image, "/tmp/out_bias.nii.gz")
  x$values$copy_header <- TRUE
  expect_error(ni_cmd(x), "unsupported")
})

test_that("container protocols receive cwd and environment and retain host outputs", {
  wd <- withr::local_tempdir(); bin <- contract_runtime(wd)
  cfg <- contract_container_cfg(wd, bin)
  withr::defer(ni_config(.reset = TRUE, auto_read = FALSE))
  ni_config(.reset = TRUE, auto_read = FALSE); ni_config(config = cfg)
  for (engine in c("docker", "apptainer")) {
    cwd <- file.path(wd, "work", engine)
    spec <- contract_rscript('writeLines(Sys.getenv("NIFLOWR_VALUE"), "same.txt")',
      outputs = list(out = list(type = "file", path = list(static = "same.txt"), must_exist = TRUE)), runtime = list(profile = "test"))
    call <- ni_call(spec, .cwd = cwd, .env = c(NIFLOWR_VALUE = engine), .engine = engine)
    p <- ni_plan(call)
    expect_equal(p$container_cwd, paste0("/work/", engine))
    r <- ni_run(call, echo = FALSE)
    expect_equal(readLines(r$outputs$out), engine)
    expect_equal(normalizePath(r$outputs$out), normalizePath(file.path(cwd, "same.txt")))
    expect_equal(r$provenance$plan$container_cwd, p$container_cwd)
  }
  bad <- ni_call(spec, .cwd = file.path(wd, "outside"), .engine = "docker")
  expect_error(ni_plan(bad), "writable mounts")
  x <- ni_call("ants.n4_bias_field_correction", input_image = file.path(wd, "in", "input.nii.gz"),
    output_image = file.path(wd, "out", "corrected.nii.gz"), save_bias = TRUE,
    .profile = "test", .engine = "docker", .validate = FALSE)
  p <- ni_plan(x)
  expect_true("[/out/corrected.nii.gz,/out/corrected_bias.nii.gz]" %in% p$container_payload$args)
  expect_equal(basename(p$outputs$output_image), "corrected.nii.gz")
  expect_equal(normalizePath(dirname(p$outputs$output_image)), normalizePath(file.path(wd, "out")))
})

test_that("two simultaneous native invocations isolate the same relative output", {
  skip_on_os("windows")
  wd <- withr::local_tempdir()
  spec <- contract_rscript('Sys.sleep(.2); writeLines(basename(getwd()), "same.txt")',
    outputs = list(out = list(type = "file", path = list(static = "same.txt"), must_exist = TRUE)))
  jobs <- lapply(c("one", "two"), function(name) parallel::mcparallel(
    ni_run(ni_call(spec, .cwd = file.path(wd, name), .engine = "native"), provenance = FALSE)))
  results <- parallel::mccollect(jobs)
  expect_equal(sort(vapply(results, function(r) readLines(r$outputs$out), character(1))), c("one", "two"), ignore_attr = TRUE)
})

test_that("overrides retain inherited PATH for executable lookup", {
  wd <- withr::local_tempdir()
  spec <- contract_spec("echo", list(message = list(type = "string", cli = list(argstr = "%s"))))
  r <- ni_run(ni_call(spec, message = "path-kept", .cwd = wd, .engine = "native", .env = c(NIFLOWR_VALUE = "x")), provenance = FALSE)
  expect_equal(r$runtime$stdout, "path-kept")
})

test_that("epi_reg exposes the intermediate segmentation only with noclean", {
  args <- list("fsl.epi_reg", epi="epi.nii.gz",t1_head="head.nii.gz",t1_brain="brain.nii.gz",out_base="reg",.validate=FALSE)
  cleaned <- do.call(ni_call,args)
  kept <- do.call(ni_call,c(args,list(no_clean=TRUE)))
  expect_null(cleaned$outputs$seg)
  expect_equal(cleaned$outputs$wmseg,"reg_fast_wmseg.nii.gz")
  expect_equal(kept$outputs$seg,"reg_fast_seg.nii.gz")
})

test_that("N4 rescaling FALSE is explicit and cannot silently enable rescaling", {
  call <- ni_call("ants.n4_bias_field_correction", input_image="in.nii.gz",output_image="out.nii.gz",
                  rescale_intensities=FALSE,.validate=FALSE)
  args <- ni_cmd(call)$args
  expect_equal(args[match("-r",args)+1L],"0")
  call$values$rescale_intensities <- TRUE
  args <- ni_cmd(call)$args
  expect_equal(args[match("-r",args)+1L],"1")
})
