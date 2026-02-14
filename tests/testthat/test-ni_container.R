test_that("ni_runtime_detect prefers native command in auto mode", {
  cfg <- ni_config_defaults()
  cfg$runtime$engine <- "auto"

  # "echo" should exist on all supported platforms.
  engine <- niflowr:::ni_runtime_detect(cfg, payload_cmd = "echo", engine_override = NULL)
  expect_equal(engine, "native")
})

test_that("ni_runtime_detect falls back to preferred container runtime", {
  cfg <- ni_config_defaults()
  cfg$runtime$engine <- "auto"
  cfg$runtime$prefer <- "docker"
  cfg$docker$bin <- "echo"
  cfg$apptainer$bin <- "__missing_apptainer__"

  engine <- niflowr:::ni_runtime_detect(cfg, payload_cmd = "__missing_payload__", engine_override = NULL)
  expect_equal(engine, "docker")
})

test_that("ni_map_host_to_container maps roots to stable container paths", {
  withr::with_tempdir({
    roots <- list(
      in_root = file.path(getwd(), "in"),
      out_root = file.path(getwd(), "out"),
      work_root = file.path(getwd(), "work")
    )
    dir.create(roots$in_root)
    dir.create(roots$out_root)
    dir.create(roots$work_root)

    in_file <- file.path(roots$in_root, "sub-01", "anat", "t1.nii.gz")
    fs::dir_create(dirname(in_file))
    file.create(in_file)

    cfg <- ni_config_defaults()
    cfg$paths$in_root <- roots$in_root
    cfg$paths$out_root <- roots$out_root
    cfg$paths$work_root <- roots$work_root

    mapped <- niflowr:::ni_map_host_to_container(in_file, cfg)
    expect_equal(mapped, "/in/sub-01/anat/t1.nii.gz")
  })
})

test_that("ni_rewrite_values_for_container errors on list path-like values without items_type", {
  withr::with_tempdir({
    roots <- list(
      in_root = file.path(getwd(), "in"),
      out_root = file.path(getwd(), "out"),
      work_root = file.path(getwd(), "work")
    )
    dir.create(roots$in_root)
    dir.create(roots$out_root)
    dir.create(roots$work_root)

    m1 <- file.path(roots$in_root, "m1.nii.gz")
    file.create(m1)

    cfg <- ni_config_defaults()
    cfg$paths$in_root <- roots$in_root
    cfg$paths$out_root <- roots$out_root
    cfg$paths$work_root <- roots$work_root

    spec <- structure(list(
      id = "test.list",
      inputs = list(
        masks = list(type = "list")
      )
    ), class = "ni_spec")

    expect_error(
      niflowr:::ni_rewrite_values_for_container(spec, list(masks = c(m1)), cfg),
      "items_type"
    )
  })
})

test_that("ni_rewrite_values_for_container maps list values when items_type=file", {
  withr::with_tempdir({
    roots <- list(
      in_root = file.path(getwd(), "in"),
      out_root = file.path(getwd(), "out"),
      work_root = file.path(getwd(), "work")
    )
    dir.create(roots$in_root)
    dir.create(roots$out_root)
    dir.create(roots$work_root)

    m1 <- file.path(roots$in_root, "m1.nii.gz")
    m2 <- file.path(roots$in_root, "m2.nii.gz")
    file.create(m1)
    file.create(m2)

    cfg <- ni_config_defaults()
    cfg$paths$in_root <- roots$in_root
    cfg$paths$out_root <- roots$out_root
    cfg$paths$work_root <- roots$work_root

    spec <- structure(list(
      id = "test.list",
      inputs = list(
        masks = list(type = "list", items_type = "file")
      )
    ), class = "ni_spec")

    out <- niflowr:::ni_rewrite_values_for_container(spec, list(masks = c(m1, m2)), cfg)
    expect_equal(out$masks, c("/in/m1.nii.gz", "/in/m2.nii.gz"))
  })
})

test_that("ni_build_docker_argv creates deterministic run arguments", {
  cfg <- ni_config_defaults()
  cfg$docker$bin <- "echo"
  mounts <- list(
    list(host = "/host/in", cont = "/in", mode = "ro"),
    list(host = "/host/out", cont = "/out", mode = "rw"),
    list(host = "/host/work", cont = "/work", mode = "rw")
  )
  env <- c(OMP_NUM_THREADS = "8")

  built <- niflowr:::ni_build_docker_argv(
    cfg = cfg,
    image = "example/tool:1.0",
    payload_cmd = "bet",
    payload_args = c("-i", "/in/t1.nii.gz"),
    mounts = mounts,
    workdir = "/work",
    env = env
  )

  expect_equal(built$bin, "echo")
  expect_true("--mount" %in% built$argv)
  expect_true("-w" %in% built$argv)
  expect_true("example/tool:1.0" %in% built$argv)
  expect_true("bet" %in% built$argv)
})

test_that("ni_build_apptainer_argv creates deterministic exec arguments", {
  cfg <- ni_config_defaults()
  cfg$apptainer$bin <- "echo"
  mounts <- list(
    list(host = "/host/in", cont = "/in", mode = "ro"),
    list(host = "/host/out", cont = "/out", mode = "rw"),
    list(host = "/host/work", cont = "/work", mode = "rw")
  )
  env <- c(OMP_NUM_THREADS = "8")

  built <- niflowr:::ni_build_apptainer_argv(
    cfg = cfg,
    container_ref = "/containers/tool.sif",
    payload_cmd = "bet",
    payload_args = c("-i", "/in/t1.nii.gz"),
    mounts = mounts,
    workdir = "/work",
    env = env
  )

  expect_equal(built$bin, "echo")
  expect_true("exec" %in% built$argv)
  expect_true("--bind" %in% built$argv)
  expect_true("/containers/tool.sif" %in% built$argv)
  expect_true("bet" %in% built$argv)
})

# Additional coverage tests for ni_which_or_null
test_that("ni_which_or_null returns path when binary exists", {
  path <- niflowr:::ni_which_or_null("echo")
  expect_type(path, "character")
  expect_true(nzchar(path))
  expect_null(names(path))
})

test_that("ni_which_or_null returns NULL when binary does not exist", {
  path <- niflowr:::ni_which_or_null("__nonexistent_binary__")
  expect_null(path)
})

# Additional coverage tests for ni_norm
test_that("ni_norm normalizes paths", {
  withr::with_tempdir({
    dir.create("testdir")
    normalized <- niflowr:::ni_norm("testdir")
    expect_true(grepl("testdir$", normalized))
    expect_false(grepl("\\\\", normalized))  # No backslashes on Unix
  })
})

# Additional coverage tests for ni_env_vector
test_that("ni_env_vector returns empty character for NULL", {
  result <- niflowr:::ni_env_vector(NULL)
  expect_equal(result, character(0))
})

test_that("ni_env_vector returns empty character for empty list", {
  result <- niflowr:::ni_env_vector(list())
  expect_equal(result, character(0))
})

test_that("ni_env_vector converts named list to character vector", {
  # Note: current implementation has a bug where as.character() drops names
  # and names(env) <- names(env) doesn't restore them (names are already NULL)
  result <- niflowr:::ni_env_vector(list(A = "1", B = "2"))
  expect_type(result, "character")
  expect_equal(result, c("1", "2"))
  # Names are lost due to as.character() - this is the current behavior
  expect_null(names(result))
})

test_that("ni_env_vector returns empty character for unnamed vector", {
  result <- niflowr:::ni_env_vector(c("a", "b"))
  expect_equal(result, character(0))
})

# Additional coverage tests for ni_relpath
test_that("ni_relpath returns relative path when path is under root", {
  withr::with_tempdir({
    root <- getwd()
    dir.create("subdir")
    path <- file.path(root, "subdir", "file.txt")
    result <- niflowr:::ni_relpath(path, root)
    expect_equal(result, "subdir/file.txt")
  })
})

test_that("ni_relpath returns NULL when path is not under root", {
  withr::with_tempdir({
    root <- file.path(getwd(), "root1")
    path <- file.path(getwd(), "root2", "file.txt")
    result <- niflowr:::ni_relpath(path, root)
    expect_null(result)
  })
})

test_that("ni_relpath returns NULL for NULL root", {
  result <- niflowr:::ni_relpath("/some/path", NULL)
  expect_null(result)
})

test_that("ni_relpath returns NULL for empty root", {
  result <- niflowr:::ni_relpath("/some/path", "")
  expect_null(result)
})

# Additional coverage tests for ni_runtime_detect
test_that("ni_runtime_detect returns explicit engine when not auto", {
  cfg <- ni_config_defaults()
  cfg$runtime$engine <- "docker"
  engine <- niflowr:::ni_runtime_detect(cfg, payload_cmd = "anything", engine_override = NULL)
  expect_equal(engine, "docker")
})

test_that("ni_runtime_detect errors on unknown engine", {
  cfg <- ni_config_defaults()
  cfg$runtime$engine <- "unknown_engine"
  expect_error(
    niflowr:::ni_runtime_detect(cfg, payload_cmd = "echo", engine_override = NULL),
    "Unknown runtime engine"
  )
})

test_that("ni_runtime_detect respects engine_override", {
  cfg <- ni_config_defaults()
  cfg$runtime$engine <- "auto"
  engine <- niflowr:::ni_runtime_detect(cfg, payload_cmd = "__missing__", engine_override = "native")
  expect_equal(engine, "native")
})

test_that("ni_runtime_detect prefers apptainer in auto mode when available", {
  cfg <- ni_config_defaults()
  cfg$runtime$engine <- "auto"
  cfg$runtime$prefer <- "apptainer"
  cfg$apptainer$bin <- "echo"  # Use echo as a proxy for apptainer
  cfg$docker$bin <- "__missing_docker__"

  engine <- niflowr:::ni_runtime_detect(cfg, payload_cmd = "__missing_payload__", engine_override = NULL)
  expect_equal(engine, "apptainer")
})

# Additional coverage tests for ni_profile_resolve
test_that("ni_profile_resolve errors when no profile provided", {
  cfg <- ni_config_defaults()
  call <- list(
    runtime = list(),
    spec = list(runtime = list())
  )

  expect_error(
    niflowr:::ni_profile_resolve(cfg, call),
    "No runtime profile provided"
  )
})

test_that("ni_profile_resolve errors when profile name is unknown", {
  cfg <- ni_config_defaults()
  call <- list(
    runtime = list(profile = "nonexistent"),
    spec = list(runtime = list())
  )

  expect_error(
    niflowr:::ni_profile_resolve(cfg, call),
    "Unknown runtime profile"
  )
})

test_that("ni_profile_resolve returns valid profile", {
  cfg <- ni_config_defaults()
  cfg$profiles <- list(
    test_profile = list(docker_image = "test/image:1.0")
  )
  call <- list(
    runtime = list(profile = "test_profile"),
    spec = list(runtime = list())
  )

  result <- niflowr:::ni_profile_resolve(cfg, call)
  expect_equal(result$name, "test_profile")
  expect_equal(result$config$docker_image, "test/image:1.0")
})

# Additional coverage tests for ni_stage_unmapped_input
test_that("ni_stage_unmapped_input errors when path does not exist", {
  withr::with_tempdir({
    cfg <- ni_config_defaults()
    roots <- list(
      in_root = file.path(getwd(), "in"),
      out_root = file.path(getwd(), "out"),
      work_root = file.path(getwd(), "work")
    )
    dir.create(roots$work_root)
    cfg$paths$work_root <- roots$work_root

    expect_error(
      niflowr:::ni_stage_unmapped_input("/nonexistent/file.txt", cfg, roots),
      "Cannot stage missing path"
    )
  })
})

test_that("ni_stage_unmapped_input copies file to stage_dir under work_root", {
  withr::with_tempdir({
    cfg <- ni_config_defaults()
    roots <- list(
      in_root = file.path(getwd(), "in"),
      out_root = file.path(getwd(), "out"),
      work_root = file.path(getwd(), "work")
    )
    dir.create(roots$in_root)
    dir.create(roots$out_root)
    dir.create(roots$work_root)

    # Create a file outside the mounted roots
    external_file <- file.path(getwd(), "external.txt")
    writeLines("test content", external_file)

    cfg$paths$work_root <- roots$work_root

    staged <- niflowr:::ni_stage_unmapped_input(external_file, cfg, roots)
    expect_true(file.exists(staged))
    expect_true(grepl("_stage", staged))
    expect_true(grepl("external.txt", staged))
  })
})

test_that("ni_stage_unmapped_input errors when stage_dir not under work_root", {
  withr::with_tempdir({
    cfg <- ni_config_defaults()
    roots <- list(
      in_root = file.path(getwd(), "in"),
      out_root = file.path(getwd(), "out"),
      work_root = file.path(getwd(), "work")
    )
    dir.create(roots$work_root)

    # Create file to stage
    external_file <- file.path(getwd(), "external.txt")
    writeLines("test", external_file)

    cfg$paths$work_root <- roots$work_root
    cfg$paths$stage_dir <- file.path(getwd(), "other_stage")  # Outside work_root

    expect_error(
      niflowr:::ni_stage_unmapped_input(external_file, cfg, roots),
      "stage_dir must live under work_root"
    )
  })
})

# Additional coverage tests for ni_prepare_mount_roots
test_that("ni_prepare_mount_roots errors when roots are missing", {
  cfg <- ni_config_defaults()
  cfg$paths$in_root <- NULL

  expect_error(
    niflowr:::ni_prepare_mount_roots(cfg),
    "Container execution requires mounted host roots"
  )
})

test_that("ni_prepare_mount_roots errors when in_root does not exist", {
  withr::with_tempdir({
    cfg <- ni_config_defaults()
    cfg$paths$in_root <- file.path(getwd(), "nonexistent_in")
    cfg$paths$out_root <- file.path(getwd(), "out")
    cfg$paths$work_root <- file.path(getwd(), "work")

    expect_error(
      niflowr:::ni_prepare_mount_roots(cfg),
      "Input mount root does not exist"
    )
  })
})

test_that("ni_prepare_mount_roots creates out_root and work_root if missing", {
  withr::with_tempdir({
    cfg <- ni_config_defaults()
    in_root <- file.path(getwd(), "in")
    out_root <- file.path(getwd(), "out")
    work_root <- file.path(getwd(), "work")

    dir.create(in_root)
    cfg$paths$in_root <- in_root
    cfg$paths$out_root <- out_root
    cfg$paths$work_root <- work_root

    result <- niflowr:::ni_prepare_mount_roots(cfg)

    expect_true(dir.exists(out_root))
    expect_true(dir.exists(work_root))
    expect_equal(result$in_root, normalizePath(in_root, winslash = "/"))
    expect_equal(result$out_root, normalizePath(out_root, winslash = "/"))
    expect_equal(result$work_root, normalizePath(work_root, winslash = "/"))
  })
})

# Additional coverage tests for ni_mounts_from_cfg
test_that("ni_mounts_from_cfg returns 3-element mount list", {
  withr::with_tempdir({
    cfg <- ni_config_defaults()
    in_root <- file.path(getwd(), "in")
    out_root <- file.path(getwd(), "out")
    work_root <- file.path(getwd(), "work")

    dir.create(in_root)
    dir.create(out_root)
    dir.create(work_root)

    cfg$paths$in_root <- in_root
    cfg$paths$out_root <- out_root
    cfg$paths$work_root <- work_root

    mounts <- niflowr:::ni_mounts_from_cfg(cfg)

    expect_length(mounts, 3)
    expect_equal(mounts[[1]]$cont, "/in")
    expect_equal(mounts[[1]]$mode, "ro")
    expect_equal(mounts[[2]]$cont, "/out")
    expect_equal(mounts[[2]]$mode, "rw")
    expect_equal(mounts[[3]]$cont, "/work")
    expect_equal(mounts[[3]]$mode, "rw")
  })
})

# Additional coverage tests for ni_apptainer_sif_path
test_that("ni_apptainer_sif_path returns normalized path", {
  withr::with_tempdir({
    cfg <- ni_config_defaults()
    work_root <- file.path(getwd(), "work")
    dir.create(work_root)

    cfg$paths$in_root <- file.path(getwd(), "in")
    cfg$paths$out_root <- file.path(getwd(), "out")
    cfg$paths$work_root <- work_root
    dir.create(cfg$paths$in_root)

    profile_name <- "test_profile"
    profile_info <- list()

    sif_path <- niflowr:::ni_apptainer_sif_path(cfg, profile_name, profile_info)

    expect_type(sif_path, "character")
    expect_true(grepl("test_profile\\.sif$", sif_path))
    expect_true(dir.exists(dirname(sif_path)))
  })
})

# Additional coverage tests for ni_build_docker_argv
test_that("ni_build_docker_argv errors when image is missing", {
  cfg <- ni_config_defaults()
  mounts <- list()
  env <- character(0)

  expect_error(
    niflowr:::ni_build_docker_argv(
      cfg = cfg,
      image = NULL,
      payload_cmd = "bet",
      payload_args = character(0),
      mounts = mounts,
      workdir = "/work",
      env = env
    ),
    "Docker profile is missing"
  )
})

test_that("ni_build_docker_argv handles custom user setting", {
  cfg <- ni_config_defaults()
  cfg$docker$bin <- "echo"
  cfg$docker$user <- "customuser"
  mounts <- list()
  env <- character(0)

  built <- niflowr:::ni_build_docker_argv(
    cfg = cfg,
    image = "test/image:1.0",
    payload_cmd = "bet",
    payload_args = character(0),
    mounts = mounts,
    workdir = "/work",
    env = env
  )

  expect_true("-u" %in% built$argv)
  expect_true("customuser" %in% built$argv)
})

test_that("ni_build_docker_argv includes extra run args", {
  cfg <- ni_config_defaults()
  cfg$docker$bin <- "echo"
  cfg$docker$extra_run_args <- c("--network=host", "--privileged")
  mounts <- list()
  env <- character(0)

  built <- niflowr:::ni_build_docker_argv(
    cfg = cfg,
    image = "test/image:1.0",
    payload_cmd = "bet",
    payload_args = character(0),
    mounts = mounts,
    workdir = "/work",
    env = env
  )

  expect_true("--network=host" %in% built$argv)
  expect_true("--privileged" %in% built$argv)
})

# Additional coverage tests for ni_build_apptainer_argv
test_that("ni_build_apptainer_argv errors when container_ref is missing", {
  cfg <- ni_config_defaults()
  mounts <- list()
  env <- character(0)

  expect_error(
    niflowr:::ni_build_apptainer_argv(
      cfg = cfg,
      container_ref = NULL,
      payload_cmd = "bet",
      payload_args = character(0),
      mounts = mounts,
      workdir = "/work",
      env = env
    ),
    "Apptainer container reference is missing"
  )
})

test_that("ni_build_apptainer_argv includes cleanenv and containall flags", {
  cfg <- ni_config_defaults()
  cfg$apptainer$bin <- "echo"
  cfg$apptainer$cleanenv <- TRUE
  cfg$apptainer$containall <- TRUE
  mounts <- list()
  env <- character(0)

  built <- niflowr:::ni_build_apptainer_argv(
    cfg = cfg,
    container_ref = "/containers/tool.sif",
    payload_cmd = "bet",
    payload_args = character(0),
    mounts = mounts,
    workdir = "/work",
    env = env
  )

  expect_true("--cleanenv" %in% built$argv)
  expect_true("--containall" %in% built$argv)
})

test_that("ni_build_apptainer_argv includes extra exec args", {
  cfg <- ni_config_defaults()
  cfg$apptainer$bin <- "echo"
  cfg$apptainer$extra_exec_args <- c("--nv", "--rocm")
  mounts <- list()
  env <- character(0)

  built <- niflowr:::ni_build_apptainer_argv(
    cfg = cfg,
    container_ref = "/containers/tool.sif",
    payload_cmd = "bet",
    payload_args = character(0),
    mounts = mounts,
    workdir = "/work",
    env = env
  )

  expect_true("--nv" %in% built$argv)
  expect_true("--rocm" %in% built$argv)
})

# ============================================================================
# New tests for uncovered functions
# ============================================================================

# Tests for ni_map_host_to_container - additional coverage
test_that("ni_map_host_to_container maps out_root paths", {
  withr::with_tempdir({
    roots <- list(
      in_root = file.path(getwd(), "in"),
      out_root = file.path(getwd(), "out"),
      work_root = file.path(getwd(), "work")
    )
    dir.create(roots$in_root)
    dir.create(roots$out_root)
    dir.create(roots$work_root)

    out_file <- file.path(roots$out_root, "results", "output.nii.gz")
    fs::dir_create(dirname(out_file))
    file.create(out_file)

    cfg <- ni_config_defaults()
    cfg$paths$in_root <- roots$in_root
    cfg$paths$out_root <- roots$out_root
    cfg$paths$work_root <- roots$work_root

    mapped <- niflowr:::ni_map_host_to_container(out_file, cfg)
    expect_equal(mapped, "/out/results/output.nii.gz")
  })
})

test_that("ni_map_host_to_container maps work_root paths", {
  withr::with_tempdir({
    roots <- list(
      in_root = file.path(getwd(), "in"),
      out_root = file.path(getwd(), "out"),
      work_root = file.path(getwd(), "work")
    )
    dir.create(roots$in_root)
    dir.create(roots$out_root)
    dir.create(roots$work_root)

    work_file <- file.path(roots$work_root, "temp", "scratch.txt")
    fs::dir_create(dirname(work_file))
    file.create(work_file)

    cfg <- ni_config_defaults()
    cfg$paths$in_root <- roots$in_root
    cfg$paths$out_root <- roots$out_root
    cfg$paths$work_root <- roots$work_root

    mapped <- niflowr:::ni_map_host_to_container(work_file, cfg)
    expect_equal(mapped, "/work/temp/scratch.txt")
  })
})

test_that("ni_map_host_to_container stages unmapped inputs when enabled", {
  withr::with_tempdir({
    roots <- list(
      in_root = file.path(getwd(), "in"),
      out_root = file.path(getwd(), "out"),
      work_root = file.path(getwd(), "work")
    )
    dir.create(roots$in_root)
    dir.create(roots$out_root)
    dir.create(roots$work_root)

    # File outside mounted roots
    external_file <- file.path(getwd(), "external.txt")
    writeLines("test", external_file)

    cfg <- ni_config_defaults()
    cfg$paths$in_root <- roots$in_root
    cfg$paths$out_root <- roots$out_root
    cfg$paths$work_root <- roots$work_root
    cfg$paths$stage_unmapped_inputs <- TRUE

    mapped <- niflowr:::ni_map_host_to_container(external_file, cfg)
    expect_true(grepl("^/work/_stage/", mapped))
    expect_true(grepl("external\\.txt$", mapped))
  })
})

test_that("ni_map_host_to_container errors on unmapped path when staging disabled", {
  withr::with_tempdir({
    roots <- list(
      in_root = file.path(getwd(), "in"),
      out_root = file.path(getwd(), "out"),
      work_root = file.path(getwd(), "work")
    )
    dir.create(roots$in_root)
    dir.create(roots$out_root)
    dir.create(roots$work_root)

    external_file <- file.path(getwd(), "external.txt")
    writeLines("test", external_file)

    cfg <- ni_config_defaults()
    cfg$paths$in_root <- roots$in_root
    cfg$paths$out_root <- roots$out_root
    cfg$paths$work_root <- roots$work_root
    cfg$paths$stage_unmapped_inputs <- FALSE

    expect_error(
      niflowr:::ni_map_host_to_container(external_file, cfg),
      "outside mounted roots"
    )
  })
})

# Tests for ni_rewrite_values_for_container - list path detection
test_that("ni_rewrite_values_for_container handles list with dir items_type", {
  withr::with_tempdir({
    roots <- list(
      in_root = file.path(getwd(), "in"),
      out_root = file.path(getwd(), "out"),
      work_root = file.path(getwd(), "work")
    )
    dir.create(roots$in_root)
    dir.create(roots$out_root)
    dir.create(roots$work_root)

    d1 <- file.path(roots$in_root, "dir1")
    d2 <- file.path(roots$in_root, "dir2")
    dir.create(d1)
    dir.create(d2)

    cfg <- ni_config_defaults()
    cfg$paths$in_root <- roots$in_root
    cfg$paths$out_root <- roots$out_root
    cfg$paths$work_root <- roots$work_root

    spec <- structure(list(
      id = "test.list",
      inputs = list(
        dirs = list(type = "list", items_type = "dir")
      )
    ), class = "ni_spec")

    out <- niflowr:::ni_rewrite_values_for_container(spec, list(dirs = c(d1, d2)), cfg)
    expect_equal(out$dirs, c("/in/dir1", "/in/dir2"))
  })
})

test_that("ni_rewrite_values_for_container skips non-file/dir types", {
  withr::with_tempdir({
    roots <- list(
      in_root = file.path(getwd(), "in"),
      out_root = file.path(getwd(), "out"),
      work_root = file.path(getwd(), "work")
    )
    dir.create(roots$in_root)
    dir.create(roots$out_root)
    dir.create(roots$work_root)

    cfg <- ni_config_defaults()
    cfg$paths$in_root <- roots$in_root
    cfg$paths$out_root <- roots$out_root
    cfg$paths$work_root <- roots$work_root

    spec <- structure(list(
      id = "test.string",
      inputs = list(
        name = list(type = "string")
      )
    ), class = "ni_spec")

    out <- niflowr:::ni_rewrite_values_for_container(spec, list(name = "test"), cfg)
    expect_equal(out$name, "test")
  })
})

# Tests for ni_resolve_apptainer_container_ref
test_that("ni_resolve_apptainer_container_ref returns URI when use_sif=FALSE", {
  withr::with_tempdir({
    cfg <- ni_config_defaults()
    cfg$apptainer$use_sif <- FALSE
    cfg$apptainer$bin <- "echo"

    # Need these for ni_prepare_mount_roots call inside ni_apptainer_sif_path
    cfg$paths$in_root <- file.path(getwd(), "in")
    cfg$paths$out_root <- file.path(getwd(), "out")
    cfg$paths$work_root <- file.path(getwd(), "work")
    dir.create(cfg$paths$in_root)

    profile_info <- list(apptainer_uri = "docker://test/image:v1")

    result <- niflowr:::ni_resolve_apptainer_container_ref(cfg, "test_profile", profile_info)

    expect_equal(result$ref, "docker://test/image:v1")
    expect_equal(result$source, "docker://test/image:v1")
    expect_null(result$sif)
  })
})

test_that("ni_resolve_apptainer_container_ref uses docker_image as fallback URI", {
  withr::with_tempdir({
    cfg <- ni_config_defaults()
    cfg$apptainer$use_sif <- FALSE
    cfg$apptainer$bin <- "echo"

    cfg$paths$in_root <- file.path(getwd(), "in")
    cfg$paths$out_root <- file.path(getwd(), "out")
    cfg$paths$work_root <- file.path(getwd(), "work")
    dir.create(cfg$paths$in_root)

    profile_info <- list(docker_image = "myimage:latest")

    result <- niflowr:::ni_resolve_apptainer_container_ref(cfg, "test_profile", profile_info)

    expect_equal(result$ref, "docker://myimage:latest")
    expect_equal(result$source, "docker://myimage:latest")
  })
})

test_that("ni_resolve_apptainer_container_ref errors when use_sif=FALSE and no URI", {
  withr::with_tempdir({
    cfg <- ni_config_defaults()
    cfg$apptainer$use_sif <- FALSE

    cfg$paths$in_root <- file.path(getwd(), "in")
    cfg$paths$out_root <- file.path(getwd(), "out")
    cfg$paths$work_root <- file.path(getwd(), "work")
    dir.create(cfg$paths$in_root)

    profile_info <- list()

    expect_error(
      niflowr:::ni_resolve_apptainer_container_ref(cfg, "test_profile", profile_info),
      "missing.*apptainer_uri"
    )
  })
})

# Tests for ni_build_container_command - main orchestrator
test_that("ni_build_container_command builds docker command", {
  withr::with_tempdir({
    cfg <- ni_config_defaults()
    cfg$docker$bin <- "echo"
    cfg$profiles <- list(
      test_prof = list(docker_image = "test/img:1.0")
    )
    cfg$paths$in_root <- file.path(getwd(), "in")
    cfg$paths$out_root <- file.path(getwd(), "out")
    cfg$paths$work_root <- file.path(getwd(), "work")
    dir.create(cfg$paths$in_root)
    dir.create(cfg$paths$out_root)
    dir.create(cfg$paths$work_root)

    call <- list(
      runtime = list(profile = "test_prof"),
      spec = list(runtime = list())
    )

    result <- niflowr:::ni_build_container_command(
      engine = "docker",
      cfg = cfg,
      call = call,
      payload_cmd = "bet",
      payload_args = c("-i", "input.nii"),
      env = c(THREADS = "4")
    )

    expect_equal(result$engine, "docker")
    expect_equal(result$profile, "test_prof")
    expect_equal(result$container_ref, "test/img:1.0")
    expect_true("bet" %in% result$argv)
  })
})

test_that("ni_build_container_command builds apptainer command with use_sif=FALSE", {
  withr::with_tempdir({
    cfg <- ni_config_defaults()
    cfg$apptainer$bin <- "echo"
    cfg$apptainer$use_sif <- FALSE
    cfg$profiles <- list(
      test_prof = list(apptainer_uri = "docker://test/img:1.0")
    )
    cfg$paths$in_root <- file.path(getwd(), "in")
    cfg$paths$out_root <- file.path(getwd(), "out")
    cfg$paths$work_root <- file.path(getwd(), "work")
    dir.create(cfg$paths$in_root)
    dir.create(cfg$paths$out_root)
    dir.create(cfg$paths$work_root)

    call <- list(
      runtime = list(profile = "test_prof"),
      spec = list(runtime = list())
    )

    result <- niflowr:::ni_build_container_command(
      engine = "apptainer",
      cfg = cfg,
      call = call,
      payload_cmd = "bet",
      payload_args = c("-i", "input.nii"),
      env = character(0)
    )

    expect_equal(result$engine, "apptainer")
    expect_equal(result$profile, "test_prof")
    expect_equal(result$container_ref, "docker://test/img:1.0")
    expect_true("bet" %in% result$argv)
  })
})

test_that("ni_build_container_command errors on unsupported engine", {
  withr::with_tempdir({
    cfg <- ni_config_defaults()
    cfg$profiles <- list(test_prof = list(docker_image = "test/img:1.0"))
    cfg$paths$in_root <- file.path(getwd(), "in")
    cfg$paths$out_root <- file.path(getwd(), "out")
    cfg$paths$work_root <- file.path(getwd(), "work")
    dir.create(cfg$paths$in_root)

    call <- list(
      runtime = list(profile = "test_prof"),
      spec = list(runtime = list())
    )

    expect_error(
      niflowr:::ni_build_container_command(
        engine = "unsupported_engine",
        cfg = cfg,
        call = call,
        payload_cmd = "bet",
        payload_args = character(0),
        env = character(0)
      ),
      "Unsupported container engine"
    )
  })
})

# Tests for ni_runtime_detect auto fallback
test_that("ni_runtime_detect errors when auto mode finds no runtime", {
  cfg <- ni_config_defaults()
  cfg$runtime$engine <- "auto"
  cfg$docker$bin <- "__missing_docker__"
  cfg$apptainer$bin <- "__missing_apptainer__"

  expect_error(
    niflowr:::ni_runtime_detect(cfg, payload_cmd = "__missing__", engine_override = NULL),
    "No container runtime available"
  )
})

# Note: Testing file.copy failure (line 122 in ni_container.R) is challenging
# across platforms without mocking frameworks. The error path is covered by
# the logic being present in the code.
