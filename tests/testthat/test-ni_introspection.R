test_that("ni_inputs returns data.frame of spec inputs", {
  spec <- ni_spec_read("fsl.bet")
  result <- ni_inputs(spec)

  expect_s3_class(result, "data.frame")
  expect_true(all(c("name", "type", "required", "default", "description", "choices", "constraints") %in% names(result)))
  expect_true(nrow(result) > 0)
})

test_that("ni_inputs works with spec_id string", {
  result <- ni_inputs("fsl.bet")

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

test_that("ni_constraints returns data.frame of constraints", {
  # Find a spec with constraints - fsl.bet should have some
  result <- ni_constraints("fsl.bet")

  expect_s3_class(result, "data.frame")
  expect_true(all(c("input", "constraint", "value") %in% names(result)))
})

test_that("ni_constraints returns empty data.frame with right columns when no constraints", {
  # Create a minimal spec with no constraints
  spec <- structure(list(
    id = "test.tool",
    command = "testcmd",
    inputs = list(
      simple_input = list(type = "string")
    )
  ), class = "ni_spec")

  result <- ni_constraints(spec)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 0)
  expect_equal(names(result), c("input", "constraint", "value"))
})

test_that("ni_constraints includes validate entries", {
  # Create a spec with validate block
  spec <- structure(list(
    id = "test.tool",
    command = "testcmd",
    inputs = list(
      validated_input = list(
        type = "string",
        validate = list(
          pattern = "^[a-z]+$"
        )
      )
    )
  ), class = "ni_spec")

  result <- ni_constraints(spec)

  expect_true(any(grepl("^validate\\.", result$constraint)))
})

test_that("format_default_value handles various inputs", {
  # NULL
  expect_equal(niflowr:::format_default_value(NULL), NA_character_)

  # length-0
  expect_equal(niflowr:::format_default_value(character(0)), NA_character_)

  # scalar
  expect_equal(niflowr:::format_default_value("foo"), "foo")

  # vector
  expect_equal(niflowr:::format_default_value(c("a", "b")), "a, b")
})

test_that("format_constraints handles NULL inputs", {
  result <- niflowr:::format_constraints(NULL, NULL)
  expect_equal(result, NA_character_)
})

test_that("format_constraints formats constraints list", {
  constraints <- list(min = 0, max = 100)

  result <- niflowr:::format_constraints(constraints, NULL)

  expect_type(result, "character")
  expect_true(grepl("min=", result))
  expect_true(grepl("max=", result))
})

test_that("format_constraints includes validate entries", {
  validate <- list(pattern = "^[a-z]+$")

  result <- niflowr:::format_constraints(NULL, validate)

  expect_type(result, "character")
  expect_true(grepl("validate\\.pattern=", result))
})

test_that("format_constraint_value handles various inputs", {
  # NULL
  expect_equal(niflowr:::format_constraint_value(NULL), "NULL")

  # length-0
  expect_equal(niflowr:::format_constraint_value(character(0)), "")

  # vector
  expect_equal(niflowr:::format_constraint_value(c("a", "b")), "a, b")
})

test_that("as_tidy_table returns tibble if available, else df", {
  df <- data.frame(a = 1:3, b = c("x", "y", "z"))

  result <- niflowr:::as_tidy_table(df)

  expect_s3_class(result, "data.frame")

  # If tibble is available, should be a tibble
  if (requireNamespace("tibble", quietly = TRUE)) {
    expect_s3_class(result, "tbl_df")
  }
})
