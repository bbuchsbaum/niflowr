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

  for (nm in names(inputs)) {
    def <- inputs[[nm]]
    if (is.null(def$cli) && is.null(spec$render) && !identical(def$role, "output")) {
      add_finding("warning", "unimplemented_input", nm,
                  "Input has no CLI rendering or custom implementation; audit imported behavior.")
    }
  }
  for (nm in names(spec$outputs)) {
    source <- spec$outputs[[nm]]$path$from_input
    if (!is.null(source) && !inputs[[source]]$type %in% c("file", "dir", "list"))
      add_finding("warning", "incompatible_output_input", source, "Output references a non-path input; automatic inference is disabled.")

    transform <- spec$outputs[[nm]]$transform
    if (is.null(transform)) next
    for (domain in c("source", "target")) {
      ref <- transform[[domain]]
      if (is.null(inputs[[ref]])) {
        add_finding(
          "error", "unknown_transform_domain", nm,
          sprintf("Transform %s references unknown input '%s'.", domain, ref)
        )
      } else if (!inputs[[ref]]$type %in% c("file", "list")) {
        add_finding(
          "error", "invalid_transform_domain", nm,
          sprintf("Transform %s input '%s' must be typed file or list.", domain, ref)
        )
      }
    }
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

  # 6) Placeholder descriptions (TODO/TBD/FIXME) are not allowed
  if (is_placeholder_text(spec$description)) {
    add_finding(
      level = "error",
      code = "placeholder_desc",
      param = "description",
      message = "Top-level description contains placeholder text."
    )
  }

  for (nm in names(inputs)) {
    desc <- inputs[[nm]]$desc
    if (is_placeholder_text(desc)) {
      add_finding(
        level = "error",
        code = "placeholder_desc",
        param = nm,
        message = "Input description contains placeholder text."
      )
    }
  }

  # 7) FSL image outs need strip_ext so tools do not double-append FSLOUTPUTTYPE.
  # Text/matrix outs must keep their full filename (e.g. fslmeants .txt).
  if (grepl("^fsl\\.", spec_id)) {
    for (nm in names(inputs)) {
      def <- inputs[[nm]]
      # Basename outs are often typed string (eddy/epi_reg out_base); still strip.
      if (!(identical(def$type, "file") ||
            identical(def$type, "string") ||
            (identical(def$type, "list") && identical(def$items_type, "file")))) {
        next
      }
      cli <- def$cli
      if (is.null(cli) || is.null(cli$argstr) || !nzchar(cli$argstr)) next
      needs <- fsl_needs_strip_ext(nm, cli$argstr, def$desc)

      if (isTRUE(cli$strip_ext) && !needs) {
        if (fix) {
          inputs[[nm]]$cli$strip_ext <- NULL
          fixed <- TRUE
          add_finding(
            level = "warning",
            code = "fsl_strip_ext_clear",
            param = nm,
            message = "Cleared cli.strip_ext so text/matrix outs keep their full filename.",
            fixed_flag = TRUE
          )
        } else {
          add_finding(
            level = "warning",
            code = "fsl_strip_ext_clear",
            param = nm,
            message = "cli.strip_ext=TRUE is incorrect for this non-image FSL output."
          )
        }
        next
      }

      if (isTRUE(cli$strip_ext)) next
      if (!needs) next

      if (fix) {
        inputs[[nm]]$cli$strip_ext <- TRUE
        fixed <- TRUE
        add_finding(
          level = "warning",
          code = "fsl_strip_ext",
          param = nm,
          message = "Marked cli.strip_ext=TRUE so FSL receives a basename without .nii.gz.",
          fixed_flag = TRUE
        )
      } else {
        add_finding(
          level = "warning",
          code = "fsl_strip_ext",
          param = nm,
          message = "FSL image output should set cli.strip_ext=TRUE to avoid doubled extensions."
        )
      }
    }
  }

  # 8) String inputs with numeric printf formats must be typed int/double
  for (nm in names(inputs)) {
    def <- inputs[[nm]]
    if (!identical(def$type, "string")) next
    argstr <- def$cli$argstr %||% ""
    new_type <- numeric_type_for_argstr(argstr)
    if (is.null(new_type)) next

    if (fix) {
      inputs[[nm]]$type <- new_type
      fixed <- TRUE
      add_finding(
        level = "warning",
        code = "numeric_argstr_type",
        param = nm,
        message = sprintf("Typed as %s to match numeric argstr format.", new_type),
        fixed_flag = TRUE
      )
    } else {
      add_finding(
        level = "warning",
        code = "numeric_argstr_type",
        param = nm,
        message = sprintf("Input renders numeric format but is typed string; prefer %s.", new_type)
      )
    }
  }

  # 9) Output-prefix inputs must be typed file so containers rewrite host paths
  for (nm in names(inputs)) {
    def <- inputs[[nm]]
    if (!identical(def$type, "string")) next
    if (!is_output_prefix_name(nm)) next

    if (fix) {
      inputs[[nm]]$type <- "file"
      fixed <- TRUE
      add_finding(
        level = "warning",
        code = "output_prefix_type",
        param = nm,
        message = "Typed output prefix as file so container runs rewrite the host path.",
        fixed_flag = TRUE
      )
    } else {
      add_finding(
        level = "warning",
        code = "output_prefix_type",
        param = nm,
        message = "Output prefix input should be typed file for container path rewriting."
      )
    }
  }

  # 10) Path-like list inputs need items_type=file for container mapping
  for (nm in names(inputs)) {
    def <- inputs[[nm]]
    if (!identical(def$type, "list")) next
    if (isTRUE(def$nested)) next
    if (!is.null(def$items_type) && nzchar(def$items_type)) next
    if (!is_path_list_input(nm, def)) next

    if (fix) {
      inputs[[nm]]$items_type <- "file"
      fixed <- TRUE
      add_finding(
        level = "warning",
        code = "path_list_items_type",
        param = nm,
        message = "Set items_type=file so container runs rewrite path list elements.",
        fixed_flag = TRUE
      )
    } else {
      add_finding(
        level = "warning",
        code = "path_list_items_type",
        param = nm,
        message = "Path-like list input should set items_type=file."
      )
    }
  }

  # 11) Nested lists are not path-mapped for containers and the generic argstr
  # loop cannot render them, so they need non-path items and a custom renderer.
  for (nm in names(inputs)) {
    def <- inputs[[nm]]
    if (!isTRUE(def$nested)) next
    if (!identical(def$type, "list") || (def$items_type %||% "") %in% c("file", "dir") ||
        is.null(spec$render)) {
      add_finding(
        level = "error",
        code = "invalid_nested_list",
        param = nm,
        message = "nested applies only to non-path list inputs of specs with a custom renderer."
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

#' Whether an FSL input should strip known extensions before CLI rendering
#'
#' Image outs (BET/MCFLIRT `-out`, FAST basenames, …) strip `.nii.gz` so FSL
#' does not double-append `FSLOUTPUTTYPE`. Text/matrix outs keep the full path
#' (e.g. `fslmeants -o mean.txt`).
#'
#' @keywords internal
fsl_needs_strip_ext <- function(name, argstr, desc = NULL) {
  argstr <- as.character(argstr %||% "")
  desc <- as.character(desc %||% "")
  # Matrix / schedule outs keep their full filename (including .mat).
  if (grepl("omat|outmat|matrix|\\.mat|schedule", argstr, ignore.case = TRUE)) {
    return(FALSE)
  }
  if (grepl("omat|outmat|matrix|schedule", name, ignore.case = TRUE)) {
    return(FALSE)
  }
  # Text / tabular outs keep .txt/.tsv (fslmeants, Vest2Text, …).
  if (grepl("text|\\.txt|\\.tsv|\\btsv\\b|\\bcsv\\b|tabular", desc, ignore.case = TRUE)) {
    return(FALSE)
  }
  # Matrix-format outs described only in the trait text (e.g. Text2Vest).
  if (grepl("matrix|\\.mat", desc, ignore.case = TRUE) &&
      !grepl("nifti|image|volume|warp", desc, ignore.case = TRUE)) {
    return(FALSE)
  }
  if (grepl("(^|\\s)-out(\\s|=|%|$)|--out=", argstr)) {
    return(TRUE)
  }
  # BET-style positional out and FAST/eddy-style basename outs.
  if (name %in% c("out_file", "out_basename", "out_base")) {
    return(TRUE)
  }
  FALSE
}

#' Map a printf conversion in argstr to int/double, or NULL if not numeric
#' @keywords internal
numeric_type_for_argstr <- function(argstr) {
  argstr <- as.character(argstr %||% "")
  if (!nzchar(argstr)) return(NULL)
  m <- regexpr("%[-+ #0-9.*]*[diouxXeEfgGaAs]", argstr)
  if (m < 0) return(NULL)
  conv <- regmatches(argstr, m)
  letter <- substr(conv, nchar(conv), nchar(conv))
  if (letter %in% c("d", "i", "o", "u", "x", "X")) return("int")
  if (letter %in% c("f", "F", "e", "E", "g", "G", "a", "A")) return("double")
  NULL
}

#' Output-prefix / basename inputs that containers must treat as paths
#' @keywords internal
is_output_prefix_name <- function(name) {
  grepl("(^prefix$|out_base$|out_basename$|out_base_name$|_prefix$)", name)
}

#' Heuristic: list input carries file paths and needs items_type=file
#' @keywords internal
is_path_list_input <- function(name, def) {
  if (grepl("(^|_)(in_)?files?$|_files$|operand_files|images?$|volumes?$", name)) {
    return(TRUE)
  }
  desc <- as.character(def$desc %||% "")
  if (grepl("\\b(file|files|image|images|volume|volumes|dataset|nifti)\\b", desc, ignore.case = TRUE)) {
    return(TRUE)
  }
  FALSE
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
is_placeholder_text <- function(x) {
  is.character(x) &&
    length(x) == 1 &&
    nzchar(trimws(x)) &&
    grepl("^\\s*(todo|tbd|fixme|xxx)\\b", x, ignore.case = TRUE)
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

  if (identical(spec$render, "ants_n4") && !isTRUE(out$save_bias)) out$bias_image <- NULL
  if (identical(spec$render, "fsl_applyxfm4d")) out$single_matrix <- NULL
  out
}

#' @keywords internal
synthesize_value <- function(name, def) {
  type <- def$type %||% "string"
  lname <- tolower(name)

  if (type == "file") {
    desc <- tolower(as.character(def$desc %||% ""))
    ext <- if (grepl("matrix|mat|xfm|transform", lname)) {
      ".mat"
    } else if (grepl("json", lname)) {
      ".json"
    } else if (grepl("csv", lname)) {
      ".csv"
    } else if (grepl("tsv", lname)) {
      ".tsv"
    } else if (grepl("txt|text|log|report", lname) ||
               (grepl("^out", lname) &&
                  grepl("text matrix|text output|\\.txt\\b|tabular", desc))) {
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
  if (type == "list") {
    items <- if (!is.null(def$choices) && length(def$choices) > 0) {
      rep_len(unlist(def$choices, use.names = FALSE), 2L)
    } else {
      switch(def$items_type %||% "",
        bool = c(FALSE, TRUE),
        int = c(1L, 2L),
        double = c(0.25, 0.5),
        c("item1", "item2")
      )
    }
    # Nested: a one-value element and a two-value element. The two values are
    # equal so renderers that require agreement within an element (e.g. ANTs
    # per-stage sampling) still accept them.
    if (isTRUE(def$nested)) return(list(items[1], rep(items[1], 2L)))
    return(items)
  }

  paste0(name, "_value")
}
