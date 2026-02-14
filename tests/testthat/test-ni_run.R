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

test_that("ni_run honors lockfile container refs when enforcement is enabled", {
  withr::with_tempdir({
    on.exit(ni_config(.reset = TRUE, auto_read = FALSE), add = TRUE)
    ni_config(.reset = TRUE, auto_read = FALSE)

    in_root <- file.path(getwd(), "in")
    out_root <- file.path(getwd(), "out")
    work_root <- file.path(getwd(), "work")
    dir.create(in_root)
    dir.create(out_root)
    dir.create(work_root)

    in_file <- file.path(in_root, "input.txt")
    file.create(in_file)

    lock_path <- file.path(getwd(), "niflowr.lock.yml")

    cfg_override <- list(
      runtime = list(
        engine = "auto",
        prefer = "docker",
        lockfile = lock_path,
        lock_enforce = TRUE
      ),
      paths = list(
        in_root = in_root,
        out_root = out_root,
        work_root = work_root
      ),
      docker = list(
        bin = "echo"
      ),
      apptainer = list(
        bin = "echo",
        use_sif = FALSE
      ),
      profiles = list(
        fsl = list(
          docker_image = "ghcr.io/example/fsl:1.0@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        )
      )
    )
    ni_config(config = cfg_override)

    bad_lock <- list(
      lock_version = "0.1",
      profiles = list(
        fsl = list(
          docker = list(
            configured_ref = "ghcr.io/example/fsl:9.9@sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
            resolved_ref = "ghcr.io/example/fsl:9.9@sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
          )
        )
      )
    )
    niflowr:::ni_lock_write(bad_lock, lock_path)

    spec <- structure(list(
      spec_version = "0.1.0",
      id = "test.container_lock",
      command = "echo",
      inputs = list(
        in_file = list(
          type = "file",
          required = TRUE,
          cli = list(argstr = "%s", position = 0L)
        ),
        out_file = list(
          type = "file",
          required = TRUE,
          cli = list(argstr = "%s", position = 1L)
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
    ), class = "ni_spec")

    call <- ni_call(
      spec,
      in_file = in_file,
      out_file = file.path(out_root, "out.txt"),
      .engine = "docker",
      .profile = "fsl",
      .validate = FALSE
    )

    result <- ni_run(call, provenance = FALSE, error_on_status = FALSE)
    expect_equal(result$runtime$exit_status, 0L)
    expect_equal(
      result$provenance$host_command$container_ref,
      "ghcr.io/example/fsl:9.9@sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
    )
  })
})

test_that("ni_run uses lockfile-resolved docker ref when enforcement is enabled", {
  withr::with_tempdir({
    on.exit(ni_config(.reset = TRUE, auto_read = FALSE), add = TRUE)
    ni_config(.reset = TRUE, auto_read = FALSE)

    in_root <- file.path(getwd(), "in")
    out_root <- file.path(getwd(), "out")
    work_root <- file.path(getwd(), "work")
    dir.create(in_root)
    dir.create(out_root)
    dir.create(work_root)

    in_file <- file.path(in_root, "input.txt")
    file.create(in_file)

    lock_path <- file.path(getwd(), "niflowr.lock.yml")
    resolved_ref <- "ghcr.io/example/fsl@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

    cfg_override <- list(
      runtime = list(
        engine = "auto",
        prefer = "docker",
        lockfile = lock_path,
        lock_enforce = TRUE
      ),
      paths = list(
        in_root = in_root,
        out_root = out_root,
        work_root = work_root
      ),
      docker = list(
        bin = "echo"
      ),
      apptainer = list(
        bin = "echo",
        use_sif = FALSE
      ),
      profiles = list(
        fsl = list(
          docker_image = "ghcr.io/example/fsl:latest"
        )
      )
    )
    ni_config(config = cfg_override)

    lock <- list(
      lock_version = "0.1",
      profiles = list(
        fsl = list(
          docker = list(
            configured_ref = "ghcr.io/example/fsl:latest",
            resolved_ref = resolved_ref
          )
        )
      )
    )
    niflowr:::ni_lock_write(lock, lock_path)

    spec <- structure(list(
      spec_version = "0.1.0",
      id = "test.container_lock_use_ref",
      command = "echo",
      inputs = list(
        in_file = list(
          type = "file",
          required = TRUE,
          cli = list(argstr = "%s", position = 0L)
        ),
        out_file = list(
          type = "file",
          required = TRUE,
          cli = list(argstr = "%s", position = 1L)
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
    ), class = "ni_spec")

    call <- ni_call(
      spec,
      in_file = in_file,
      out_file = file.path(out_root, "out.txt"),
      .engine = "docker",
      .profile = "fsl",
      .validate = FALSE
    )

    result <- ni_run(call, provenance = FALSE, error_on_status = FALSE)
    expect_equal(result$runtime$exit_status, 0L)
    expect_equal(result$provenance$host_command$container_ref, resolved_ref)
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

# ---- Additional ni_run tests ----

test_that("ni_dry_run is a shorthand for dry_run=TRUE", {
  # Use a simple test spec that doesn't require container execution
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

test_that("ni_run with return='files' returns character vector", {
  skip_on_cran()
  skip_if_no_processx()

  withr::with_tempdir({
    out_path <- file.path(getwd(), "output.txt")
    spec <- structure(list(
      spec_version = "0.1.0", id = "test.touch", command = "touch",
      inputs = list(out_file = list(type = "file", required = TRUE, cli = list(argstr = "%s", position = 0L))),
      outputs = list(out_file = list(type = "file", path = list(from_input = "out_file"), must_exist = TRUE)),
      runtime = list()
    ), class = "ni_spec")
    call <- ni_call(spec, out_file = out_path, .validate = FALSE)
    files <- ni_run(call, echo = FALSE, provenance = FALSE, return = "files")
    expect_s3_class(files, "ni_files")
    expect_true(length(files) > 0)
    expect_true(!is.null(attr(files, "ni_result")))
  })
})

test_that("check_outputs warns on missing expected files", {
  call <- structure(list(
    spec = structure(list(
      outputs = list(out_file = list(must_exist = TRUE))
    ), class = "ni_spec"),
    outputs = list(out_file = "/nonexistent/path.nii.gz")
  ), class = "ni_call")
  warnings <- niflowr:::check_outputs(call)
  expect_true(length(warnings) > 0)
  expect_match(warnings[1], "not found")
})

test_that("check_outputs returns empty warnings when no must_exist outputs", {
  call <- structure(list(
    spec = structure(list(
      outputs = list(out_file = list(must_exist = FALSE))
    ), class = "ni_spec"),
    outputs = list(out_file = "/nonexistent/path.nii.gz")
  ), class = "ni_call")
  warnings <- niflowr:::check_outputs(call)
  expect_equal(length(warnings), 0)
})
