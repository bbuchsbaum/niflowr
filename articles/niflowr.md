# Getting started with niflowr

## Why niflowr?

Neuroimaging pipelines call many command-line tools — FSL’s `bet`, ANTs’
`antsRegistration`, FreeSurfer’s `recon-all` — each with its own
argument syntax, validation quirks, and output conventions. Wrapping
these in R typically means writing brittle
[`system()`](https://rdrr.io/r/base/system.html) calls with
[`paste()`](https://rdrr.io/r/base/paste.html)-assembled shell strings,
no input validation, and no record of what ran. niflowr takes a
different approach:

- **Tool interfaces are defined as JSON specs**, not executable code.
  Each spec declares inputs, outputs, CLI rendering rules, and
  validation constraints.
- **Commands are built as argument vectors**, never shell strings — no
  quoting bugs, no injection hazards.
- **Execution captures provenance** — what command ran, with what
  arguments, how long it took, and what it produced.
- **Pipeline orchestration is left to {targets}** — niflowr handles the
  interface layer; {targets} and {crew} handle scheduling, caching, and
  parallelism.

## Quick example

Here’s what it looks like to run FSL’s brain extraction tool:

``` r

result <- ni_fsl_bet(
  in_file  = "sub-01_T1w.nii.gz",
  out_file = "sub-01_desc-brain_T1w.nii.gz",
  frac     = 0.5,
  mask     = TRUE
)

ni_outputs(result)
#> $out_file
#> [1] "sub-01_desc-brain_T1w.nii.gz"
#> $mask_file
#> [1] "sub-01_desc-brain_T1w.nii.gz_mask.nii.gz"
```

That single call validated your inputs, built a safe argument vector,
ran `bet` via `processx`, checked that outputs exist, and wrote a
provenance sidecar — all without a single
[`paste()`](https://rdrr.io/r/base/paste.html) or
[`system()`](https://rdrr.io/r/base/system.html).

## Browsing available specs

niflowr ships with specs for common tools across four major suites:

``` r

ni_spec_list()
#>   [1] "afni.a_boverlap"                            
#>   [2] "afni.afn_ito_nifti"                         
#>   [3] "afni.align_epi_anat_py"                     
#>   [4] "afni.allineate"                             
#>   [5] "afni.auto_tcorrelate"                       
#>   [6] "afni.auto_tlrc"                             
#>   [7] "afni.autobox"                               
#>   [8] "afni.automask"                              
#>   [9] "afni.axialize"                              
#>  [10] "afni.bandpass"                              
#>  [11] "afni.blur_in_mask"                          
#>  [12] "afni.blur_to_fwhm"                          
#>  [13] "afni.brick_stat"                            
#>  [14] "afni.bucket"                                
#>  [15] "afni.calc"                                  
#>  [16] "afni.cat_matvec"                            
#>  [17] "afni.cat"                                   
#>  [18] "afni.center_mass"                           
#>  [19] "afni.clip_level"                            
#>  [20] "afni.convert_dset"                          
#>  [21] "afni.copy"                                  
#>  [22] "afni.deconvolve"                            
#>  [23] "afni.degree_centrality"                     
#>  [24] "afni.despike"                               
#>  [25] "afni.detrend"                               
#>  [26] "afni.dot"                                   
#>  [27] "afni.ecm"                                   
#>  [28] "afni.edge3"                                 
#>  [29] "afni.eval"                                  
#>  [30] "afni.fim"                                   
#>  [31] "afni.fourier"                               
#>  [32] "afni.fwh_mx"                                
#>  [33] "afni.gcor"                                  
#>  [34] "afni.hist"                                  
#>  [35] "afni.lfcd"                                  
#>  [36] "afni.local_bistat"                          
#>  [37] "afni.localstat"                             
#>  [38] "afni.mask_tool"                             
#>  [39] "afni.maskave"                               
#>  [40] "afni.means"                                 
#>  [41] "afni.merge"                                 
#>  [42] "afni.net_corr"                              
#>  [43] "afni.notes"                                 
#>  [44] "afni.nwarp_adjust"                          
#>  [45] "afni.nwarp_apply"                           
#>  [46] "afni.nwarp_cat"                             
#>  [47] "afni.one_d_tool_py"                         
#>  [48] "afni.outlier_count"                         
#>  [49] "afni.quality_index"                         
#>  [50] "afni.qwarp_plus_minus"                      
#>  [51] "afni.qwarp"                                 
#>  [52] "afni.re_ho"                                 
#>  [53] "afni.refit"                                 
#>  [54] "afni.remlfit"                               
#>  [55] "afni.resample"                              
#>  [56] "afni.retroicor"                             
#>  [57] "afni.roi_stats"                             
#>  [58] "afni.seg"                                   
#>  [59] "afni.skull_strip"                           
#>  [60] "afni.svm_test"                              
#>  [61] "afni.svm_train"                             
#>  [62] "afni.synthesize"                            
#>  [63] "afni.t_cat_sub_brick"                       
#>  [64] "afni.t_cat"                                 
#>  [65] "afni.t_corr_map"                            
#>  [66] "afni.t_corr1_d"                             
#>  [67] "afni.t_correlate"                           
#>  [68] "afni.t_norm"                                
#>  [69] "afni.t_project"                             
#>  [70] "afni.t_shift"                               
#>  [71] "afni.t_smooth"                              
#>  [72] "afni.t_stat"                                
#>  [73] "afni.to3_d"                                 
#>  [74] "afni.undump"                                
#>  [75] "afni.unifize"                               
#>  [76] "afni.volreg"                                
#>  [77] "afni.warp"                                  
#>  [78] "afni.z_cut_up"                              
#>  [79] "afni.zcat"                                  
#>  [80] "afni.zeropad"                               
#>  [81] "ants.affine_initializer"                    
#>  [82] "ants.ai"                                    
#>  [83] "ants.ants_introduction"                     
#>  [84] "ants.ants"                                  
#>  [85] "ants.apply_transforms_to_points"            
#>  [86] "ants.apply_transforms"                      
#>  [87] "ants.atropos"                               
#>  [88] "ants.average_affine_transform"              
#>  [89] "ants.average_images"                        
#>  [90] "ants.brain_extraction"                      
#>  [91] "ants.buildtemplateparallel"                 
#>  [92] "ants.compose_multi_transform"               
#>  [93] "ants.composite_transform_util"              
#>  [94] "ants.convert_scalar_image_to_rgb"           
#>  [95] "ants.cortical_thickness"                    
#>  [96] "ants.create_jacobian_determinant_image"     
#>  [97] "ants.create_tiled_mosaic"                   
#>  [98] "ants.denoise_image"                         
#>  [99] "ants.gen_warp_fields"                       
#> [100] "ants.image_math"                            
#> [101] "ants.joint_fusion"                          
#> [102] "ants.kelly_kapowski"                        
#> [103] "ants.label_geometry"                        
#> [104] "ants.laplacian_thickness"                   
#> [105] "ants.measure_image_similarity"              
#> [106] "ants.multiply_images"                       
#> [107] "ants.n4_bias_field_correction"              
#> [108] "ants.registration_syn_quick"                
#> [109] "ants.registration"                          
#> [110] "ants.resample_image_by_spacing"             
#> [111] "ants.threshold_image"                       
#> [112] "ants.transform_build"                       
#> [113] "ants.warp_image_multi_transform"            
#> [114] "ants.warp_time_series_image_multi_transform"
#> [115] "dcm2niix.convert"                           
#> [116] "fastsurfer.run"                             
#> [117] "fastsurfer.segment"                         
#> [118] "freesurfer.add_x_form_to_header"            
#> [119] "freesurfer.aparc2_aseg"                     
#> [120] "freesurfer.apas2_aseg"                      
#> [121] "freesurfer.apply_mask"                      
#> [122] "freesurfer.apply_vol_transform"             
#> [123] "freesurfer.bb_register"                     
#> [124] "freesurfer.binarize"                        
#> [125] "freesurfer.ca_label"                        
#> [126] "freesurfer.ca_normalize"                    
#> [127] "freesurfer.ca_register"                     
#> [128] "freesurfer.check_talairach_alignment"       
#> [129] "freesurfer.concatenate_lta"                 
#> [130] "freesurfer.concatenate"                     
#> [131] "freesurfer.contrast"                        
#> [132] "freesurfer.curvature_stats"                 
#> [133] "freesurfer.curvature"                       
#> [134] "freesurfer.dicom_convert"                   
#> [135] "freesurfer.edit_w_mwith_aseg"               
#> [136] "freesurfer.em_register"                     
#> [137] "freesurfer.euler_number"                    
#> [138] "freesurfer.extract_main_component"          
#> [139] "freesurfer.fit_ms_params"                   
#> [140] "freesurfer.fix_topology"                    
#> [141] "freesurfer.fuse_segmentations"              
#> [142] "freesurfer.glm_fit"                         
#> [143] "freesurfer.gtm_seg"                         
#> [144] "freesurfer.gtmpvc"                          
#> [145] "freesurfer.image_info"                      
#> [146] "freesurfer.jacobian"                        
#> [147] "freesurfer.label2_annot"                    
#> [148] "freesurfer.label2_label"                    
#> [149] "freesurfer.label2_vol"                      
#> [150] "freesurfer.logan"                           
#> [151] "freesurfer.lta_convert"                     
#> [152] "freesurfer.make_average_subject"            
#> [153] "freesurfer.make_surfaces"                   
#> [154] "freesurfer.mni_bias_correction"             
#> [155] "freesurfer.mp_rto_mni305"                   
#> [156] "freesurfer.mr_is_ca_label"                  
#> [157] "freesurfer.mr_is_calc"                      
#> [158] "freesurfer.mr_is_combine"                   
#> [159] "freesurfer.mr_is_convert"                   
#> [160] "freesurfer.mr_is_expand"                    
#> [161] "freesurfer.mr_is_inflate"                   
#> [162] "freesurfer.mri_convert"                     
#> [163] "freesurfer.mri_coreg"                       
#> [164] "freesurfer.mri_fill"                        
#> [165] "freesurfer.mri_marching_cubes"              
#> [166] "freesurfer.mri_pretess"                     
#> [167] "freesurfer.mri_tessellate"                  
#> [168] "freesurfer.mris_preproc_recon_all"          
#> [169] "freesurfer.mris_preproc"                    
#> [170] "freesurfer.mrtm1"                           
#> [171] "freesurfer.mrtm2"                           
#> [172] "freesurfer.ms_lda"                          
#> [173] "freesurfer.normalize"                       
#> [174] "freesurfer.one_sample_t_test"               
#> [175] "freesurfer.paint"                           
#> [176] "freesurfer.parcellation_stats"              
#> [177] "freesurfer.parse_dicom_dir"                 
#> [178] "freesurfer.recon_all"                       
#> [179] "freesurfer.register_av_ito_talairach"       
#> [180] "freesurfer.register"                        
#> [181] "freesurfer.relabel_hypointensities"         
#> [182] "freesurfer.remove_intersection"             
#> [183] "freesurfer.remove_neck"                     
#> [184] "freesurfer.resample"                        
#> [185] "freesurfer.robust_register"                 
#> [186] "freesurfer.robust_template"                 
#> [187] "freesurfer.sample_to_surface"               
#> [188] "freesurfer.seg_stats_recon_all"             
#> [189] "freesurfer.seg_stats"                       
#> [190] "freesurfer.segment_cc"                      
#> [191] "freesurfer.segment_wm"                      
#> [192] "freesurfer.smooth_tessellation"             
#> [193] "freesurfer.smooth"                          
#> [194] "freesurfer.sphere"                          
#> [195] "freesurfer.spherical_average"               
#> [196] "freesurfer.surface_smooth"                  
#> [197] "freesurfer.surface_snapshots"               
#> [198] "freesurfer.surface_transform"               
#> [199] "freesurfer.surface2_vol_transform"          
#> [200] "freesurfer.synthesize_flash"                
#> [201] "freesurfer.synthmorph_apply"                
#> [202] "freesurfer.synthmorph_register"             
#> [203] "freesurfer.synthstrip"                      
#> [204] "freesurfer.talairach_avi"                   
#> [205] "freesurfer.talairach_qc"                    
#> [206] "freesurfer.tkregister2"                     
#> [207] "freesurfer.unpack_sdicom_dir"               
#> [208] "freesurfer.volume_mask"                     
#> [209] "freesurfer.watershed_skull_strip"           
#> [210] "fsl.apply_mask"                             
#> [211] "fsl.apply_topup"                            
#> [212] "fsl.apply_warp"                             
#> [213] "fsl.apply_xfm"                              
#> [214] "fsl.ar1_image"                              
#> [215] "fsl.av_scale"                               
#> [216] "fsl.b0_calc"                                
#> [217] "fsl.bedpostx5"                              
#> [218] "fsl.bet"                                    
#> [219] "fsl.binary_maths"                           
#> [220] "fsl.change_data_type"                       
#> [221] "fsl.cluster"                                
#> [222] "fsl.complex"                                
#> [223] "fsl.contrast_mgr"                           
#> [224] "fsl.convert_warp"                           
#> [225] "fsl.convert_xfm"                            
#> [226] "fsl.copy_geom"                              
#> [227] "fsl.dilate_image"                           
#> [228] "fsl.distance_map"                           
#> [229] "fsl.dti_fit"                                
#> [230] "fsl.dual_regression"                        
#> [231] "fsl.eddy_correct"                           
#> [232] "fsl.eddy_quad"                              
#> [233] "fsl.eddy"                                   
#> [234] "fsl.epi_de_warp"                            
#> [235] "fsl.epi_reg"                                
#> [236] "fsl.erode_image"                            
#> [237] "fsl.extract_roi"                            
#> [238] "fsl.fast"                                   
#> [239] "fsl.feat_model"                             
#> [240] "fsl.feat"                                   
#> [241] "fsl.filmgls"                                
#> [242] "fsl.filter_regressor"                       
#> [243] "fsl.find_the_biggest"                       
#> [244] "fsl.first"                                  
#> [245] "fsl.flameo"                                 
#> [246] "fsl.flirt"                                  
#> [247] "fsl.fnirt"                                  
#> [248] "fsl.fugue"                                  
#> [249] "fsl.glm"                                    
#> [250] "fsl.ica_aroma"                              
#> [251] "fsl.image_maths"                            
#> [252] "fsl.image_meants"                           
#> [253] "fsl.image_stats"                            
#> [254] "fsl.inv_warp"                               
#> [255] "fsl.isotropic_smooth"                       
#> [256] "fsl.make_dyadic_vectors"                    
#> [257] "fsl.maths_command"                          
#> [258] "fsl.max_image"                              
#> [259] "fsl.maxn_image"                             
#> [260] "fsl.mcflirt"                                
#> [261] "fsl.mean_image"                             
#> [262] "fsl.median_image"                           
#> [263] "fsl.melodic"                                
#> [264] "fsl.merge"                                  
#> [265] "fsl.min_image"                              
#> [266] "fsl.motion_outliers"                        
#> [267] "fsl.multi_image_maths"                      
#> [268] "fsl.overlay"                                
#> [269] "fsl.percentile_image"                       
#> [270] "fsl.plot_motion_params"                     
#> [271] "fsl.plot_time_series"                       
#> [272] "fsl.power_spectrum"                         
#> [273] "fsl.prelude"                                
#> [274] "fsl.prepare_fieldmap"                       
#> [275] "fsl.prob_track_x"                           
#> [276] "fsl.prob_track_x2"                          
#> [277] "fsl.proj_thresh"                            
#> [278] "fsl.randomise"                              
#> [279] "fsl.reorient2_std"                          
#> [280] "fsl.robust_fov"                             
#> [281] "fsl.sig_loss"                               
#> [282] "fsl.slice_timer"                            
#> [283] "fsl.slice"                                  
#> [284] "fsl.slicer"                                 
#> [285] "fsl.smm"                                    
#> [286] "fsl.smooth_estimate"                        
#> [287] "fsl.smooth"                                 
#> [288] "fsl.spatial_filter"                         
#> [289] "fsl.split"                                  
#> [290] "fsl.std_image"                              
#> [291] "fsl.susan"                                  
#> [292] "fsl.swap_dimensions"                        
#> [293] "fsl.temporal_filter"                        
#> [294] "fsl.text2_vest"                             
#> [295] "fsl.threshold"                              
#> [296] "fsl.topup"                                  
#> [297] "fsl.tract_skeleton"                         
#> [298] "fsl.unary_maths"                            
#> [299] "fsl.vec_reg"                                
#> [300] "fsl.vest2_text"                             
#> [301] "fsl.warp_points_from_std"                   
#> [302] "fsl.warp_points_to_std"                     
#> [303] "fsl.warp_points"                            
#> [304] "fsl.warp_utils"                             
#> [305] "fsl.x_fibres5"
```

Each spec is a JSON file under `inst/specs/`. You can inspect any spec
to see what inputs and outputs it defines:

``` r

spec <- ni_spec_read("fsl.bet")
spec
#> 
#> ── FSL BET ──
#> 
#> Command: `bet`
#> Spec version: 0.1.0
#> FSL BET wrapper for skull stripping
#> 
#> ── Inputs (20)
#> args (string) - Additional parameters to the command
#> center (list) - center of gravity in voxels
#> frac (double) - fractional intensity threshold
#> functional (flag) - apply to 4D fMRI data
#> in_file (file) [required] - input file to skull strip
#> mask (flag) - create binary mask image
#> mesh (flag) - generate a vtk mesh brain surface
#> no_output (flag) - Don't generate segmented output
#> out_file (file) - name of output skull stripped image
#> outline (flag) - create surface outline image
#> padding (flag) - improve BET if FOV is very small in Z (by temporarily padding
#> end slices)
#> radius (int) - head radius
#> reduce_bias (flag) - bias field and neck cleanup
#> remove_eyes (flag) - eye & optic nerve cleanup (can be useful in SIENA)
#> robust (flag) - robust brain centre estimation (iterates BET several times)
#> skull (flag) - create skull image
#> surfaces (flag) - run bet2 and then betsurf to get additional skull and scalp
#> surfaces (includes registrations)
#> t2_guided (file) - as with creating surfaces, when also feeding in
#> non-brain-extracted T2 (includes registrations)
#> threshold (flag) - apply thresholding to segmented brain image and mask
#> vertical_gradient (double) - vertical gradient in fractional intensity
#> threshold (-1, 1)
#> 
#> ── Outputs (1)
#> out_file (file)
```

## The core workflow

niflowr has three core objects that flow into each other:

1.  **`ni_spec`** — the tool interface definition (from JSON)
2.  **`ni_call`** — a spec bound to concrete parameter values
3.  **`ni_result`** — the execution output with runtime info and
    provenance

### Step 1: Build a call

[`ni_call()`](https://bbuchsbaum.github.io/niflowr/reference/ni_call.md)
binds parameter values to a spec. It validates inputs immediately —
required parameters, file existence, numeric ranges, mutual exclusion
constraints:

``` r

# This fails: frac must be between 0 and 1
ni_call("fsl.bet",
  in_file  = "/tmp/t1.nii.gz",
  out_file = "/tmp/brain.nii.gz",
  frac     = 1.5,
  .validate = FALSE  # skip file-exists check for this demo
)
#> 
#> ── ni_call: fsl.bet
#> Command: `bet /tmp/t1.nii.gz /tmp/brain.nii.gz -f 1.50`
#> 
#> ── Expected outputs
#> out_file: /tmp/brain.nii.gz
```

When inputs are valid, you get back a call object you can inspect:

``` r

call <- ni_call("fsl.bet",
  in_file  = "/tmp/t1.nii.gz",
  out_file = "/tmp/brain.nii.gz",
  frac     = 0.3,
  mask     = TRUE,
  .validate = FALSE
)
call
#> 
#> ── ni_call: fsl.bet
#> Command: `bet /tmp/t1.nii.gz /tmp/brain.nii.gz -f 0.30 -m`
#> 
#> ── Expected outputs
#> out_file: /tmp/brain.nii.gz
```

### Step 2: Inspect the command

Before running anything, you can see exactly what command would be
executed. niflowr never hides what it’s doing:

``` r

ni_cmd(call)
#> $command
#> [1] "bet"
#> 
#> $args
#> [1] "/tmp/t1.nii.gz"    "/tmp/brain.nii.gz" "-f"               
#> [4] "0.30"              "-m"               
#> 
#> $wd
#> NULL
#> 
#> $env
#> NULL
#> 
#> $engine
#> NULL
#> 
#> $profile
#> NULL
#> 
#> $stdout
#> NULL
#> 
#> $stderr
#> NULL
```

The `args` vector is what gets passed to
[`processx::run()`](http://processx.r-lib.org/reference/run.md) — each
element is a separate argument, never concatenated into a shell string.

### Step 3: Execute

[`ni_run()`](https://bbuchsbaum.github.io/niflowr/reference/ni_run.md)
runs the command and returns an `ni_result`:

``` r

result <- ni_run(call)
result
#> -- ni_result: fsl.bet [success] --
#> Exit status: 0
#> Duration: 12.3s
#>
#> -- Outputs --
#>   out_file: /tmp/brain.nii.gz
#>   mask_file: /tmp/brain.nii.gz_mask.nii.gz
```

### Dry-run mode

If you just want to preview the command without executing it, use
`dry_run = TRUE` or the shorthand
[`ni_dry_run()`](https://bbuchsbaum.github.io/niflowr/reference/ni_dry_run.md):

``` r

ni_dry_run("fsl.bet",
  in_file  = "/tmp/t1.nii.gz",
  out_file = "/tmp/brain.nii.gz",
  frac     = 0.5,
  .engine  = "native"
)
#> ℹ Dry run [native]: `bet /tmp/t1.nii.gz /tmp/brain.nii.gz -f 0.50`
#> 
#> ── Expected outputs
#> out_file: /tmp/brain.nii.gz
```

## Using the convenience wrappers

Every bundled spec has a corresponding wrapper function with typed
arguments and documentation. These are the recommended way to call
tools:

| Function | Tool |
|----|----|
| [`ni_fsl_bet()`](https://bbuchsbaum.github.io/niflowr/reference/ni_fsl_bet.md) | FSL BET (brain extraction) |
| [`ni_fsl_flirt()`](https://bbuchsbaum.github.io/niflowr/reference/ni_fsl_flirt.md) | FSL FLIRT (linear registration) |
| `ni_fsl_applywarp()` | FSL applywarp (apply warp fields) |
| `ni_afni_3dcalc()` | AFNI 3dcalc (voxelwise math) |
| `ni_afni_3dresample()` | AFNI 3dresample (reslicing) |
| [`ni_ants_registration()`](https://bbuchsbaum.github.io/niflowr/reference/ni_ants_registration.md) | ANTs registration (SyN) |
| [`ni_ants_apply_transforms()`](https://bbuchsbaum.github.io/niflowr/reference/ni_ants_apply_transforms.md) | ANTs antsApplyTransforms |
| [`ni_freesurfer_recon_all()`](https://bbuchsbaum.github.io/niflowr/reference/ni_freesurfer_recon_all.md) | FreeSurfer recon-all |
| [`ni_freesurfer_mri_convert()`](https://bbuchsbaum.github.io/niflowr/reference/ni_freesurfer_mri_convert.md) | FreeSurfer mri_convert |

Each wrapper calls
[`ni_call()`](https://bbuchsbaum.github.io/niflowr/reference/ni_call.md) +
[`ni_run()`](https://bbuchsbaum.github.io/niflowr/reference/ni_run.md)
internally, so you get the same validation, safe execution, and
provenance:

``` r

# Linear registration with FLIRT
result <- ni_fsl_flirt(
  in_file         = "func_mean.nii.gz",
  reference       = "MNI152_T1_2mm.nii.gz",
  out_file        = "func_mean_mni.nii.gz",
  out_matrix_file = "func2mni.mat",
  dof             = 12,
  cost            = "corratio"
)
```

## Provenance

Every successful run writes a JSON sidecar next to the primary output.
This records the exact command, arguments, timing, and (optionally)
input file hashes:

``` r

# After running bet...
prov <- ni_provenance(result)
prov$command
#> [1] "bet"
prov$args
#> [1] "/data/sub-01_T1w.nii.gz" "/data/sub-01_brain.nii.gz" "-f" "0.5" "-m"
prov$duration_secs
#> [1] 12.3

# Or read a sidecar from disk
ni_provenance_read("sub-01_brain_provenance.json")
```

## Container support

niflowr can run tools inside Docker or Apptainer containers. Container
execution is profile-driven via `niflowr.yml`, with stable container
paths (`/in`, `/out`, `/work`):

``` r

# Configure once per project (or rely on automatic niflowr.yml discovery):
ni_config(config_file = "niflowr.yml")

result <- ni_fsl_bet(
  in_file    = "/data/t1.nii.gz",
  out_file   = "/data/brain.nii.gz",
  .engine    = "auto",   # native first, then container fallback by runtime.prefer
  .profile   = "fsl"     # maps to profiles.fsl in niflowr.yml
)
# Runs natively if `bet` exists; otherwise uses configured container backend.
```

Wrappers always accept host paths; path mapping into container paths is
handled inside
[`ni_run()`](https://bbuchsbaum.github.io/niflowr/reference/ni_run.md).

### FastSurfer: GPU-accelerated segmentation

niflowr includes specs for
[FastSurfer](https://deep-mi.org/research/fastsurfer/), a
GPU-accelerated alternative to FreeSurfer that runs brain segmentation
in ~5 minutes. FastSurfer runs primarily via container, so configure a
profile in `niflowr.yml`:

``` yaml
profiles:
  fastsurfer:
    docker_image: "deepmi/fastsurfer:cpu-v2.4.2"
    apptainer_uri: "docker://deepmi/fastsurfer:cpu-v2.4.2"
```

Then call the wrapper:

``` r

# Full pipeline: segmentation + surface reconstruction
result <- ni_fastsurfer_run(
  t1     = "sub-01_T1w.nii.gz",
  sid    = "sub-01",
  sd     = "derivatives/fastsurfer",
  device = "cuda",
  .engine = "docker"
)

# Segmentation only (~5 min)
seg <- ni_fastsurfer_segment(
  t1     = "sub-01_T1w.nii.gz",
  sid    = "sub-01",
  sd     = "derivatives/fastsurfer",
  device = "cpu"
)
ni_outputs(seg)
#> $seg_file
#> [1] "derivatives/fastsurfer/sub-01/mri/aparc.DKTatlas+aseg.deep.mgz"
#> $mask_file
#> [1] "derivatives/fastsurfer/sub-01/mri/mask.mgz"
```

### Runtime diagnostics with `ni_doctor()`

Use
[`ni_doctor()`](https://bbuchsbaum.github.io/niflowr/reference/ni_doctor.md)
to check runtime binaries, mounted roots, profile definitions, and
lockfile consistency:

``` r

report <- ni_doctor()
report

# Strict mode errors on failures:
ni_doctor(strict = TRUE)
```

### Pinning and validating lockfiles

Use
[`ni_pin()`](https://bbuchsbaum.github.io/niflowr/reference/ni_pin.md)
to create/update a lockfile with resolved runtime references for
configured profiles, and
[`ni_lock_validate()`](https://bbuchsbaum.github.io/niflowr/reference/ni_lock_validate.md)
to verify current config matches the lock:

``` r

# Create/update lockfile (default: runtime.lockfile or niflowr.lock.yml)
lock <- ni_pin()

# Validate current config against lockfile
checks <- ni_lock_validate()
checks
```

### Lock enforcement during execution

Enable lock enforcement to ensure containerized runs use lockfile-pinned
references:

``` r

ni_config(config = list(
  runtime = list(
    lockfile = "niflowr.lock.yml",
    lock_enforce = TRUE
  )
))

# When lock_enforce = TRUE, ni_run() resolves container refs from the lockfile
# for the selected profile and errors if lock constraints are violated.
result <- ni_fsl_bet(
  in_file  = "/data/t1.nii.gz",
  out_file = "/data/brain.nii.gz",
  .engine  = "docker",
  .profile = "fsl"
)
```

## Ecosystem integration

niflowr is designed to work with three companion packages:

### neuroim2 — read outputs as R objects

After running a tool, load its output directly into a neuroim2
`NeuroVol` or `NeuroVec`:

``` r

result <- ni_fsl_bet(in_file = "t1.nii.gz", out_file = "brain.nii.gz")
brain <- ni_read_output(result, "out_file")
# Returns a NeuroVol — you can slice, plot, do math on it
```

### neurotransform — work with spatial transforms

Registration outputs can be loaded as neurotransform morphism objects
for composition and resampling:

``` r

reg <- ni_fsl_flirt(
  in_file = "func.nii.gz", reference = "t1.nii.gz",
  out_file = "func_t1.nii.gz", out_matrix_file = "func2t1.mat"
)
xfm <- ni_read_transform(reg, "out_matrix_file")
# Returns an Affine3DMorphism — compose, invert, resample with it
```

### bidser — BIDS-aware input discovery

Query a BIDS dataset for inputs and generate derivatives-style output
paths:

``` r

library(bidser)
proj <- bids_project("/data/bids")

# Find T1w images for a subject
inputs <- ni_bids_inputs(proj, "fsl.bet", subid = "01", modality = "T1w")

# Generate a BIDS-derivatives output path
ni_deriv_path(inputs$path[1], desc = "brain", suffix = "T1w")
#> [1] "derivatives/niflowr/sub-01/anat/sub-01_desc-brain_T1w.nii.gz"
```

## Building pipelines with {targets}

For multi-step pipelines, niflowr integrates with {targets} for
DAG-based execution with caching and parallelism. The key idea: niflowr
handles the *interface layer*, {targets} handles the *execution layer*.

### Using `ni_run_files()` in targets

The simplest pattern uses
[`ni_run_files()`](https://bbuchsbaum.github.io/niflowr/reference/ni_run_files.md),
which returns output paths suitable for `format = "file"` targets:

``` r

# _targets.R
library(targets)
library(niflowr)

list(
  tar_target(
    brain,
    ni_run_files("fsl.bet",
      in_file  = "data/sub-01_T1w.nii.gz",
      out_file = "derivatives/sub-01_desc-brain_T1w.nii.gz",
      frac = 0.5
    ),
    format = "file"
  )
)
```

### Using `tar_ni_step()` for less boilerplate

The
[`tar_ni_step()`](https://bbuchsbaum.github.io/niflowr/reference/tar_ni_step.md)
target factory wraps this pattern:

``` r

list(
  tar_ni_step(brain, "fsl.bet",
    in_file  = "data/sub-01_T1w.nii.gz",
    out_file = "derivatives/sub-01_desc-brain_T1w.nii.gz",
    frac = 0.5
  )
)
```

### Dynamic branching over subjects

Process multiple subjects in parallel with {targets} dynamic branching
and {crew} workers:

``` r

library(targets)
library(crew)
library(niflowr)
library(bidser)

tar_option_set(
  packages = c("niflowr", "bidser"),
  controller = crew_controller_local(workers = 8)
)

list(
  tar_target(bids, bidser::bids_project("data/bids")),

  tar_target(t1w_files,
    bidser::search_files(bids, regex = "_T1w\\.nii", full_path = TRUE)
  ),

  tar_target(brain, {
    out <- ni_deriv_path(t1w_files, desc = "brain")
    ni_run_files("fsl.bet", in_file = t1w_files, out_file = out, frac = 0.5)
  }, pattern = map(t1w_files), format = "file")
)
```

{targets} skips subjects whose outputs are already up to date, and
{crew} distributes the work across 8 parallel workers.

## Writing your own specs

You can write specs for any command-line tool. The
[`vignette("extending-niflowr")`](https://bbuchsbaum.github.io/niflowr/articles/extending-niflowr.md)
vignette walks through the full loop (spec → lint → wrapper → golden →
test) using SynthStrip as a worked example. The short version: create a
JSON file following the schema at `inst/schema/niflowr-spec-0.1.0.json`:

``` json
{
  "spec_version": "0.1.0",
  "id": "my.tool",
  "title": "My Custom Tool",
  "command": "mytool",
  "inputs": {
    "in_file": {
      "type": "file",
      "required": true,
      "validate": { "exists": true },
      "cli": { "argstr": "--input %s" }
    },
    "threshold": {
      "type": "double",
      "validate": { "min": 0, "max": 1 },
      "cli": { "argstr": "--thresh %g" }
    }
  },
  "outputs": {
    "out_file": {
      "type": "file",
      "path": { "template": "{in_file}_processed.nii.gz" },
      "must_exist": true
    }
  }
}
```

Load it by path:

``` r

spec <- ni_spec_read("/path/to/my.tool.json")
result <- ni_run(ni_call(spec, in_file = "data.nii.gz", threshold = 0.5))
```

## Next steps

- Browse the bundled specs with
  [`ni_spec_list()`](https://bbuchsbaum.github.io/niflowr/reference/ni_spec_list.md)
  and
  [`ni_spec_read()`](https://bbuchsbaum.github.io/niflowr/reference/ni_spec_read.md)
  to see how real interfaces are defined
- See
  [`?ni_call`](https://bbuchsbaum.github.io/niflowr/reference/ni_call.md)
  for the full set of validation and constraint options
- See
  [`?ni_run`](https://bbuchsbaum.github.io/niflowr/reference/ni_run.md)
  for execution options (echo, provenance, container)
- See
  [`?tar_ni_step`](https://bbuchsbaum.github.io/niflowr/reference/tar_ni_step.md)
  for {targets} integration details
- See
  [`?ni_read_output`](https://bbuchsbaum.github.io/niflowr/reference/ni_read_output.md)
  and
  [`?ni_read_transform`](https://bbuchsbaum.github.io/niflowr/reference/ni_read_transform.md)
  for ecosystem helpers
