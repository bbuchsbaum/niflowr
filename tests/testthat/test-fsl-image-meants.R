test_that("image_meants keeps requested .txt/.tsv paths and requires the output", {
  for (ext in c(".txt", ".tsv")) {
    requested <- paste0("/tmp/requested_mean", ext)
    call <- ni_call(
      "fsl.image_meants",
      in_file = "/tmp/mcf.nii.gz",
      out_file = requested,
      order = 1L,
      .validate = FALSE
    )
    built <- niflowr:::build_command(call)
    out_idx <- which(built$args == "-o")
    expect_length(out_idx, 1L)
    expect_equal(built$args[[out_idx + 1L]], requested)
    expect_equal(call$outputs$out_file, requested)
  }

  spec <- ni_spec_read("fsl.image_meants")
  expect_false(isTRUE(spec$inputs$out_file$cli$strip_ext))
  expect_true(isTRUE(spec$outputs$out_file$must_exist))
  expect_false(niflowr:::fsl_needs_strip_ext(
    "out_file",
    spec$inputs$out_file$cli$argstr,
    spec$inputs$out_file$desc
  ))
})

test_that("image_meants text outs survive container path rewriting", {
  withr::with_tempdir({
    roots <- list(
      in_root = file.path(getwd(), "in"),
      out_root = file.path(getwd(), "out"),
      work_root = file.path(getwd(), "work")
    )
    for (d in roots) dir.create(d, recursive = TRUE)

    in_file <- file.path(roots$in_root, "mcf.nii.gz")
    file.create(in_file)
    for (ext in c(".txt", ".tsv")) {
      requested <- file.path(roots$out_root, paste0("requested_mean", ext))
      call <- ni_call(
        "fsl.image_meants",
        in_file = in_file,
        out_file = requested,
        order = 1L,
        .engine = "docker",
        .profile = "fsl",
        .validate = FALSE
      )
      cfg <- ni_config_defaults()
      cfg$paths$in_root <- roots$in_root
      cfg$paths$out_root <- roots$out_root
      cfg$paths$work_root <- roots$work_root
      mapped <- niflowr:::ni_rewrite_values_for_container(call$spec, call$values, cfg)
      expect_equal(mapped$out_file, paste0("/out/requested_mean", ext))

      mapped_call <- call
      mapped_call$values <- mapped
      built <- niflowr:::build_command(mapped_call)
      out_idx <- which(built$args == "-o")
      expect_equal(built$args[[out_idx + 1L]], paste0("/out/requested_mean", ext))
      expect_equal(call$outputs$out_file, requested)
    }
  })
})

test_that("missing image_meants out_file fails even when exit status is zero", {
  wd <- withr::local_tempdir()
  out <- file.path(wd, "requested_mean.txt")
  # Subprocess succeeds but never writes the declared text matrix.
  spec <- structure(
    list(
      spec_version = "0.1.0",
      id = "fsl.image_meants",
      command = "true",
      inputs = list(
        in_file = list(type = "file", required = TRUE, cli = list(argstr = "-i %s")),
        out_file = list(
          type = "file",
          desc = "name of output text matrix",
          cli = list(argstr = "-o %s", strip_ext = FALSE)
        )
      ),
      outputs = list(
        out_file = list(
          type = "file",
          path = list(from_input = "out_file"),
          must_exist = TRUE
        )
      ),
      runtime = list(profile = "fsl")
    ),
    class = "ni_spec"
  )
  call <- ni_call(spec, in_file = file.path(wd, "mcf.nii.gz"), out_file = out,
                  .cwd = wd, .engine = "native", .validate = FALSE)
  file.create(call$values$in_file)
  e <- tryCatch(ni_run(call, provenance = FALSE), ni_execution_error = identity)
  expect_s3_class(e, "ni_execution_error")
  expect_equal(e$result$runtime$exit_status, 0L)
  expect_false(e$result$runtime$success)
  expect_false(file.exists(out))
  expect_match(conditionMessage(e), "out_file|not found|Expected output", ignore.case = TRUE)
})

test_that("image_meants smoke writes the declared text matrix with one row per volume", {
  wd <- withr::local_tempdir()
  bin <- file.path(wd, "bin")
  dir.create(bin)
  # Fake fslmeants: honor -o and emit one row per synthetic volume.
  writeLines(c(
    "#!/bin/sh",
    "out=",
    "while [ $# -gt 0 ]; do",
    "  if [ \"$1\" = \"-o\" ]; then out=$2; shift 2; continue; fi",
    "  shift",
    "done",
    "printf '1.0\\n2.0\\n3.0\\n4.0\\n' > \"$out\""
  ), file.path(bin, "fslmeants"))
  Sys.chmod(file.path(bin, "fslmeants"), "0755")
  withr::local_path(bin)

  in_file <- file.path(wd, "mcf.nii.gz")
  # Four-volume placeholder is enough for the output contract; fslmeants is stubbed.
  writeBin(raw(16), in_file)
  requested <- file.path(wd, "requested_mean.txt")

  r <- ni_run(
    ni_call(
      "fsl.image_meants",
      in_file = in_file,
      out_file = requested,
      order = 1L,
      .cwd = wd,
      .engine = "native",
      .validate = FALSE
    ),
    provenance = FALSE
  )
  expect_true(r$runtime$success)
  expect_true(file.exists(requested))
  expect_equal(normalizePath(r$outputs$out_file), normalizePath(requested))
  expect_equal(length(readLines(requested)), 4L)
  expect_false(file.exists(sub("[.]txt$", "", requested)))
})

test_that("lint fix clears incorrect strip_ext on image_meants text outs", {
  withr::with_tempdir({
    spec_path <- file.path(getwd(), "fsl.image_meants.json")
    spec <- list(
      spec_version = "0.1.0",
      id = "fsl.image_meants",
      title = "FSL ImageMeants",
      command = "fslmeants",
      inputs = list(
        in_file = list(
          type = "file",
          required = TRUE,
          cli = list(argstr = "-i %s", position = 0)
        ),
        out_file = list(
          type = "file",
          desc = "name of output text matrix",
          cli = list(argstr = "-o %s", strip_ext = TRUE)
        )
      ),
      outputs = list(
        out_file = list(
          type = "file",
          path = list(from_input = "out_file"),
          must_exist = FALSE
        )
      ),
      runtime = list(profile = "fsl")
    )
    jsonlite::write_json(spec, spec_path, pretty = TRUE, auto_unbox = TRUE, null = "null")

    findings <- ni_lint_specs(spec_paths = spec_path, fix = TRUE, write = TRUE, strict = FALSE)
    expect_true(any(findings$code == "fsl_strip_ext_clear" & findings$fixed))

    fixed <- jsonlite::read_json(spec_path, simplifyVector = FALSE)
    expect_null(fixed$inputs$out_file$cli$strip_ext)
  })
})
