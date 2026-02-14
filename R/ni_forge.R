#' Lint niflowr specs with optional autofix
#'
#' Performs mechanical checks on spec JSON files (or parsed specs), including:
#' shell metacharacters in CLI arg strings, positional collisions, invalid flag
#' formats, and broken constraint references.
#'
#' @param spec_dir Directory containing spec JSON files. Ignored if `spec_paths`
#'   is provided.
#' @param spec_paths Optional character vector of spec file paths to lint.
#' @param strict Logical; if `TRUE`, abort when lint errors remain.
#' @param fix Logical; if `TRUE`, apply safe autofixes in-memory.
#' @param write Logical; if `TRUE` and `fix = TRUE`, write modified specs back to
#'   disk.
#' @return A data frame (or tibble, if available) with lint findings.
#' @export
ni_lint_specs <- function(spec_dir = "inst/specs", spec_paths = NULL,
                          strict = FALSE, fix = FALSE, write = fix) {
  if (is.null(spec_paths)) {
    spec_dir <- resolve_spec_dir(spec_dir)
    spec_paths <- list.files(spec_dir, pattern = "\\.json$", full.names = TRUE)
  }
  if (length(spec_paths) == 0) {
    cli::cli_abort("No spec files found to lint.")
  }

  findings <- list()
  updates <- list()

  for (path in sort(spec_paths)) {
    spec <- jsonlite::read_json(path, simplifyVector = FALSE)
    lint <- lint_single_spec(spec, path, fix = fix)
    findings <- c(findings, lint$findings)
    if (!is.null(lint$spec_fixed)) {
      updates[[path]] <- lint$spec_fixed
    }
  }

  out <- if (length(findings) == 0) {
    data.frame(
      spec_id = character(0),
      path = character(0),
      level = character(0),
      code = character(0),
      param = character(0),
      message = character(0),
      fixed = logical(0),
      stringsAsFactors = FALSE
    )
  } else {
    do.call(rbind, findings)
  }

  if (fix && write && length(updates) > 0) {
    for (path in names(updates)) {
      jsonlite::write_json(
        updates[[path]],
        path = path,
        pretty = TRUE,
        auto_unbox = TRUE,
        null = "null"
      )
    }
  }

  out <- as_tidy_table(out)

  if (strict) {
    errs <- out[out$level == "error" & !out$fixed, , drop = FALSE]
    if (nrow(errs) > 0) {
      top <- paste(utils::head(sprintf("%s [%s] %s", errs$spec_id, errs$param, errs$message), 10), collapse = "\n")
      cli::cli_abort(c(
        "Spec lint failed with {.strong {nrow(errs)}} unresolved errors.",
        "x" = "{top}"
      ))
    }
  }

  out
}

#' @keywords internal
resolve_spec_dir <- function(spec_dir) {
  candidates <- unique(c(
    spec_dir,
    file.path("..", spec_dir),
    file.path("..", "..", spec_dir)
  ))
  for (cand in candidates) {
    if (dir.exists(cand)) return(cand)
  }

  pkg_dir <- system.file("specs", package = utils::packageName())
  if (nzchar(pkg_dir) && dir.exists(pkg_dir)) return(pkg_dir)

  spec_dir
}

#' Generate golden command fixtures for all specs
#'
#' Builds deterministic command/argument snapshots for each spec and writes a
#' single JSON fixture suitable for regression testing.
#'
#' @param output Path to the golden JSON fixture file.
#' @param spec_ids Optional spec IDs. Defaults to all bundled specs.
#' @param spec_dir Directory containing specs when running from source.
#' @return Path written (invisibly).
#' @export
ni_golden_cmdline_generate <- function(output = "tests/golden/cmdline_golden.json",
                                       spec_ids = NULL,
                                       spec_dir = "inst/specs") {
  spec_dir <- resolve_spec_dir(spec_dir)

  if (is.null(spec_ids)) {
    all_ids <- ni_spec_list()
    spec_ids <- all_ids[order(all_ids, method = "radix")]
    if (length(spec_ids) == 0 && dir.exists(spec_dir)) {
      raw_ids <- sub("\\.json$", "", list.files(spec_dir, pattern = "\\.json$"))
      spec_ids <- raw_ids[order(raw_ids, method = "radix")]
    }
  }

  if (length(spec_ids) == 0) {
    cli::cli_abort("No specs available for golden command generation.")
  }

  fixtures <- list()

  for (id in spec_ids) {
    local_path <- file.path(spec_dir, paste0(id, ".json"))
    spec <- if (file.exists(local_path)) {
      ni_spec_read(local_path)
    } else {
      ni_spec_read(id)
    }
    values <- synthesize_values_for_spec(spec)
    call <- do.call(ni_call, c(list(spec_id = spec, .validate = FALSE), values))
    cmd <- withCallingHandlers(
      ni_cmd(call),
      warning = function(w) invokeRestart("muffleWarning")
    )

    fixtures[[id]] <- list(
      command = cmd$command,
      args = unname(as.character(cmd$args))
    )
  }

  fs::dir_create(fs::path_dir(output))
  jsonlite::write_json(
    fixtures,
    path = output,
    pretty = TRUE,
    auto_unbox = TRUE,
    null = "null"
  )

  invisible(output)
}

#' @keywords internal
lint_single_spec <- function(spec, path, fix = FALSE) {
  findings <- list()
  fixed <- FALSE
  inputs <- spec$inputs %||% list()
  spec_id <- spec$id %||% fs::path_ext_remove(basename(path))

  add_finding <- function(level, code, param, message, fixed_flag = FALSE) {
    findings[[length(findings) + 1]] <<- data.frame(
      spec_id = spec_id,
      path = path,
      level = level,
      code = code,
      param = param %||% "",
      message = message,
      fixed = isTRUE(fixed_flag),
      stringsAsFactors = FALSE
    )
  }

  # 1) Shell metacharacters in argstr
  for (nm in names(inputs)) {
    def <- inputs[[nm]]
    argstr <- def$cli$argstr
    if (!is.character(argstr) || length(argstr) != 1) next
    if (!grepl("[|<>]", argstr)) next

    rewrite <- rewrite_shell_argstr(argstr, nm)
    if (fix && !is.null(rewrite)) {
      def$cli$argstr <- rewrite$argstr
      if (is.null(def$cli$argstr) || !nzchar(def$cli$argstr)) {
        def$cli$argstr <- NULL
        def$cli$position <- NULL
        def$cli$sep <- NULL
        def$cli$`repeat` <- NULL
      }
      if (isTRUE(rewrite$stdout)) {
        def$cli$stdout_to <- nm
      }
      if (isTRUE(rewrite$stderr)) {
        def$cli$stderr_to <- nm
      }
      inputs[[nm]] <- def
      fixed <- TRUE
      add_finding(
        level = "warning",
        code = "shell_argstr",
        param = nm,
        message = sprintf("Shell argstr rewritten: %s", rewrite$note),
        fixed_flag = TRUE
      )
    } else {
      add_finding(
        level = "error",
        code = "shell_argstr",
        param = nm,
        message = sprintf("argstr contains shell syntax: %s", argstr)
      )
    }
  }

  # 2) Positional collisions among renderable args
  positions <- list()
  for (nm in names(inputs)) {
    cli <- inputs[[nm]]$cli
    if (is.null(cli) || is.null(cli$argstr) || !nzchar(cli$argstr)) next
    pos <- cli$position
    if (is.null(pos)) next
    key <- as.character(pos)
    positions[[key]] <- c(positions[[key]], nm)
  }
  for (key in names(positions)) {
    params_at_pos <- positions[[key]]
    if (length(params_at_pos) > 1) {
      if (fix) {
        keep <- choose_position_winner(inputs, params_at_pos)
        drop <- setdiff(params_at_pos, keep)
        for (nm in drop) {
          if (!is.null(inputs[[nm]]$cli$position)) {
            inputs[[nm]]$cli$position <- NULL
            fixed <- TRUE
          }
        }
        add_finding(
          level = "warning",
          code = "position_collision",
          param = paste(params_at_pos, collapse = ","),
          message = sprintf(
            "Resolved position %s collision by keeping %s; dropped from %s",
            key, keep, paste(drop, collapse = ", ")
          ),
          fixed_flag = TRUE
        )
      } else {
        add_finding(
          level = "error",
          code = "position_collision",
          param = paste(params_at_pos, collapse = ","),
          message = sprintf("Multiple inputs share position %s: %s",
                            key, paste(params_at_pos, collapse = ", "))
        )
      }
    }
  }

  # 3) Flag/bool should not use printf placeholders
  for (nm in names(inputs)) {
    def <- inputs[[nm]]
    if (!def$type %in% c("flag", "bool")) next
    argstr <- def$cli$argstr
    if (is.character(argstr) && grepl("%", argstr)) {
      if (identical(def$type, "flag")) {
        add_finding(
          level = "error",
          code = "flag_placeholder",
          param = nm,
          message = sprintf("%s input has placeholder in argstr: %s", def$type, argstr)
        )
      } else {
        add_finding(
          level = "warning",
          code = "bool_placeholder",
          param = nm,
          message = sprintf("bool input uses formatted argstr: %s", argstr)
        )
      }
    }
  }

  # 4) Constraint references must exist
  input_names <- names(inputs)
  for (nm in input_names) {
    cons <- inputs[[nm]]$constraints
    if (is.null(cons)) next
    for (kind in intersect(names(cons), c("xor", "requires"))) {
      # Normalize to list form so JSON round-trips as arrays under auto_unbox=TRUE.
      if (fix && !is.list(cons[[kind]])) {
        cons[[kind]] <- as.list(as.character(unlist(cons[[kind]])))
        inputs[[nm]]$constraints <- cons
        fixed <- TRUE
        add_finding(
          level = "warning",
          code = "constraint_array_shape",
          param = nm,
          message = sprintf("Normalized constraints.%s to array form.", kind),
          fixed_flag = TRUE
        )
      }

      vals <- unique(as.character(unlist(cons[[kind]])))
      missing <- setdiff(vals, input_names)
      self_ref <- intersect(vals, nm)
      cleaned <- setdiff(intersect(vals, input_names), nm)

      if (fix && (length(missing) > 0 || length(self_ref) > 0)) {
        if (length(cleaned) == 0) {
          cons[[kind]] <- NULL
        } else {
          cons[[kind]] <- as.list(cleaned)
        }
        inputs[[nm]]$constraints <- cons
        fixed <- TRUE

        detail <- c()
        if (length(missing) > 0) detail <- c(detail, paste0("unknown=", paste(missing, collapse = ",")))
        if (length(self_ref) > 0) detail <- c(detail, "self-ref removed")
        add_finding(
          level = "warning",
          code = "constraint_unknown_ref",
          param = nm,
          message = sprintf("Normalized constraints.%s (%s).", kind, paste(detail, collapse = "; ")),
          fixed_flag = TRUE
        )
      } else {
        if (length(missing) > 0) {
          add_finding(
            level = "error",
            code = "constraint_unknown_ref",
            param = nm,
            message = sprintf("constraints.%s references unknown inputs: %s",
                              kind, paste(missing, collapse = ", "))
          )
        }
        if (length(self_ref) > 0) {
          add_finding(
            level = "warning",
            code = "constraint_self_ref",
            param = nm,
            message = sprintf("constraints.%s includes self-reference.", kind)
          )
        }
      }
    }
  }

  # 5) Requires vs xor contradiction
  for (nm in input_names) {
    cons <- inputs[[nm]]$constraints
    if (is.null(cons$requires) || is.null(cons$xor)) next
    req <- as.character(unlist(cons$requires))
    xor <- as.character(unlist(cons$xor))
    overlap <- intersect(req, xor)
    if (length(overlap) > 0) {
      add_finding(
        level = "error",
        code = "constraint_contradiction",
        param = nm,
        message = sprintf("Input both requires and excludes: %s", paste(overlap, collapse = ", "))
      )
    }
  }

  if (fixed) {
    spec$inputs <- inputs
    list(findings = findings, spec_fixed = spec)
  } else {
    list(findings = findings, spec_fixed = NULL)
  }
}

#' @keywords internal
choose_position_winner <- function(inputs, params) {
  score <- vapply(params, function(nm) {
    def <- inputs[[nm]]
    req <- isTRUE(def$required)
    type <- def$type %||% "string"
    # Prefer required and non-flag values for deterministic positional rendering
    (if (req) 100L else 0L) +
      (if (type %in% c("file", "dir", "string", "int", "double", "enum", "list")) 10L else 0L)
  }, integer(1))

  winners <- params[score == max(score)]
  sort(winners)[1]
}

#' @keywords internal
rewrite_shell_argstr <- function(argstr, param_name) {
  x <- trimws(argstr)

  # Pattern: "> %s"
  if (grepl("^>\\s*%s$", x)) {
    return(list(argstr = NULL, stdout = TRUE, stderr = FALSE, note = sprintf("%s -> stdout_to", x)))
  }

  # Pattern: "<prefix> > %s"
  m_redirect <- regexec("^(.*?)\\s*>\\s*%s$", x)
  g_redirect <- regmatches(x, m_redirect)[[1]]
  if (length(g_redirect) > 0) {
    prefix <- trimws(g_redirect[2])
    return(list(
      argstr = if (nzchar(prefix)) prefix else NULL,
      stdout = TRUE,
      stderr = FALSE,
      note = sprintf("%s -> argstr='%s' + stdout_to", x, prefix %||% "")
    ))
  }

  # Pattern: "|& tee %s" or "<prefix> |& tee %s"
  m_tee <- regexec("^(.*?)\\s*\\|&\\s*tee\\s+%s$", x)
  g_tee <- regmatches(x, m_tee)[[1]]
  if (length(g_tee) > 0) {
    prefix <- trimws(g_tee[2])
    return(list(
      argstr = if (nzchar(prefix)) prefix else NULL,
      stdout = TRUE,
      stderr = TRUE,
      note = sprintf("%s -> argstr='%s' + stdout_to + stderr_to", x, prefix %||% "")
    ))
  }

  NULL
}

#' @keywords internal
synthesize_values_for_spec <- function(spec) {
  out <- list()
  inputs <- spec$inputs %||% list()

  for (nm in names(inputs)) {
    def <- inputs[[nm]]
    if (!is.null(def$default) && length(def$default) > 0) {
      out[[nm]] <- def$default
      next
    }
    out[[nm]] <- synthesize_value(nm, def)
  }

  out
}

#' @keywords internal
synthesize_value <- function(name, def) {
  type <- def$type %||% "string"
  lname <- tolower(name)

  if (type == "file") {
    ext <- if (grepl("matrix|mat|xfm|transform", lname)) {
      ".mat"
    } else if (grepl("json", lname)) {
      ".json"
    } else if (grepl("csv", lname)) {
      ".csv"
    } else if (grepl("tsv", lname)) {
      ".tsv"
    } else if (grepl("txt|text|log|report", lname)) {
      ".txt"
    } else {
      ".nii.gz"
    }
    return(file.path("/tmp/niflowr", paste0(name, ext)))
  }

  if (type == "dir") return(file.path("/tmp/niflowr", paste0(name, "_dir")))
  if (type == "string") return(paste0(name, "_value"))
  if (type == "int") return(1L)
  if (type == "double") return(1)
  if (type == "bool" || type == "flag") return(FALSE)
  if (type == "enum") {
    if (!is.null(def$choices) && length(def$choices) > 0) return(def$choices[[1]])
    return("value")
  }
  if (type == "list") return(c("item1", "item2"))

  paste0(name, "_value")
}
