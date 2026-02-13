test_that("collect_bind_dirs extracts input file directories", {
  call <- structure(list(
    values = list(
      in_file = "/data/input/t1.nii.gz",
      ref_file = "/data/ref/mni.nii.gz"
    ),
    spec = structure(list(
      inputs = list(
        in_file = list(type = "file"),
        ref_file = list(type = "file")
      )
    ), class = "ni_spec"),
    outputs = list()
  ), class = "ni_call")

  dirs <- niflowr:::collect_bind_dirs(call)
  # Only existing directories will be returned
  expect_type(dirs, "character")
})

test_that("collect_bind_dirs creates output directories", {
  withr::with_tempdir({
    out_path <- file.path(getwd(), "new_subdir", "output.nii.gz")
    call <- structure(list(
      values = list(),
      spec = structure(list(
        inputs = list()
      ), class = "ni_spec"),
      outputs = list(out_file = out_path)
    ), class = "ni_call")

    dirs <- niflowr:::collect_bind_dirs(call)
    # The new_subdir should have been created
    expect_true(dir.exists(file.path(getwd(), "new_subdir")))
  })
})

test_that("wrap_container errors on missing image", {
  built <- list(command = "bet", args = c("in.nii", "out.nii"))
  container <- list(type = "docker", image = "")
  call <- structure(list(
    values = list(),
    spec = structure(list(inputs = list()), class = "ni_spec"),
    outputs = list()
  ), class = "ni_call")

  expect_error(
    niflowr:::wrap_container(built, container, call),
    "image must be specified"
  )
})

test_that("wrap_container builds docker command", {
  withr::with_tempdir({
    in_dir <- file.path(getwd(), "input")
    dir.create(in_dir)
    in_file <- file.path(in_dir, "t1.nii.gz")
    file.create(in_file)

    built <- list(command = "bet", args = c(in_file, "/tmp/out.nii.gz"),
                  stdout = NULL, stderr = NULL)
    container <- list(type = "docker", image = "fsl:6.0")
    call <- structure(list(
      values = list(in_file = in_file),
      spec = structure(list(
        inputs = list(in_file = list(type = "file"))
      ), class = "ni_spec"),
      outputs = list()
    ), class = "ni_call")

    result <- niflowr:::wrap_container(built, container, call)
    expect_equal(result$command, "docker")
    expect_true("run" %in% result$args)
    expect_true("--rm" %in% result$args)
    expect_true("fsl:6.0" %in% result$args)
  })
})

test_that("wrap_container builds apptainer command", {
  withr::with_tempdir({
    in_dir <- file.path(getwd(), "input")
    dir.create(in_dir)
    in_file <- file.path(in_dir, "t1.nii.gz")
    file.create(in_file)

    built <- list(command = "bet", args = c(in_file, "/tmp/out.nii.gz"),
                  stdout = NULL, stderr = NULL)
    container <- list(type = "apptainer", image = "fsl.sif")
    call <- structure(list(
      values = list(in_file = in_file),
      spec = structure(list(
        inputs = list(in_file = list(type = "file"))
      ), class = "ni_spec"),
      outputs = list()
    ), class = "ni_call")

    result <- niflowr:::wrap_container(built, container, call)
    expect_equal(result$command, "apptainer")
    expect_true("exec" %in% result$args)
    expect_true("fsl.sif" %in% result$args)
  })
})

test_that("wrap_container errors on unknown type", {
  built <- list(command = "bet", args = character())
  container <- list(type = "podman", image = "img")
  call <- structure(list(
    values = list(),
    spec = structure(list(inputs = list()), class = "ni_spec"),
    outputs = list()
  ), class = "ni_call")

  expect_error(
    niflowr:::wrap_container(built, container, call),
    "Unknown container type"
  )
})
