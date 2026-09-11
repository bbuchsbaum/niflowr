test_that("ni_doctor returns checks for a minimally valid config", {
  withr::with_tempdir({
    cfg <- ni_config_defaults()
    cfg$docker$bin <- "echo"
    cfg$apptainer$bin <- "echo"
    cfg$paths$in_root <- file.path(getwd(), "in")
    cfg$paths$out_root <- file.path(getwd(), "out")
    cfg$paths$work_root <- file.path(getwd(), "work")
    dir.create(cfg$paths$in_root)
    dir.create(cfg$paths$out_root)
    dir.create(cfg$paths$work_root)
    cfg$profiles <- list(
      fsl = list(
        docker_image = "ghcr.io/example/fsl:1.0@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
      )
    )

    report <- ni_doctor(cfg = cfg, strict = FALSE, check_lock = FALSE, probe_profiles = FALSE)
    expect_true(is.data.frame(report))
    expect_true(all(c("check", "status", "message") %in% names(report)))
    expect_false(any(report$status == "fail"))
  })
})

test_that("ni_doctor strict errors when required checks fail", {
  cfg <- ni_config_defaults()
  cfg$profiles <- list()

  expect_error(
    ni_doctor(cfg = cfg, strict = TRUE, check_lock = FALSE, probe_profiles = FALSE),
    "ni_doctor found failing checks"
  )
})

test_that("ni_doctor validates profile platform/entrypoint shape", {
  withr::with_tempdir({
    cfg <- ni_config_defaults()
    cfg$docker$bin <- "echo"
    cfg$apptainer$bin <- "echo"
    cfg$paths$in_root <- file.path(getwd(), "in")
    cfg$paths$out_root <- file.path(getwd(), "out")
    cfg$paths$work_root <- file.path(getwd(), "work")
    dir.create(cfg$paths$in_root)
    dir.create(cfg$paths$out_root)
    dir.create(cfg$paths$work_root)
    cfg$profiles <- list(
      fsl = list(
        docker_image = "example/fsl:1.0",
        platform = "linux/amd64",
        entrypoint = ""
      )
    )

    report <- ni_doctor(cfg = cfg, strict = FALSE, check_lock = FALSE, probe_profiles = FALSE)
    expect_true(any(report$check == "profile.fsl.platform" & report$status == "pass"))
    expect_true(any(report$check == "profile.fsl.entrypoint" & report$status == "pass"))
  })
})

test_that("ni_doctor probe warns when docker image is not local", {
  skip_on_cran()
  skip_if_not_installed("processx")
  skip_if(is.null(niflowr:::ni_which_or_null("docker")), "docker not available")

  withr::with_tempdir({
    cfg <- ni_config_defaults()
    cfg$paths$in_root <- file.path(getwd(), "in")
    cfg$paths$out_root <- file.path(getwd(), "out")
    cfg$paths$work_root <- file.path(getwd(), "work")
    dir.create(cfg$paths$in_root)
    dir.create(cfg$paths$out_root)
    dir.create(cfg$paths$work_root)
    cfg$profiles <- list(
      fsl = list(
        docker_image = "niflowr.invalid/does-not-exist:never"
      )
    )

    report <- ni_doctor(cfg = cfg, strict = FALSE, check_lock = FALSE, probe_profiles = TRUE)
    probe <- report[report$check == "profile.fsl.probe", , drop = FALSE]
    expect_equal(nrow(probe), 1L)
    expect_equal(probe$status[[1]], "warn")
    expect_match(probe$message[[1]], "not local")
  })
})
