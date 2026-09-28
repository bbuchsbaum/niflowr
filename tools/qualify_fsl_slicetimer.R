#!/usr/bin/env Rscript

if (!requireNamespace("RNifti", quietly = TRUE)) stop("RNifti is required")
if (!requireNamespace("pkgload", quietly = TRUE)) stop("pkgload is required")
pkgload::load_all(".", quiet = TRUE)

args <- commandArgs(trailingOnly = TRUE)
image <- if (length(args)) args[[1L]] else Sys.getenv("NIFLOWR_FSL_IMAGE", "48724e8a5a8d")
out <- if (length(args) >= 2L) args[[2L]] else "inst/qualification/fsl-slicetimer.json"
if (!nzchar(Sys.which("docker"))) stop("docker is required")

work <- tempfile("niflowr-fsl-slicetimer-")
dir.create(work)
on.exit(unlink(work, recursive = TRUE, force = TRUE), add = TRUE)
n_time <- 32L
phase <- 0:(n_time - 1L)
base_signal <- sin(2 * pi * phase / 8)
late_signal <- sin(2 * pi * (phase + 0.5) / 8)
middle <- 5:28

run_case <- function(direction, reference_time) {
  values <- array(0, c(2, 2, 2, n_time))
  for (i in 1:2) for (j in 1:2) for (k in 1:2) {
    slice <- c(i, j, k)[[direction]]
    values[i, j, k, ] <- if (slice == 1L) base_signal else late_signal
  }
  label <- paste0("d", direction, "-r", reference_time)
  input <- file.path(work, paste0(label, "-input.nii.gz"))
  timing_path <- file.path(work, paste0(label, "-timing.txt"))
  output_stem <- file.path("/data", paste0(label, "-output"))
  RNifti::writeNifti(values, input)
  timing <- ni_fsl_slice_timing_file(c(0, 1), 2, reference_time, timing_path)
  command <- c(
    "run", "--rm", "--platform", "linux/amd64",
    "-v", paste0(work, ":/data"), image,
    "slicetimer",
    paste0("--in=/data/", basename(input)),
    paste0("--out=", output_stem),
    "--repeat=2",
    paste0("--direction=", direction),
    paste0("--tcustom=/data/", basename(timing_path))
  )
  result <- processx::run("docker", command, error_on_status = FALSE)
  if (result$status != 0L) stop(result$stderr)
  corrected <- RNifti::readNifti(file.path(work, paste0(label, "-output.nii.gz")))
  pick <- function(image, slice) {
    index <- list(1L, 1L, 1L, middle)
    index[[direction]] <- slice
    do.call(`[`, c(list(image), index, list(drop = TRUE)))
  }
  raw_rmse <- sqrt(mean((pick(values, 1L) - pick(values, 2L))^2))
  corrected_rmse <- sqrt(mean((pick(corrected, 1L) - pick(corrected, 2L))^2))
  list(
    direction = direction,
    reference_time_seconds = reference_time,
    forward_shift_fractions = unname(timing$shifts),
    raw_slice_rmse = raw_rmse,
    corrected_slice_rmse = corrected_rmse,
    improvement_ratio = raw_rmse / corrected_rmse,
    passed = isTRUE(corrected_rmse < 0.03 && raw_rmse / corrected_rmse > 10)
  )
}

help <- processx::run(
  "docker",
  c("run", "--rm", "--platform", "linux/amd64", image, "slicetimer", "--help"),
  error_on_status = FALSE
)
help_text <- paste(help$stdout, help$stderr, sep = "\n")
version_lines <- grep("Part of FSL", strsplit(help_text, "\n", fixed = TRUE)[[1L]], value = TRUE)
if (!length(version_lines)) stop("could not identify the FSL slicetimer version")
inspect <- processx::run("docker", c("image", "inspect", image, "--format", "{{.Id}}"))
cases <- c(
  lapply(1:3, run_case, reference_time = 0),
  list(run_case(3, reference_time = 1))
)
if (!all(vapply(cases, `[[`, logical(1), "passed"))) {
  stop("one or more FSL slicetimer phase fixtures failed")
}
report <- list(
  schema_version = "1.0",
  backend = list(
    program = "FSL slicetimer",
    version_line = version_lines[[1L]],
    docker_image_argument = image,
    docker_image_id = trimws(inspect$stdout),
    platform = "linux/amd64"
  ),
  estimand = "RMSE between two slices sampling the same sinusoid half a TR apart after correction",
  thresholds = list(max_corrected_rmse = 0.03, min_improvement_ratio = 10),
  cases = cases,
  passed = TRUE
)
dir.create(dirname(out), recursive = TRUE, showWarnings = FALSE)
jsonlite::write_json(report, out, auto_unbox = TRUE, pretty = TRUE, digits = NA)
cat("Wrote", out, "\n")
