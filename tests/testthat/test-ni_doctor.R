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
        docker_image = "ghcr.io/example/fsl:1.0@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        entrypoint = "",
        platform = "linux/amd64"
      )
    )

    report <- ni_doctor(cfg = cfg, strict = FALSE, check_lock = FALSE)
    expect_true(is.data.frame(report))
    expect_true(all(c("check", "status", "message") %in% names(report)))
    expect_false(any(report$status == "fail"))
    expect_true("profile.fsl.entrypoint" %in% report$check)
    expect_true("profile.fsl.platform" %in% report$check)
    # Stub docker.bin=echo cannot satisfy real inspect JSON; probe is skipped.
    expect_true("profile.fsl.payload" %in% report$check)
    payload <- report[report$check == "profile.fsl.payload", , drop = FALSE]
    expect_equal(payload$status, "warn")
  })
})

test_that("ni_doctor strict errors when required checks fail", {
  cfg <- ni_config_defaults()
  cfg$profiles <- list()

  expect_error(
    ni_doctor(cfg = cfg, strict = TRUE, check_lock = FALSE, check_payload = FALSE),
    "ni_doctor found failing checks"
  )
})

test_that("ni_doctor flags invalid entrypoint/platform fields", {
  cfg <- ni_config_defaults()
  cfg$docker$bin <- "echo"
  cfg$apptainer$bin <- "echo"
  cfg$paths$in_root <- tempdir()
  cfg$profiles <- list(
    bad = list(
      docker_image = "example/img:1",
      entrypoint = 1L,
      platform = ""
    )
  )

  report <- ni_doctor(cfg = cfg, strict = FALSE, check_lock = FALSE, check_payload = FALSE)
  expect_true(any(report$check == "profile.bad.entrypoint" & report$status == "fail"))
  expect_true(any(report$check == "profile.bad.platform" & report$status == "fail"))
})

test_that("ni_doctor_probe_docker_payload detects swallowed commands", {
  skip_if_not_installed("processx")

  cfg <- ni_config_defaults()
  cfg$docker$bin <- "echo"
  profile <- list(docker_image = "example/img:1")

  # With stub docker, inspect is not JSON → warn skip
  skipped <- niflowr:::ni_doctor_probe_docker_payload(cfg, "fsl", profile)
  expect_equal(skipped$status, "warn")

  # Simulate inspect + run where exit 0 but marker missing (entrypoint swallow)
  fake_bin <- tempfile("fake-docker")
  writeLines(
    c(
      "#!/bin/sh",
      "if [ \"$1\" = \"image\" ] && [ \"$2\" = \"inspect\" ]; then",
      "  printf '[{\"Id\":\"sha256:deadbeef\"}]\\n'",
      "  exit 0",
      "fi",
      "# docker run ... : pretend success without echoing payload marker",
      "exit 0"
    ),
    fake_bin
  )
  Sys.chmod(fake_bin, "0755")
  cfg$docker$bin <- fake_bin

  swallowed <- niflowr:::ni_doctor_probe_docker_payload(cfg, "fsl", profile)
  expect_equal(swallowed$status, "fail")
  expect_match(swallowed$message, "ENTRYPOINT|entrypoint|payload marker", ignore.case = TRUE)

  # Simulate successful payload execution
  fake_ok <- tempfile("fake-docker-ok")
  writeLines(
    c(
      "#!/bin/sh",
      "if [ \"$1\" = \"image\" ] && [ \"$2\" = \"inspect\" ]; then",
      "  printf '[{\"Id\":\"sha256:deadbeef\"}]\\n'",
      "  exit 0",
      "fi",
      "for a in \"$@\"; do",
      "  if [ \"$a\" = \"NIFLOWR_PROBE_OK\" ]; then",
      "    printf '%s\\n' \"$a\"",
      "  fi",
      "done",
      "exit 0"
    ),
    fake_ok
  )
  Sys.chmod(fake_ok, "0755")
  cfg$docker$bin <- fake_ok

  ok <- niflowr:::ni_doctor_probe_docker_payload(cfg, "fsl", profile)
  expect_equal(ok$status, "pass")
})
