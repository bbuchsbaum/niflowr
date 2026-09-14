#!/usr/bin/env bash
# Cloud Agent install script for the niflowr R package.
#
# Idempotent: safe to re-run. It (1) installs the system toolchain R and the
# package's compiled dependencies need, and (2) installs the R packages the
# package code, codegen tools, and test suite require.
#
# The R dependency set mirrors CI (.github/workflows/*.yml): a plain
# install.packages() of the concrete packages, deliberately NOT resolving the
# DESCRIPTION, so the non-CRAN Suggests (bidsappr, neuroim2, ...) are skipped.
set -euo pipefail

# --- 1. System dependencies -------------------------------------------------
# R itself plus the build toolchain, and libnode-dev, which jsonvalidate's V8
# backend links against at runtime. apt-get install is idempotent, so this is a
# fast no-op once the packages are present; only refresh the index when a
# required package is actually missing.
SYS_PKGS=(r-base-dev libnode-dev libcurl4-openssl-dev libssl-dev libxml2-dev git curl pandoc ca-certificates)
missing_sys=()
for p in "${SYS_PKGS[@]}"; do
  dpkg -s "$p" >/dev/null 2>&1 || missing_sys+=("$p")
done
if [ "${#missing_sys[@]}" -gt 0 ]; then
  echo "Installing system packages: ${missing_sys[*]}"
  sudo apt-get update -qq
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${missing_sys[@]}"
else
  echo "System packages already installed."
fi

# --- 2. R package dependencies ----------------------------------------------
# Posit Public Package Manager serves precompiled binaries for Ubuntu Noble,
# which makes the install fast and deterministic.
export NIFLOWR_PPM="${NIFLOWR_PPM:-https://packagemanager.posit.co/cran/__linux__/noble/latest}"

# Install into R's standard per-user library. R adds this path to .libPaths()
# automatically when the directory exists, so later `Rscript` invocations need
# no R_LIBS_USER export, and we avoid needing write access to the system
# site-library.
USER_LIB="$(Rscript -e 'cat(Sys.getenv("R_LIBS_USER"))')"
mkdir -p "$USER_LIB"

Rscript - <<'RS'
pkgs <- c(
  "cli", "digest", "fs", "glue", "jsonlite", "jsonvalidate",
  "processx", "yaml", "pkgload", "testthat", "withr", "tibble"
)
options(
  Ncpus = parallel::detectCores(),
  repos = c(PPM = Sys.getenv("NIFLOWR_PPM")),
  # Sending this User-Agent makes Posit Package Manager serve precompiled
  # Ubuntu Noble binaries instead of source tarballs, which is much faster.
  HTTPUserAgent = sprintf(
    "R/%s R (%s)", getRversion(),
    paste(getRversion(), R.version["platform"], R.version["arch"], R.version["os"])
  )
)
lib <- Sys.getenv("R_LIBS_USER")
dir.create(lib, showWarnings = FALSE, recursive = TRUE)
.libPaths(c(lib, .libPaths()))

missing <- pkgs[!(pkgs %in% rownames(installed.packages()))]
if (length(missing)) {
  install.packages(missing)
} else {
  message("All required R packages already installed.")
}
still_missing <- pkgs[!(pkgs %in% rownames(installed.packages()))]
if (length(still_missing)) {
  stop("Failed to install: ", paste(still_missing, collapse = ", "))
}
message("niflowr R dependencies ready: ", paste(pkgs, collapse = ", "))
RS
