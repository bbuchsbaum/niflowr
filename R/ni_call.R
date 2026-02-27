#' Construct an ni_call: bind parameter values to a spec
#'
#' Creates a validated call object that captures a spec plus concrete parameter
#' values, ready for execution or dry-run preview.
#'
#' @param spec_id A spec ID (e.g. `"fsl.bet"`), path to a JSON file, or an
#'   `ni_spec` object.
#' @param ... Named parameter values.
#' @param .cwd Working directory override.
#' @param .env Named character vector of environment variables.
#' @param .engine Execution engine override. One of `"auto"`, `"native"`,
#'   `"docker"`, `"apptainer"`.
#' @param .profile Runtime profile override (maps to `profiles` entry in
#'   `niflowr.yml`).
#' @param .validate Logical; validate inputs at construction time. Default `TRUE`.
#' @return An `ni_call` object (S3 list).
#' @export
ni_call <- function(spec_id, ..., .cwd = NULL, .env = NULL,
                    .engine = NULL, .profile = NULL,
                    .validate = TRUE) {
  # Resolve spec
  if (inherits(spec_id, "ni_spec")) {
    spec <- spec_id
  } else {
    spec <- ni_spec_read(spec_id)
  }

  values <- normalize_input_values(spec, list(...))

  # Validate
  if (.validate) {
    validate_inputs(spec, values)
  }

  # Fill missing output-driving inputs (e.g. out_file) from primary input
  values <- populate_auto_output_inputs(spec, values)

  # Resolve output paths
  outputs <- resolve_outputs(spec, values)

  call <- structure(
    list(
      spec = spec,
      values = values,
      outputs = outputs,
      runtime = list(
        cwd = .cwd,
        env = .env,
        engine = .engine,
        profile = .profile
      )
    ),
    class = "ni_call"
  )

  call
}

#' Normalize and coerce input values for pipeline ergonomics
#' @keywords internal
normalize_input_values <- function(spec, values) {
  for (nm in names(values)) {
    def <- spec$inputs[[nm]]
    if (is.null(def)) next
    values[[nm]] <- coerce_input_value(values[[nm]], def, nm)
  }
  values
}

#' Coerce ni_result / ni_call inputs into file paths
#' @keywords internal
coerce_input_value <- function(value, def, param_name) {
  if (inherits(value, "ni_result")) {
    return(extract_pipeline_path(value$outputs, param_name))
  }
  if (inherits(value, "ni_call")) {
    return(extract_pipeline_path(value$outputs, param_name))
  }

  if (def$type == "list" && is.list(value)) {
    return(unlist(lapply(value, function(x) {
      if (inherits(x, "ni_result")) {
        extract_pipeline_path(x$outputs, param_name)
      } else if (inherits(x, "ni_call")) {
        extract_pipeline_path(x$outputs, param_name)
      } else {
        x
      }
    }), use.names = FALSE))
  }

  if (identical(def$type, "enum")) {
    value <- coerce_enum_value(value, def)
  }

  value
}

#' Coerce ergonomic enum inputs to declared enum choices
#' @keywords internal
coerce_enum_value <- function(value, def) {
  choices <- as.character(def$choices %||% character(0))
  if (length(choices) == 0) return(value)

  if (is.logical(value) && length(value) == 1 && !is.na(value)) {
    yn <- enum_pick_choice(choices, yes = c("y", "yes", "true"), no = c("n", "no", "false"))
    if (!is.null(yn)) {
      return(if (isTRUE(value)) yn$yes else yn$no)
    }

    bit <- enum_pick_choice(choices, yes = c("1"), no = c("0"))
    if (!is.null(bit)) {
      return(if (isTRUE(value)) bit$yes else bit$no)
    }
  }

  if (is.numeric(value) && length(value) == 1 && !is.na(value)) {
    as_chr <- as.character(value)
    if (as_chr %in% choices) return(as_chr)

    if (isTRUE(all.equal(value, trunc(value)))) {
      as_int <- as.character(as.integer(value))
      if (as_int %in% choices) return(as_int)
    }
  }

  value
}

#' Pick matching enum choices for yes/no style mappings
#' @keywords internal
enum_pick_choice <- function(choices, yes, no) {
  lower <- tolower(choices)
  yes_idx <- match(yes, lower, nomatch = 0L)
  no_idx <- match(no, lower, nomatch = 0L)
  yes_idx <- yes_idx[yes_idx > 0][1]
  no_idx <- no_idx[no_idx > 0][1]

  if (length(yes_idx) == 0 || length(no_idx) == 0 || is.na(yes_idx) || is.na(no_idx)) {
    return(NULL)
  }
  list(yes = choices[[yes_idx]], no = choices[[no_idx]])
}

#' Pick a file path from a previous call/result output set
#' @keywords internal
extract_pipeline_path <- function(outputs, preferred_name = NULL) {
  if (!is.list(outputs) || length(outputs) == 0) {
    cli::cli_abort("Cannot pipe into this step: previous result/call has no outputs.")
  }

  if (!is.null(preferred_name) && !is.null(outputs[[preferred_name]]) &&
      is.character(outputs[[preferred_name]]) && nzchar(outputs[[preferred_name]])) {
    return(outputs[[preferred_name]])
  }

  if (!is.null(outputs$out_file) &&
      is.character(outputs$out_file) &&
      nzchar(outputs$out_file)) {
    return(outputs$out_file)
  }

  for (val in outputs) {
    if (is.character(val) && length(val) == 1 && nzchar(val)) {
      return(val)
    }
  }

  cli::cli_abort("Cannot pipe into this step: no usable output file path found.")
}

#' Fill missing output-driving inputs with inferred defaults
#' @keywords internal
populate_auto_output_inputs <- function(spec, values) {
  if (is.null(spec$outputs) || length(spec$outputs) == 0) {
    return(values)
  }

  for (out_name in names(spec$outputs)) {
    path_spec <- spec$outputs[[out_name]]$path
    input_name <- path_spec$from_input
    if (is.null(input_name)) next
    if (!is_missing_value(values[[input_name]])) next

    inferred <- infer_output_path(spec, values, out_name, input_name)
    if (!is.null(inferred)) {
      values[[input_name]] <- inferred
    }
  }

  values
}

#' Infer an output path when a from_input output parameter is omitted
#' @keywords internal
infer_output_path <- function(spec, values, output_name, input_name) {
  source_path <- infer_primary_input_path(spec, values)
  if (is.null(source_path)) return(NULL)

  ext <- infer_output_extension(source_path, output_name, input_name)
  desc <- infer_output_desc(spec$id, output_name)

  if (is_bids_like_path(source_path) && ext %in% c(".nii.gz", ".nii", ".mgh", ".mgz")) {
    return(ni_deriv_path(
      input_path = source_path,
      derivatives_dir = ni_config_get("derivatives_dir", "derivatives/niflowr"),
      desc = desc,
      extension = ext
    ))
  }

  stem <- strip_known_extension(basename(source_path))
  safe_desc <- gsub("[^A-Za-z0-9]+", "-", desc)
  out_name <- paste0(stem, "_", safe_desc, ext)
  file.path(dirname(source_path), out_name)
}

#' @keywords internal
infer_primary_input_path <- function(spec, values) {
  inputs <- spec$inputs
  if (is.null(inputs) || length(inputs) == 0) return(NULL)

  preferred_names <- names(inputs)[vapply(inputs, function(def) {
    identical(def$type, "file") && isTRUE(def$required)
  }, logical(1))]

  for (nm in c(preferred_names, names(inputs))) {
    def <- inputs[[nm]]
    if (is.null(def) || !identical(def$type, "file")) next
    val <- values[[nm]]
    if (is.character(val) && length(val) == 1 && nzchar(val)) {
      return(val)
    }
  }

  NULL
}

#' @keywords internal
infer_output_desc <- function(spec_id, output_name) {
  lname <- tolower(output_name)
  tool <- tolower(sub("^.*\\.", "", spec_id))

  if (grepl("mask", lname)) return("mask")
  if (grepl("matrix|xfm|transform|mat", lname)) return("xfm")
  if (grepl("bet$", tool)) return("brain")
  if (grepl("flirt", tool)) return("reg")
  if (grepl("apply_?warp", tool)) return("warped")
  if (grepl("warp", tool)) return("warp")
  if (identical(lname, "out_file")) return(gsub("_", "-", tool))

  gsub("_", "-", lname)
}

#' @keywords internal
infer_output_extension <- function(source_path, output_name, input_name) {
  hint <- tolower(paste(output_name, input_name, sep = "_"))

  if (grepl("matrix|xfm|transform|mat", hint)) return(".mat")
  if (grepl("json", hint)) return(".json")
  if (grepl("csv", hint)) return(".csv")
  if (grepl("tsv", hint)) return(".tsv")
  if (grepl("txt|text|log|report", hint)) return(".txt")

  ext <- detect_known_extension(source_path)
  if (!is.null(ext)) return(ext)

  ".nii.gz"
}

#' @keywords internal
detect_known_extension <- function(path) {
  m <- regexpr("\\.(nii\\.gz|nii|mgz|mgh|mat|txt|csv|tsv|json)$", path, ignore.case = TRUE)
  if (m[1] < 0) return(NULL)
  tolower(substr(path, m[1], nchar(path)))
}

#' @keywords internal
strip_known_extension <- function(path) {
  sub("\\.(nii\\.gz|nii|mgz|mgh|mat|txt|csv|tsv|json)$", "", path, ignore.case = TRUE)
}

#' @keywords internal
is_bids_like_path <- function(path) {
  fname <- basename(path)
  grepl("^sub-[A-Za-z0-9]+_", fname)
}

#' Resolve output paths from spec and input values
#' @keywords internal
resolve_outputs <- function(spec, values) {
  out <- list()

  for (nm in names(spec$outputs)) {
    odef <- spec$outputs[[nm]]
    path_spec <- odef$path

    if (!is.null(path_spec$from_input)) {
      # Path taken directly from an input value
      input_name <- path_spec$from_input
      out[[nm]] <- values[[input_name]]
    } else if (!is.null(path_spec$template)) {
      # Glue-style template using input values
      tmpl <- path_spec$template
      out[[nm]] <- as.character(tryCatch(
        glue::glue(tmpl, .envir = as.environment(values)),
        error = function(e) {
          cli::cli_abort(c(
            "Failed to resolve output template for {.field {nm}}.",
            "x" = "Template: {.code {tmpl}}",
            "i" = "Error: {e$message}",
            "i" = "Check that all template variables are provided as inputs."
          ))
        }
      ))
    } else if (!is.null(path_spec$static)) {
      out[[nm]] <- path_spec$static
    }
  }

  out
}

#' Get the command + args that would be executed
#'
#' @param call An `ni_call` object.
#' @return A list with `command`, `args`, `wd`, `env`, `stdout`, `stderr`.
#' @export
ni_cmd <- function(call) {
  stopifnot(inherits(call, "ni_call"))
  built <- build_command(call)
  rt <- call$runtime %||% list()

  list(
    command = built$command,
    args = built$args,
    wd = rt$cwd,
    env = rt$env,
    engine = rt$engine,
    profile = rt$profile,
    stdout = built$stdout,
    stderr = built$stderr
  )
}

#' @export
print.ni_call <- function(x, ...) {
  built <- build_command(x)
  cmd_str <- paste(c(built$command, built$args), collapse = " ")

  cli::cli_h3("ni_call: {x$spec$id}")
  cli::cli_text("Command: {.code {cmd_str}}")

  rt <- x$runtime %||% list()
  if (!is.null(rt$cwd)) {
    cli::cli_text("Working dir: {.path {rt$cwd}}")
  }
  if (!is.null(rt$engine)) {
    cli::cli_text("Engine override: {.val {rt$engine}}")
  }
  if (!is.null(rt$profile)) {
    cli::cli_text("Profile override: {.val {rt$profile}}")
  }

  if (length(x$outputs) > 0) {
    cli::cli_h3("Expected outputs")
    for (nm in names(x$outputs)) {
      cli::cli_text("  {.field {nm}}: {.path {x$outputs[[nm]]}}")
    }
  }

  invisible(x)
}
