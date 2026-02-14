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

    report <- ni_doctor(cfg = cfg, strict = FALSE, check_lock = FALSE)
    expect_true(is.data.frame(report))
    expect_true(all(c("check", "status", "message") %in% names(report)))
    expect_false(any(report$status == "fail"))
  })
})

test_that("ni_doctor strict errors when required checks fail", {
  cfg <- ni_config_defaults()
  cfg$profiles <- list()

  expect_error(
    ni_doctor(cfg = cfg, strict = TRUE, check_lock = FALSE),
    "ni_doctor found failing checks"
  )
})
