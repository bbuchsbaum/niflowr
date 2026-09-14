# Real Docker checks complement the lightweight runtime protocol unit fixture.
verify_runtime_contracts <- function(root) {
  spec <- structure(list(spec_version="0.1.0", id="test.runtime_smoke",
    command=c("sh", "-c", 'sleep 0.2; printf "%s" "$NIFLOWR_TEST" > same.txt'),
    inputs=list(), outputs=list(out=list(type="file",path=list(static="same.txt"),must_exist=TRUE)),
    runtime=list(profile="ants")), class="ni_spec")
  calls <- lapply(c("one","two"), function(name) ni_call(spec, .cwd=file.path(root,"work",name),
    .engine="docker",.env=c(NIFLOWR_TEST=name)))
  jobs <- lapply(calls, function(call) parallel::mcparallel(ni_run(call,timeout=20,echo=FALSE)))
  results <- parallel::mccollect(jobs)
  stopifnot(identical(sort(unname(vapply(results,function(r) readLines(r$outputs$out,warn=FALSE),character(1)))),c("one","two")))
  slow <- spec; slow$command <- c("sh","-c","sleep 30"); slow$outputs <- list()
  failure <- tryCatch(ni_run(ni_call(slow,.cwd=file.path(root,"work","timeout"),.engine="docker"),timeout=2,echo=FALSE),
                      ni_execution_error=identity)
  stopifnot(inherits(failure,"ni_execution_error"),failure$result$runtime$timed_out)
  argv <- failure$result$provenance$plan$execution$args
  name <- argv[match("--name",argv)+1L]
  stopifnot(processx::run("docker",c("inspect",name),error_on_status=FALSE)$status != 0L)
  cfg <- niflowr:::ni_config_resolve(); cfg$profiles <- cfg$profiles["ants"]
  doctor <- ni_doctor(cfg,check_lock=FALSE,check_payload=TRUE)
  stopifnot(doctor$status[doctor$check=="profile.ants.payload"]=="pass")
  cfg$profiles$ants$entrypoint <- "/bin/true"
  broken <- ni_doctor(cfg,check_lock=FALSE,check_payload=TRUE)
  stopifnot(broken$status[broken$check=="profile.ants.payload"]=="fail")
  jsonlite::write_json(list(concurrency="passed",timeout_cleanup="passed",payload_probe="passed"),
                      file.path(root,"runtime-verification.json"),auto_unbox=TRUE,pretty=TRUE)
}
