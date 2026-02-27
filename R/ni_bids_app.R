#' Create a bidsappr-based BIDS App pre-configured with niflowr
#'
#' Scaffolds a BIDS App using `bidsappr::new_app()` and creates a template
#' `app.R` with niflowr integration. The generated app includes example usage
#' of niflowr functions and can be customized with tool-specific examples.
#'
#' @param path Directory path where the app will be created.
#' @param app_name Name of the BIDS App. Default: basename of `path`.
#' @param tools Optional character vector of spec IDs (e.g., `c("fsl.bet", "ants.registration")`)
#'   to include as commented-out examples in the generated app.
#' @return Invisibly returns the path to the created app directory.
#' @export
#' @examples
#' \dontrun{
#' # Create a basic BIDS App
#' ni_bids_app("~/my_bids_app", app_name = "MyApp")
#'
#' # Create an app with tool examples
#' ni_bids_app("~/my_bids_app", tools = c("fsl.bet", "ants.registration"))
#' }
ni_bids_app <- function(path, app_name = basename(path), tools = NULL) {
  if (!requireNamespace("bidsappr", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg bidsappr} is required. Install from: https://github.com/bbuchsbaum/bidsappr")
  }

  # Create the app scaffolding
  cli::cli_alert_info("Creating BIDS App scaffolding at {.path {path}}")
  bidsappr::new_app(path, app_name)

  # Build the app.R template
  app_template <- build_app_template(app_name, path, tools)

  # Write the customized app.R
  app_r_path <- file.path(path, "app.R")
  writeLines(app_template, app_r_path)

  cli::cli_alert_success("Created niflowr BIDS App at {.path {path}}")
  cli::cli_alert_info("Edit {.file app.R} to customize your pipeline")
  cli::cli_alert_info("Run with: {.code bidsappr::main(app_dir = \"{path}\", argv = c(\"bids_dir\", \"output_dir\", \"participant\"))}")

  invisible(path)
}

#' Build the app.R template with optional tool examples
#'
#' @param app_name Name of the app
#' @param path Path to the app directory
#' @param tools Optional character vector of spec IDs
#' @return Character vector of template lines
#' @keywords internal
build_app_template <- function(app_name, path, tools = NULL) {
  # Base template
  template <- c(
    paste0("# ", app_name, " \u2014 A BIDS App powered by niflowr"),
    "#",
    "# This app was scaffolded with niflowr::ni_bids_app().",
    "# Edit the participant() function below to implement your pipeline.",
    "#",
    paste0("# Run with:"),
    paste0("#   bidsappr::main(app_dir = \"", path, "\", argv = c(\"bids_dir\", \"output_dir\", \"participant\"))"),
    "",
    "library(niflowr)",
    "",
    "participant <- function(ctx, frac = 0.5) {",
    "  for (sub in ctx$subjects()) {",
    "    # Find T1w images for this subject",
    "    t1_files <- ctx$files(suffix = \"T1w\", subject = sub)",
    "",
    "    for (i in seq_len(nrow(t1_files))) {",
    "      # Example: skull stripping with FSL BET",
    "      out_path <- ctx$out_file(",
    "        sub = sub,",
    "        desc = \"brain\",",
    "        suffix = \"T1w\",",
    "        ext = \".nii.gz\"",
    "      )",
    "",
    "      ni_fsl_bet(",
    "        in_file  = t1_files$path[i],",
    "        out_file = out_path,",
    "        frac     = frac,",
    "        mask     = TRUE,",
    "        .engine  = \"native\"",
    "      )",
    "    }",
    "  }",
    "  invisible(TRUE)",
    "}"
  )

  # Add tool-specific examples if provided
  if (!is.null(tools) && length(tools) > 0) {
    template <- c(
      template,
      "",
      "# Additional tool examples (uncomment and customize):",
      ""
    )

    for (tool in tools) {
      template <- c(template, generate_tool_example(tool))
    }
  }

  # Add group-level stub
  template <- c(
    template,
    "",
    "# Uncomment to add group-level analysis:",
    "# group <- function(ctx) {",
    "#   # Aggregate results across participants",
    "#   invisible(TRUE)",
    "# }"
  )

  template
}

#' Generate a commented-out example for a specific tool
#'
#' @param spec_id Tool spec ID
#' @return Character vector of example lines
#' @keywords internal
generate_tool_example <- function(spec_id) {
  # Parse tool name from spec_id (e.g., "fsl.bet" -> "bet", "ants.registration" -> "registration")
  tool_parts <- strsplit(spec_id, "\\.")[[1]]
  if (length(tool_parts) >= 2) {
    suite <- tool_parts[1]
    tool <- tool_parts[2]
    func_name <- paste0("ni_", suite, "_", tool)
  } else {
    func_name <- paste0("ni_", spec_id)
    tool <- spec_id
  }

  c(
    paste0("# # Example: ", tool),
    paste0("# ", func_name, "("),
    "#   # Add your parameters here",
    "#   .engine = \"native\"",
    "# )"
  )
}
