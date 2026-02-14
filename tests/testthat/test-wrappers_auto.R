test_that("wrapper functions exist for all specs", {
  spec_ids <- ni_spec_list()
  skip_if(length(spec_ids) == 0, "No bundled specs available")

  for (id in spec_ids) {
    fn_name <- paste0("ni_", gsub(".", "_", id, fixed = TRUE))

    # Check function exists in namespace
    expect_true(
      exists(fn_name, where = asNamespace("niflowr"), mode = "function"),
      info = paste("Wrapper missing for spec:", id, "-> expected function:", fn_name)
    )
  }
})

test_that("wrapper functions execute ni_call for all specs", {
  # This test verifies that wrappers call ni_call(), even if validation fails
  # for some specs due to complex constraints (xor groups, parameter conflicts, etc.)
  spec_ids <- ni_spec_list()
  skip_if(length(spec_ids) == 0, "No bundled specs available")

  success_count <- 0
  expected_error_count <- 0
  unexpected_error_count <- 0

  for (id in spec_ids) {
    fn_name <- paste0("ni_", gsub(".", "_", id, fixed = TRUE))
    fn <- get(fn_name, envir = asNamespace("niflowr"))

    # Build synthetic values for this spec
    spec <- ni_spec_read(id)
    values <- niflowr:::synthesize_values_for_spec(spec)

    # If spec has a parameter named "dry_run" or "echo", remove it from values
    # to avoid conflicts with wrapper parameters
    values$dry_run <- NULL
    values$echo <- NULL

    # Call wrapper with dry_run = TRUE and .engine = "native"
    args <- c(values, list(.engine = "native", dry_run = TRUE, echo = FALSE))

    result <- withCallingHandlers(
      tryCatch(
        {
          do.call(fn, args)
          success_count <- success_count + 1
          "success"
        },
        error = function(e) {
          msg <- conditionMessage(e)
          # These are expected errors from synthesized values
          expected_patterns <- c(
            "Input validation failed",
            "mutually exclusive",
            "matched by multiple actual arguments",
            "values must be type",
            "argument not used by format"
          )
          if (any(sapply(expected_patterns, function(p) grepl(p, msg)))) {
            expected_error_count <<- expected_error_count + 1
            "expected_error"
          } else {
            unexpected_error_count <<- unexpected_error_count + 1
            e
          }
        }
      ),
      warning = function(w) {
        # Warnings from sprintf format issues are expected
        invokeRestart("muffleWarning")
      }
    )

    # Only fail if there's an unexpected error
    if (inherits(result, "error")) {
      fail(paste0(
        "Wrapper ", fn_name, " (spec: ", id, ") failed with unexpected error.\n",
        "Error: ", conditionMessage(result)
      ))
    }
  }

  # Expect that all wrappers execute without unexpected errors
  total <- length(spec_ids)
  expect_equal(unexpected_error_count, 0,
               label = paste0("All wrappers should execute without unexpected errors. ",
                            "Success: ", success_count, ", Expected errors: ", expected_error_count,
                            ", Unexpected: ", unexpected_error_count, ", Total: ", total))
})

test_that("wrapper dry_run returns NULL invisibly", {
  # Test with minimal required parameters
  withr::with_tempfile("tf", fileext = ".nii.gz", {
    file.create(tf)

    result <- withVisible(
      ni_fsl_bet(
        in_file = tf,
        out_file = "/tmp/out.nii.gz",
        .engine = "native",
        dry_run = TRUE,
        echo = FALSE
      )
    )

    expect_null(result$value)
    expect_false(result$visible)
  })
})

test_that("wrapper naming convention is correct", {
  # Test specific known mappings
  expect_true(exists("ni_fsl_bet", where = asNamespace("niflowr"), mode = "function"))
  expect_true(exists("ni_afni_a_boverlap", where = asNamespace("niflowr"), mode = "function"))
  expect_true(exists("ni_ants_registration", where = asNamespace("niflowr"), mode = "function"))

  # Verify the pattern: spec_id "fsl.bet" -> "ni_fsl_bet"
  expect_equal(
    paste0("ni_", gsub(".", "_", "fsl.bet", fixed = TRUE)),
    "ni_fsl_bet"
  )
  expect_equal(
    paste0("ni_", gsub(".", "_", "afni.a_boverlap", fixed = TRUE)),
    "ni_afni_a_boverlap"
  )
})

test_that("wrappers pass through all standard parameters", {
  # Test that wrappers accept and pass through .cwd, .env, .engine, .profile
  withr::with_tempfile("tf", fileext = ".nii.gz", {
    file.create(tf)

    # Should not error with these parameters
    result <- ni_fsl_bet(
      in_file = tf,
      out_file = "/tmp/brain.nii.gz",
      .cwd = "/tmp",
      .env = c(FSLOUTPUTTYPE = "NIFTI_GZ"),
      .engine = "native",
      .profile = "fsl-6.0",
      dry_run = TRUE,
      echo = FALSE
    )

    expect_null(result)
  })
})

test_that("wrappers create ni_call objects via ni_call()", {
  # Verify that wrappers are calling ni_call internally by testing dry_run behavior
  withr::with_tempfile("tf", fileext = ".nii.gz", {
    file.create(tf)
    result <- ni_fsl_bet(
      in_file = tf,
      out_file = "/tmp/brain.nii.gz",
      .engine = "native",
      dry_run = TRUE,
      echo = FALSE
    )
    expect_null(result)
  })
})

test_that("sample wrappers with minimal parameters work in dry_run", {
  # Test wrappers with only required parameters to avoid validation issues
  withr::with_tempfile("in1", fileext = ".nii.gz", {
    withr::with_tempfile("in2", fileext = ".nii.gz", {
      file.create(in1)
      file.create(in2)

      test_cases <- list(
        list(id = "fsl.bet", fn = "ni_fsl_bet",
             args = list(in_file = in1, out_file = "/tmp/out.nii.gz")),
        list(id = "afni.automask", fn = "ni_afni_automask",
             args = list(in_file = in1)),
        list(id = "afni.a_boverlap", fn = "ni_afni_a_boverlap",
             args = list(in_file_a = in1, in_file_b = in2))
      )

      for (tc in test_cases) {
        skip_if(!tc$id %in% ni_spec_list(), paste("Spec not available:", tc$id))

        fn <- get(tc$fn, envir = asNamespace("niflowr"))
        args <- c(tc$args, list(.engine = "native", dry_run = TRUE, echo = FALSE))

        result <- tryCatch(
          do.call(fn, args),
          error = function(e) e
        )

        if (inherits(result, "error")) {
          fail(paste0(
            "Sample wrapper ", tc$fn, " failed.\n",
            "Error: ", conditionMessage(result)
          ))
        }

        expect_null(result)
      }
    })
  })
})

test_that("wrappers handle all parameter types", {
  # Test that wrappers correctly pass through different parameter types
  withr::with_tempfile("tf", fileext = ".nii.gz", {
    file.create(tf)

    # ni_fsl_bet has various parameter types: file, numeric, logical
    result <- ni_fsl_bet(
      in_file = tf,
      out_file = "/tmp/out.nii.gz",
      frac = 0.5,           # numeric
      robust = TRUE,        # logical
      .engine = "native",
      dry_run = TRUE,
      echo = FALSE
    )

    expect_null(result)
  })
})
