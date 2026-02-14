#' Get or update niflowr runtime configuration
#'
#' By default, `ni_config()` returns the effective configuration computed as:
#'
#' `defaults <- niflowr defaults`
#'
#' `file <- niflowr.yml (if present and auto_read = TRUE)`
#'
#' `effective <- merge(defaults, file, in_memory_overrides)`
#'
#' @param derivatives_dir Base directory used for inferred BIDS-derivatives
#'   outputs. Default: `"derivatives/niflowr"`.
#' @param config Optional named list of configuration overrides to merge into
#'   in-memory overrides.
#' @param config_file Path to project config file. Default: `"niflowr.yml"`.
#' @param auto_read Logical; if `TRUE`, read `config_file` automatically when
#'   resolving config.
#' @param .reset Logical; if `TRUE`, reset in-memory overrides and behavior.
#' @return Named list with current effective configuration.
#' @export
ni_config <- function(derivatives_dir = NULL,
                      config = NULL,
                      config_file = NULL,
                      auto_read = NULL,
                      .reset = FALSE) {
  if (isTRUE(.reset)) {
    .ni_config$overrides <- list()
    .ni_config$config_file <- "niflowr.yml"
    .ni_config$auto_read <- TRUE
  }

  if (!is.null(config_file)) {
    if (!is.character(config_file) || length(config_file) != 1 || !nzchar(config_file)) {
      cli::cli_abort("{.arg config_file} must be a non-empty character string.")
    }
    .ni_config$config_file <- config_file
  }

  if (!is.null(auto_read)) {
    if (!is.logical(auto_read) || length(auto_read) != 1 || is.na(auto_read)) {
      cli::cli_abort("{.arg auto_read} must be TRUE or FALSE.")
    }
    .ni_config$auto_read <- isTRUE(auto_read)
  }

  if (!is.null(derivatives_dir)) {
    if (!is.character(derivatives_dir) || length(derivatives_dir) != 1 || !nzchar(derivatives_dir)) {
      cli::cli_abort("{.arg derivatives_dir} must be a non-empty character string.")
    }
    .ni_config$overrides <- ni_config_merge(
      .ni_config$overrides %||% list(),
      list(derivatives_dir = derivatives_dir)
    )
  }

  if (!is.null(config)) {
    if (!is.list(config)) {
      cli::cli_abort("{.arg config} must be a named list.")
    }
    .ni_config$overrides <- ni_config_merge(.ni_config$overrides %||% list(), config)
  }

  ni_config_resolve()
}

#' Read niflowr project config from YAML
#'
#' @param path Path to a `niflowr.yml` file.
#' @return Parsed configuration list.
#' @keywords internal
ni_config_read <- function(path = "niflowr.yml") {
  if (!file.exists(path)) {
    cli::cli_abort("Config file not found: {.path {path}}")
  }
  if (!requireNamespace("yaml", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg yaml} is required to read {.path niflowr.yml}.")
  }
  cfg <- yaml::read_yaml(path)
  if (is.null(cfg)) list() else cfg
}

#' Resolve effective config (defaults + file + overrides)
#' @keywords internal
ni_config_resolve <- function() {
  defaults <- ni_config_defaults()

  cfg_file <- .ni_config$config_file %||% "niflowr.yml"
  auto_read <- isTRUE(.ni_config$auto_read %||% TRUE)

  file_cfg <- list()
  if (auto_read && file.exists(cfg_file)) {
    file_cfg <- ni_config_read(cfg_file)
  }

  overrides <- .ni_config$overrides %||% list()

  cfg <- ni_config_merge(defaults, file_cfg)
  cfg <- ni_config_merge(cfg, overrides)

  # Ensure key sections always exist for downstream code.
  cfg$runtime <- cfg$runtime %||% list()
  cfg$paths <- cfg$paths %||% list()
  cfg$container_paths <- cfg$container_paths %||% list()
  cfg$docker <- cfg$docker %||% list()
  cfg$apptainer <- cfg$apptainer %||% list()
  cfg$env <- cfg$env %||% list()
  cfg$profiles <- cfg$profiles %||% list()
  cfg
}

#' Default runtime config structure
#' @keywords internal
ni_config_defaults <- function() {
  list(
    version = "0.1",
    derivatives_dir = "derivatives/niflowr",
    runtime = list(
      engine = "auto",
      prefer = "apptainer",
      lockfile = "niflowr.lock.yml",
      lock_enforce = FALSE
    ),
    paths = list(
      in_root = NULL,
      out_root = NULL,
      work_root = NULL,
      stage_unmapped_inputs = FALSE,
      stage_dir = NULL
    ),
    container_paths = list(
      `in` = "/in",
      out = "/out",
      work = "/work"
    ),
    docker = list(
      bin = "docker",
      pull_policy = "missing",
      user = "auto",
      extra_run_args = character(0)
    ),
    apptainer = list(
      bin = "apptainer",
      cleanenv = TRUE,
      containall = TRUE,
      use_sif = TRUE,
      sif_dir = NULL,
      pull_args = character(0),
      extra_exec_args = character(0)
    ),
    env = list(),
    profiles = list()
  )
}

#' Recursive list merge where values in `y` override `x`
#' @keywords internal
ni_config_merge <- function(x, y) {
  if (is.null(y)) return(x)
  if (!is.list(x) || !is.list(y)) return(y)

  out <- x
  y_names <- names(y)
  if (is.null(y_names)) return(y)

  for (nm in y_names) {
    xv <- out[[nm]]
    yv <- y[[nm]]

    if (is.list(xv) && is.list(yv) && !is.null(names(yv))) {
      out[[nm]] <- ni_config_merge(xv, yv)
    } else {
      out[[nm]] <- yv
    }
  }

  out
}

#' @keywords internal
ni_config_get <- function(key, default = NULL) {
  cfg <- ni_config_resolve()

  if (is.null(key) || identical(key, "")) {
    return(cfg)
  }

  parts <- strsplit(key, ".", fixed = TRUE)[[1]]
  val <- cfg
  for (part in parts) {
    if (!is.list(val) || is.null(val[[part]])) {
      return(default)
    }
    val <- val[[part]]
  }

  if (is.null(val)) default else val
}
