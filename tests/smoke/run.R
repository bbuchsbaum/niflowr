pkgload::load_all(".", quiet = TRUE)
root <- as.character(fs::path_abs(commandArgs(trailingOnly = TRUE)[1]))
fs::dir_create(root)
stopifnot(!dir.exists(file.path(root, "out"))) # Never reuse stale products.
for (d in c("in", "out", "work")) fs::dir_create(file.path(root, d))
python <- Sys.which("python3")
processx::run(python, c("tests/smoke/fixture.py", file.path(root, "in")))
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
# epi_reg consumes a binary WM segmentation derived from FAST's actual labels.
processx::run(python,c("-c",paste0("import nibabel as n,numpy as p,sys; i=n.load(sys.argv[1]); n.save(n.Nifti1Image((i.get_fdata()==3).astype('uint8'),i.affine),sys.argv[2])"),
  seg$outputs$tissue_class_map,out("wm.nii.gz")))
epi <- run("epi_reg","fsl.epi_reg",epi=flirt$outputs$out_file,t1_head=n4$outputs$output_image,
  t1_brain=brain$outputs$out_file,wmseg=out("wm.nii.gz"),out_base=out("epi"))
processx::run(python,c("tests/smoke/verify.py",root),echo=TRUE)
writeLines(system2("git", c("rev-parse","HEAD"),stdout=TRUE), file.path(root,"revision.txt"))
