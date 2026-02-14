test_that("ni_pin writes lockfile with configured profiles", {
  withr::with_tempdir({
    cfg <- ni_config_defaults()
    cfg$runtime$lockfile <- file.path(getwd(), "niflowr.lock.yml")
    cfg$paths$in_root <- file.path(getwd(), "in")
    cfg$paths$out_root <- file.path(getwd(), "out")
    cfg$paths$work_root <- file.path(getwd(), "work")
    dir.create(cfg$paths$in_root)
    dir.create(cfg$paths$out_root)
    dir.create(cfg$paths$work_root)

    cfg$profiles <- list(
      fsl = list(
        docker_image = "ghcr.io/example/fsl:1.0@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        apptainer_uri = "docker://ghcr.io/example/fsl:1.0@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        sif_name = "fsl.sif"
      )
    )

    lock <- ni_pin(cfg = cfg, path = cfg$runtime$lockfile, pull = FALSE, include_specs = FALSE)
    expect_true(file.exists(cfg$runtime$lockfile))
    expect_true("fsl" %in% names(lock$profiles))
    expect_equal(
      lock$profiles$fsl$docker$digest,
      "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    )
  })
})

test_that("ni_lock_validate reports mismatch against config", {
  withr::with_tempdir({
    cfg <- ni_config_defaults()
    cfg$runtime$lockfile <- file.path(getwd(), "niflowr.lock.yml")
    cfg$profiles <- list(
      fsl = list(
        docker_image = "ghcr.io/example/fsl:1.0@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        apptainer_uri = "docker://ghcr.io/example/fsl:1.0@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
      )
    )

    ni_pin(cfg = cfg, path = cfg$runtime$lockfile, pull = FALSE, include_specs = FALSE)

    cfg2 <- cfg
    cfg2$profiles$fsl$docker_image <- "ghcr.io/example/fsl:2.0@sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"

    report <- ni_lock_validate(path = cfg$runtime$lockfile, cfg = cfg2, strict = FALSE)
    expect_true(any(report$status == "fail"))
    expect_true(any(report$check == "docker_configured_ref"))
  })
})

test_that("ni_lock_validate strict aborts on failures", {
  withr::with_tempdir({
    cfg <- ni_config_defaults()
    cfg$runtime$lockfile <- file.path(getwd(), "niflowr.lock.yml")
    cfg$profiles <- list(
      fsl = list(
        docker_image = "ghcr.io/example/fsl:1.0@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
      )
    )

    ni_pin(cfg = cfg, path = cfg$runtime$lockfile, pull = FALSE, include_specs = FALSE)
    cfg$profiles$fsl$docker_image <- "ghcr.io/example/fsl:2.0@sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"

    expect_error(
      ni_lock_validate(path = cfg$runtime$lockfile, cfg = cfg, strict = TRUE),
      "Lock validation failed"
    )
  })
})

test_that("ni_lock_enforce_profile fails on mismatch", {
  withr::with_tempdir({
    cfg <- ni_config_defaults()
    cfg$runtime$lockfile <- file.path(getwd(), "niflowr.lock.yml")
    cfg$runtime$lock_enforce <- TRUE
    cfg$profiles <- list(
      fsl = list(
        docker_image = "ghcr.io/example/fsl:1.0@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
      )
    )
    ni_pin(cfg = cfg, path = cfg$runtime$lockfile, pull = FALSE, include_specs = FALSE)

    expect_error(
      niflowr:::ni_lock_enforce_profile(
        cfg = cfg,
        engine = "docker",
        profile = "fsl",
        container_ref = "ghcr.io/example/fsl:2.0@sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
      ),
      "Lock enforcement failed"
    )
  })
})

test_that("ni_pin records SIF path as apptainer resolved_ref when use_sif is enabled", {
  withr::with_tempdir({
    cfg <- ni_config_defaults()
    cfg$runtime$lockfile <- file.path(getwd(), "niflowr.lock.yml")
    cfg$paths$in_root <- file.path(getwd(), "in")
    cfg$paths$out_root <- file.path(getwd(), "out")
    cfg$paths$work_root <- file.path(getwd(), "work")
    dir.create(cfg$paths$in_root)
    dir.create(cfg$paths$out_root)
    dir.create(cfg$paths$work_root)

    cfg$apptainer$bin <- "echo"
    cfg$apptainer$use_sif <- TRUE
    cfg$profiles <- list(
      ants = list(
        docker_image = "ghcr.io/example/ants:1.0@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        apptainer_uri = "docker://ghcr.io/example/ants:1.0@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        sif_name = "ants.sif"
      )
    )

    lock <- ni_pin(cfg = cfg, path = cfg$runtime$lockfile, pull = FALSE, include_specs = FALSE)
    expect_equal(lock$profiles$ants$apptainer$resolved_ref, lock$profiles$ants$apptainer$sif_path)
  })
})

# Tests for internal functions

test_that("ni_ref_digest extracts sha256 digest from ref string", {
  # Valid digest
  result <- niflowr:::ni_ref_digest("img@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
  expect_equal(result, "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")

  # Tag without digest
  result <- niflowr:::ni_ref_digest("img:latest")
  expect_null(result)

  # NULL input
  result <- niflowr:::ni_ref_digest(NULL)
  expect_null(result)

  # Empty string
  result <- niflowr:::ni_ref_digest("")
  expect_null(result)
})

test_that("ni_sha256_file returns sha256 of a file", {
  withr::with_tempdir({
    test_file <- file.path(getwd(), "test.txt")
    writeLines("test content", test_file)

    result <- niflowr:::ni_sha256_file(test_file)
    expect_type(result, "character")
    expect_equal(nchar(result), 64)

    # Verify it's consistent
    result2 <- niflowr:::ni_sha256_file(test_file)
    expect_equal(result, result2)
  })
})

test_that("ni_lock_checks_df creates data.frame from list", {
  # Empty list
  result <- niflowr:::ni_lock_checks_df(list())
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 0)
  expect_equal(names(result), c("profile", "check", "status", "message"))

  # List of data.frames
  checks <- list(
    data.frame(profile = "fsl", check = "test1", status = "pass", message = "ok", stringsAsFactors = FALSE),
    data.frame(profile = "fsl", check = "test2", status = "fail", message = "error", stringsAsFactors = FALSE)
  )
  result <- niflowr:::ni_lock_checks_df(checks)
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 2)
  expect_equal(result$profile, c("fsl", "fsl"))
  expect_equal(result$status, c("pass", "fail"))
})

test_that("ni_lock_read reads lockfile", {
  withr::with_tempdir({
    lock_path <- file.path(getwd(), "test.lock.yml")

    # Missing file
    expect_error(niflowr:::ni_lock_read(lock_path), "not found")

    # Valid YAML file
    lock_data <- list(
      lock_version = "0.1",
      profiles = list(
        fsl = list(docker = list(configured_ref = "test:latest"))
      )
    )
    yaml::write_yaml(lock_data, lock_path)

    result <- niflowr:::ni_lock_read(lock_path)
    expect_type(result, "list")
    expect_equal(result$lock_version, "0.1")
    expect_true("fsl" %in% names(result$profiles))
  })
})

test_that("ni_lock_write writes lockfile", {
  withr::with_tempdir({
    lock_path <- file.path(getwd(), "output.lock.yml")

    lock_data <- list(
      lock_version = "0.1",
      profiles = list(
        test = list(docker = list(configured_ref = "img:tag"))
      )
    )

    niflowr:::ni_lock_write(lock_data, lock_path)
    expect_true(file.exists(lock_path))

    # Read it back
    result <- niflowr:::ni_lock_read(lock_path)
    expect_equal(result$lock_version, "0.1")
    expect_equal(result$profiles$test$docker$configured_ref, "img:tag")
  })
})

test_that("ni_lock_validate with missing lockfile returns fail status", {
  withr::with_tempdir({
    cfg <- ni_config_defaults()
    cfg$runtime$lockfile <- file.path(getwd(), "missing.lock.yml")
    cfg$profiles <- list(fsl = list(docker_image = "test:latest"))

    result <- ni_lock_validate(path = cfg$runtime$lockfile, cfg = cfg, strict = FALSE)
    expect_s3_class(result, "data.frame")
    expect_true(any(result$status == "fail"))
    expect_true(any(result$check == "lockfile_exists"))
  })
})

test_that("ni_lock_validate with matching config returns all pass", {
  withr::with_tempdir({
    cfg <- ni_config_defaults()
    cfg$runtime$lockfile <- file.path(getwd(), "test.lock.yml")
    cfg$profiles <- list(
      fsl = list(
        docker_image = "ghcr.io/example/fsl:1.0@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
      )
    )

    ni_pin(cfg = cfg, path = cfg$runtime$lockfile, pull = FALSE, include_specs = FALSE)

    result <- ni_lock_validate(path = cfg$runtime$lockfile, cfg = cfg, strict = FALSE)
    expect_true(all(result$status == "pass"))
  })
})

test_that("ni_lock_abort_if_failed works correctly", {
  # All pass - no error
  df_pass <- data.frame(
    profile = "fsl",
    check = "test",
    status = "pass",
    message = "ok",
    stringsAsFactors = FALSE
  )
  expect_silent(niflowr:::ni_lock_abort_if_failed(df_pass, "test.lock"))

  # With failures - error
  df_fail <- data.frame(
    profile = "fsl",
    check = "test",
    status = "fail",
    message = "error",
    stringsAsFactors = FALSE
  )
  expect_error(niflowr:::ni_lock_abort_if_failed(df_fail, "test.lock"), "Lock validation failed")
})

# Tests for ni_collect_spec_index
test_that("ni_collect_spec_index collects spec metadata", {
  skip_if_not(dir.exists(system.file("specs", package = "niflowr")),
              "Specs directory not available")

  result <- niflowr:::ni_collect_spec_index()

  expect_type(result, "list")
  expect_true(length(result) > 0)

  # Check structure of first entry
  if (length(result) > 0) {
    first <- result[[1]]
    expect_type(first, "list")
    expect_true("spec_version" %in% names(first))
    expect_true("profile" %in% names(first))
  }
})

# Tests for ni_lock_profile_entry
test_that("ni_lock_profile_entry reads profile from lockfile", {
  withr::with_tempdir({
    cfg <- ni_config_defaults()
    cfg$runtime$lockfile <- file.path(getwd(), "test.lock.yml")
    cfg$profiles <- list(
      fsl = list(
        docker_image = "ghcr.io/example/fsl:1.0@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
      )
    )

    ni_pin(cfg = cfg, path = cfg$runtime$lockfile, pull = FALSE, include_specs = FALSE)

    result <- niflowr:::ni_lock_profile_entry(cfg, "fsl")
    expect_type(result, "list")
    expect_true("docker" %in% names(result))
  })
})

test_that("ni_lock_profile_entry errors when lockfile missing", {
  cfg <- ni_config_defaults()
  cfg$runtime$lockfile <- tempfile(fileext = ".lock.yml")

  expect_error(
    niflowr:::ni_lock_profile_entry(cfg, "fsl"),
    "lockfile is missing"
  )
})

test_that("ni_lock_profile_entry errors when profile not in lockfile", {
  withr::with_tempdir({
    cfg <- ni_config_defaults()
    cfg$runtime$lockfile <- file.path(getwd(), "test.lock.yml")
    cfg$profiles <- list(
      fsl = list(docker_image = "test:latest")
    )

    ni_pin(cfg = cfg, path = cfg$runtime$lockfile, pull = FALSE, include_specs = FALSE)

    expect_error(
      niflowr:::ni_lock_profile_entry(cfg, "unknown"),
      "not present in lockfile"
    )
  })
})

# Tests for ni_lock_enforce_profile apptainer branch
test_that("ni_lock_enforce_profile enforces apptainer SIF path", {
  withr::with_tempdir({
    cfg <- ni_config_defaults()
    cfg$runtime$lockfile <- file.path(getwd(), "test.lock.yml")
    cfg$runtime$lock_enforce <- TRUE
    cfg$apptainer$use_sif <- TRUE
    cfg$paths$in_root <- file.path(getwd(), "in")
    cfg$paths$out_root <- file.path(getwd(), "out")
    cfg$paths$work_root <- file.path(getwd(), "work")
    dir.create(cfg$paths$in_root)
    dir.create(cfg$paths$out_root)
    dir.create(cfg$paths$work_root)

    cfg$profiles <- list(
      ants = list(
        docker_image = "ghcr.io/example/ants:1.0@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        apptainer_uri = "docker://ghcr.io/example/ants:1.0@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        sif_name = "ants.sif"
      )
    )

    ni_pin(cfg = cfg, path = cfg$runtime$lockfile, pull = FALSE, include_specs = FALSE)

    # Wrong URI should fail
    expect_error(
      niflowr:::ni_lock_enforce_profile(
        cfg = cfg,
        engine = "apptainer",
        profile = "ants",
        container_ref = "docker://wrong:uri"
      ),
      "Lock enforcement failed"
    )
  })
})

test_that("ni_lock_enforce_profile checks SIF existence", {
  withr::with_tempdir({
    cfg <- ni_config_defaults()
    cfg$runtime$lockfile <- file.path(getwd(), "test.lock.yml")
    cfg$runtime$lock_enforce <- TRUE

    # Create lockfile with SIF path that doesn't exist
    lock_data <- list(
      lock_version = "0.1",
      profiles = list(
        ants = list(
          apptainer = list(
            configured_uri = "docker://test",
            sif_path = file.path(getwd(), "missing.sif")
          )
        )
      )
    )
    yaml::write_yaml(lock_data, cfg$runtime$lockfile)

    cfg$profiles <- list(
      ants = list(apptainer_uri = "docker://test")
    )

    expect_error(
      niflowr:::ni_lock_enforce_profile(
        cfg = cfg,
        engine = "apptainer",
        profile = "ants",
        container_ref = "docker://test"
      ),
      "does not exist"
    )
  })
})

test_that("ni_lock_enforce_profile checks SIF checksum", {
  withr::with_tempdir({
    cfg <- ni_config_defaults()
    cfg$runtime$lockfile <- file.path(getwd(), "test.lock.yml")
    cfg$runtime$lock_enforce <- TRUE

    # Create a test SIF file
    sif_path <- file.path(getwd(), "test.sif")
    writeLines("test content", sif_path)
    correct_sha <- niflowr:::ni_sha256_file(sif_path)
    wrong_sha <- "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

    # Create lockfile with wrong checksum
    lock_data <- list(
      lock_version = "0.1",
      profiles = list(
        ants = list(
          apptainer = list(
            configured_uri = "docker://test",
            sif_path = sif_path,
            sif_sha256 = wrong_sha
          )
        )
      )
    )
    yaml::write_yaml(lock_data, cfg$runtime$lockfile)

    cfg$profiles <- list(
      ants = list(apptainer_uri = "docker://test")
    )

    expect_error(
      niflowr:::ni_lock_enforce_profile(
        cfg = cfg,
        engine = "apptainer",
        profile = "ants",
        container_ref = "docker://test"
      ),
      "checksum mismatch"
    )
  })
})

# Tests for ni_pin edge cases
test_that("ni_pin errors on empty profiles", {
  cfg <- ni_config_defaults()
  cfg$profiles <- list()

  expect_error(
    ni_pin(cfg = cfg, pull = FALSE, include_specs = FALSE),
    "No profiles configured"
  )
})

test_that("ni_pin errors on unknown profile", {
  cfg <- ni_config_defaults()
  cfg$profiles <- list(fsl = list(docker_image = "test:latest"))

  expect_error(
    ni_pin(cfg = cfg, profiles = "unknown", pull = FALSE, include_specs = FALSE),
    "Unknown profile"
  )
})

test_that("ni_pin includes specs when include_specs=TRUE", {
  skip_if_not(dir.exists(system.file("specs", package = "niflowr")),
              "Specs directory not available")

  withr::with_tempdir({
    cfg <- ni_config_defaults()
    cfg$runtime$lockfile <- file.path(getwd(), "test.lock.yml")
    cfg$profiles <- list(
      fsl = list(docker_image = "test:latest")
    )

    lock <- ni_pin(cfg = cfg, path = cfg$runtime$lockfile, pull = FALSE, include_specs = TRUE)

    expect_true("specs" %in% names(lock))
    expect_type(lock$specs, "list")
  })
})

# Tests for ni_lock_validate SIF checks
test_that("ni_lock_validate checks SIF existence", {
  withr::with_tempdir({
    cfg <- ni_config_defaults()
    cfg$runtime$lockfile <- file.path(getwd(), "test.lock.yml")

    # Create a test SIF file
    sif_path <- file.path(getwd(), "test.sif")
    writeLines("test content", sif_path)

    lock_data <- list(
      lock_version = "0.1",
      profiles = list(
        ants = list(
          apptainer = list(
            configured_uri = "docker://test",
            sif_path = sif_path
          )
        )
      )
    )
    yaml::write_yaml(lock_data, cfg$runtime$lockfile)

    cfg$profiles <- list(
      ants = list(apptainer_uri = "docker://test")
    )

    result <- ni_lock_validate(path = cfg$runtime$lockfile, cfg = cfg, check_sif = TRUE)
    expect_true(any(result$check == "sif_exists"))
    expect_true(any(result$status[result$check == "sif_exists"] == "pass"))
  })
})

test_that("ni_lock_validate checks SIF checksum", {
  withr::with_tempdir({
    cfg <- ni_config_defaults()
    cfg$runtime$lockfile <- file.path(getwd(), "test.lock.yml")

    # Create a test SIF file
    sif_path <- file.path(getwd(), "test.sif")
    writeLines("test content", sif_path)
    correct_sha <- niflowr:::ni_sha256_file(sif_path)

    lock_data <- list(
      lock_version = "0.1",
      profiles = list(
        ants = list(
          apptainer = list(
            configured_uri = "docker://test",
            sif_path = sif_path,
            sif_sha256 = correct_sha
          )
        )
      )
    )
    yaml::write_yaml(lock_data, cfg$runtime$lockfile)

    cfg$profiles <- list(
      ants = list(apptainer_uri = "docker://test")
    )

    result <- ni_lock_validate(path = cfg$runtime$lockfile, cfg = cfg, check_sif = TRUE)
    expect_true(any(result$check == "sif_sha256"))
    expect_true(any(result$status[result$check == "sif_sha256"] == "pass"))
  })
})

test_that("ni_lock_validate reports SIF checksum mismatch", {
  withr::with_tempdir({
    cfg <- ni_config_defaults()
    cfg$runtime$lockfile <- file.path(getwd(), "test.lock.yml")

    # Create a test SIF file
    sif_path <- file.path(getwd(), "test.sif")
    writeLines("test content", sif_path)
    wrong_sha <- "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

    lock_data <- list(
      lock_version = "0.1",
      profiles = list(
        ants = list(
          apptainer = list(
            configured_uri = "docker://test",
            sif_path = sif_path,
            sif_sha256 = wrong_sha
          )
        )
      )
    )
    yaml::write_yaml(lock_data, cfg$runtime$lockfile)

    cfg$profiles <- list(
      ants = list(apptainer_uri = "docker://test")
    )

    result <- ni_lock_validate(path = cfg$runtime$lockfile, cfg = cfg, check_sif = TRUE)
    expect_true(any(result$check == "sif_sha256"))
    expect_true(any(result$status[result$check == "sif_sha256"] == "fail"))
  })
})

# Tests for ni_lock_read yaml requirement
test_that("ni_lock_read errors when yaml package missing", {
  skip_if(requireNamespace("yaml", quietly = TRUE), "yaml package is available")

  # This test only runs if yaml is not available
  expect_error(
    niflowr:::ni_lock_read(tempfile()),
    "yaml"
  )
})

test_that("ni_lock_read returns empty list for null yaml content", {
  withr::with_tempdir({
    # Create an empty YAML file (which yaml::read_yaml returns as NULL)
    empty_file <- file.path(getwd(), "empty.lock.yml")
    writeLines("", empty_file)

    result <- niflowr:::ni_lock_read(empty_file)
    expect_type(result, "list")
    expect_equal(length(result), 0)
  })
})

# Tests for ni_lock_write yaml requirement
test_that("ni_lock_write errors when yaml package missing", {
  skip_if(requireNamespace("yaml", quietly = TRUE), "yaml package is available")

  # This test only runs if yaml is not available
  lock_data <- list(lock_version = "0.1")
  expect_error(
    niflowr:::ni_lock_write(lock_data, tempfile()),
    "yaml"
  )
})

# Test for ni_lock_validate strict mode with missing lockfile
test_that("ni_lock_validate strict mode errors on missing lockfile", {
  cfg <- ni_config_defaults()
  cfg$runtime$lockfile <- tempfile(fileext = ".lock.yml")
  cfg$profiles <- list(fsl = list(docker_image = "test:latest"))

  expect_error(
    ni_lock_validate(path = cfg$runtime$lockfile, cfg = cfg, strict = TRUE),
    "Lock validation failed"
  )
})
