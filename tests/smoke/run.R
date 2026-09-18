pkgload::load_all(".", quiet = TRUE)
root <- as.character(fs::path_abs(commandArgs(trailingOnly = TRUE)[1]))
fs::dir_create(root)
stopifnot(!dir.exists(file.path(root, "out"))) # Never reuse stale products.
for (d in c("in", "out", "work")) fs::dir_create(file.path(root, d))
python <- Sys.getenv("NIFLOWR_SMOKE_PYTHON", Sys.which("python3"))
if (!nzchar(python)) stop("No python3 found; set NIFLOWR_SMOKE_PYTHON.")
message("Smoke fixtures use ", python)
# R's ldpaths prepends system library dirs to LD_LIBRARY_PATH, so a shared-lib
# interpreter (e.g. setup-python's) would load the distro libpython and its
# frozen site module, which drops the interpreter's own site-packages.
py_env <- c("current", LD_LIBRARY_PATH = paste(c(file.path(dirname(dirname(python)), "lib"),
  Sys.getenv("LD_LIBRARY_PATH")), collapse = .Platform$path.sep))
run_python <- function(args, ...) processx::run(python, args, env = py_env, ...)
run_python(c("tests/smoke/fixture.py", file.path(root, "in")))
images <- jsonlite::read_json(Sys.getenv("NIFLOWR_SMOKE_IMAGES", "tests/smoke/images.json"), simplifyVector = TRUE)
profiles <- lapply(images, function(x) list(docker_image = x$image, platform = x$platform, entrypoint = x$entrypoint))
invisible(ni_config(.reset = TRUE, auto_read = FALSE))
invisible(ni_config(config = list(paths = list(in_root=file.path(root,"in"),out_root=file.path(root,"out"),work_root=file.path(root,"work")),
  profiles=profiles, docker=list(pull_policy="never"),env=list(ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS="1",OMP_NUM_THREADS="1"))))
source("tests/smoke/runtime.R")
verify_runtime_contracts(root)
results <- list()
run <- function(name, spec, ...) {
  result <- ni_run(ni_call(spec, ..., .engine="docker", .cwd=file.path(root,"work",name)),
    timeout=300, echo=TRUE, log_dir=file.path(root,"logs"))
  results[[name]] <<- list(outputs=result$outputs, provenance=result$provenance)
  jsonlite::write_json(results,file.path(root,"results.json"),auto_unbox=TRUE,pretty=TRUE,null="null")
  result
}
out <- function(x) file.path(root,"out",x)
infile <- function(x) file.path(root,"in",x)
n4 <- run("n4","ants.n4_bias_field_correction",input_image=infile("t1.nii.gz"),output_image=out("corrected.nii.gz"),
  mask_image=infile("mask.nii.gz"),dimension=3,save_bias=TRUE,rescale_intensities=FALSE,shrink_factor=2,n_iterations=c(5,5))
brain <- run("bet","fsl.bet",in_file=n4$outputs$output_image,out_file=out("brain.nii.gz"),mask=TRUE,frac=.35)
seg <- run("fast","fsl.fast",in_files=brain$outputs$out_file,out_basename=out("seg"),number_classes=3,img_type=1,
  probability_maps=TRUE,output_biascorrected=TRUE,output_biasfield=TRUE)
mc <- run("mcflirt","fsl.mcflirt",in_file=infile("bold.nii.gz"),out_file=out("mc.nii.gz"),save_mats=TRUE,save_plots=TRUE)
flirt <- run("flirt","fsl.flirt",in_file=brain$outputs$out_file,reference=brain$outputs$out_file,
  out_file=out("registered.nii.gz"),out_matrix_file=out("registered.mat"),dof=6)
# Three-stage Rigid + Affine + SyN exercising every per-stage antsRegistration input.
antsreg <- run("ants_registration","ants.registration",fixed_image=brain$outputs$out_file,
  moving_image=n4$outputs$output_image,transforms=c("Rigid","Affine","SyN"),
  transform_parameters=c("0.1","0.1","0.1,3,0"),metric=c("Mattes","Mattes","CC"),metric_weight=1,
  radius_or_number_of_bins=c(32,32,2),sampling_strategy=c("Regular","Regular","None"),
  sampling_percentage=c(0.25,0.25,1),number_of_iterations=c("20x10","20x10","10x5"),
  convergence_threshold=1e-6,convergence_window_size=5,shrink_factors="2x1",smoothing_sigmas="1x0vox",
  use_histogram_matching=TRUE,winsorize_lower_quantile=0.005,winsorize_upper_quantile=0.995,
  output_transform_prefix=out("antsreg_"),output_warped_image=out("antsreg_Warped.nii.gz"),
  output_inverse_warped_image=out("antsreg_InverseWarped.nii.gz"),write_composite_transform=TRUE,
  float=TRUE,random_seed=1)
# epi_reg consumes a binary WM segmentation derived from FAST's actual labels.
run_python(c("-c",paste0("import nibabel as n,numpy as p,sys; i=n.load(sys.argv[1]); n.save(n.Nifti1Image((i.get_fdata()==3).astype('uint8'),i.affine),sys.argv[2])"),
  seg$outputs$tissue_class_map,out("wm.nii.gz")))
epi <- run("epi_reg","fsl.epi_reg",epi=flirt$outputs$out_file,t1_head=n4$outputs$output_image,
  t1_brain=brain$outputs$out_file,wmseg=out("wm.nii.gz"),out_base=out("epi"))
run_python(c("tests/smoke/verify.py",root),echo=TRUE)
writeLines(system2("git", c("rev-parse","HEAD"),stdout=TRUE), file.path(root,"revision.txt"))
