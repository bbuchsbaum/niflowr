# A real subprocess implementing just the Docker/Apptainer argv protocol. This
# exercises forwarding end-to-end; it does not claim container isolation proof.
contract_runtime <- function(wd) {
  python <- Sys.which("python3")
  skip_if(!nzchar(python), "python3 required for runtime protocol fixture")
  path <- file.path(wd, "runtime.py")
  writeLines(c(paste0("#!", python),
    'import sys, os, subprocess',
    'a=sys.argv[1:]; mode=a.pop(0); env=os.environ.copy(); mounts={}; cwd=None',
    'if mode == "rm": sys.exit(0)',
    'while a:',
    ' x=a[0]',
    ' if x in ("--rm", "--cleanenv", "--containall") or x.startswith("--pull="): a.pop(0); continue',
    ' if x in ("--name", "--platform", "--entrypoint", "-u"): del a[:2]; continue',
    ' if x in ("-w", "--cwd"): cwd=a[1]; del a[:2]; continue',
    ' if x in ("-e", "--env"): k,v=a[1].split("=",1); env[k]=v; del a[:2]; continue',
    ' if x == "--mount":',
    '  m=dict(z.split("=",1) for z in a[1].split(",") if "=" in z); mounts[m["dst"]]=m["src"]; del a[:2]; continue',
    ' if x == "--bind":',
    '  host,cont,mode=a[1].split(":"); mounts[cont]=host; del a[:2]; continue',
    ' break',
    'a.pop(0)',
    'def translate(s):',
    ' for cont,host in sorted(mounts.items(),key=lambda kv: -len(kv[0])):',
    '  if s == cont or s.startswith(cont+"/"): return host+s[len(cont):]',
    ' return s',
    'sys.exit(subprocess.call([translate(x) for x in a],cwd=translate(cwd),env=env))'), path)
  Sys.chmod(path, "0755")
  path
}
contract_container_cfg <- function(wd, bin) {
  for (d in c("in", "out", "work")) dir.create(file.path(wd, d))
  list(paths = list(in_root = file.path(wd, "in"), out_root = file.path(wd, "out"), work_root = file.path(wd, "work")),
    docker = list(bin = bin), apptainer = list(bin = bin, use_sif = FALSE),
    profiles = list(test = list(docker_image = "fixture:test")))
}
