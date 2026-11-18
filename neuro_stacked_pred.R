## library path
.libPaths(new =  "/home/wanyu368/R/foss-2023a/4.3"  )
#for parallel processing

library(tidymodels)
library(tidyverse)
library("sva")
library(future)
library(finetune)



options(future.globals.maxSize = Inf)
plan(future.callr::callr, workers = 15,gc = TRUE)


datafolder <- "/Volumes/sci-psy-narun/Nesi/Yue/ABCD_7.0_growth/"

#neuro_gi_tune

source(paste0(datafolder,"r_functions_7.0.R"))

subj_n_site <-  c("participant_id","ab_g_dyn__design_site")   

gi_set <- "neuro_gi_stack/"
gs_set <- "neuro_gs_stack/"
all_set <- "neuro_all"
dti_set <- "neuro_dmri"
rsmri_set <- "neuro_rsmri"
smri_set <- "neuro_smri"
tfmri_set <- "neuro_tfmri"




for(batch_idx in 1:21){
  #batch_idx <- 1
  
  gi_tuned_list <- readRDS(paste0(datafolder,gi_set ,all_set, ".",batch_idx,".RDS" ))
  
  gs_tuned_list <- readRDS(paste0(datafolder, gs_set ,all_set, ".",batch_idx,".RDS" ))
  
  xgboost_gi_pred <- xgb_final_fit(recipe_input =gi_tuned_list[["recipe_gi"]] , 
                                     wf_input =gi_tuned_list[["xgboost_gi"]],
                                     test_input =gi_tuned_list[["gi_test_select"]] ,
                                     test_data_all =gi_tuned_list[["test_gi"]],
                                     resp_input = "gi")
  
  
  
  xgboost_gs_pred <- xgb_final_fit(recipe_input =gs_tuned_list[["recipe_gs"]], 
                                   wf_input =gs_tuned_list [["xgboost_gs"]],
                                   test_input = gs_tuned_list [["gs_test_select"]],
                                   test_data_all = gs_tuned_list[["test_gs"]],
                                   resp_input = "gs")
  
  
  
  
  xgboost_gi_pred_train <- xgb_final_fit(recipe_input = gi_tuned_list[["recipe_gi"]], 
                                           wf_input =  gi_tuned_list[["xgboost_gi"]],
                                           test_input = gi_tuned_list[["gi_train_select"]],
                                           test_data_all = gi_tuned_list[["train_gi"]],
                                           resp_input = "gi")
  
  
  
  xgboost_gs_pred_train <- xgb_final_fit(recipe_input = gs_tuned_list [["recipe_gs"]], 
                                         wf_input = gs_tuned_list [["xgboost_gs"]],
                                         test_input = gs_tuned_list [["gs_train_select"]],
                                         test_data_all = gs_tuned_list [["train_gs"]],
                                         resp_input = "gs")
  
  
  output_list <- list(xgboost_gs =gs_tuned_list [["xgboost_gs"]],
                      xgboost_gi =gi_tuned_list [["xgboost_gi"]],
                      xgboost_gs_pred = xgboost_gs_pred,
                      xgboost_gi_pred=xgboost_gi_pred,
                      xgboost_gi_pred_train=xgboost_gi_pred_train,
                      xgboost_gs_pred_train = xgboost_gs_pred_train,
                      train_gi =gi_tuned_list [["train_gi"]],
                      train_gs =gs_tuned_list[["train_gs"]] ,
                      test_gi= gi_tuned_list[["test_gi"]],
                      test_gs=gs_tuned_list[["test_gs"]])
  
  saveRDS(output_list, paste0(datafolder, "xgb_results/" ,"stacked_neuro_all", ".",batch_idx,".RDS" ))
  
  gc()
}


for(batch_idx in 1:21){
  gi_tuned_list <- readRDS(paste0(datafolder,gi_set ,dti_set, ".",batch_idx,".RDS" ))
  
  gs_tuned_list <- readRDS(paste0(datafolder, gs_set ,dti_set, ".",batch_idx,".RDS" ))
  
  xgboost_gi_pred <- xgb_final_fit(recipe_input =gi_tuned_list[["recipe_gi"]] , 
                                   wf_input =gi_tuned_list[["xgboost_gi"]],
                                   test_input =gi_tuned_list[["gi_test_select"]] ,
                                   test_data_all =gi_tuned_list[["test_gi"]],
                                   resp_input = "gi")
  
  
  
  xgboost_gs_pred <- xgb_final_fit(recipe_input =gs_tuned_list[["recipe_gs"]], 
                                   wf_input =gs_tuned_list [["xgboost_gs"]],
                                   test_input = gs_tuned_list [["gs_test_select"]],
                                   test_data_all = gs_tuned_list[["test_gs"]],
                                   resp_input = "gs")
  
  
  
  
  xgboost_gi_pred_train <- xgb_final_fit(recipe_input = gi_tuned_list[["recipe_gi"]], 
                                         wf_input =  gi_tuned_list[["xgboost_gi"]],
                                         test_input = gi_tuned_list[["gi_train_select"]],
                                         test_data_all = gi_tuned_list[["train_gi"]],
                                         resp_input = "gi")
  
  
  
  xgboost_gs_pred_train <- xgb_final_fit(recipe_input = gs_tuned_list [["recipe_gs"]], 
                                         wf_input = gs_tuned_list [["xgboost_gs"]],
                                         test_input = gs_tuned_list [["gs_train_select"]],
                                         test_data_all = gs_tuned_list [["train_gs"]],
                                         resp_input = "gs")
  
  
  output_list <- list(xgboost_gs =gs_tuned_list [["xgboost_gs"]],
                      xgboost_gi =gi_tuned_list [["xgboost_gi"]],
                      xgboost_gs_pred = xgboost_gs_pred,
                      xgboost_gi_pred=xgboost_gi_pred,
                      xgboost_gi_pred_train=xgboost_gi_pred_train,
                      xgboost_gs_pred_train = xgboost_gs_pred_train,
                      train_gi =gi_tuned_list [["train_gi"]],
                      train_gs =gs_tuned_list[["train_gs"]] ,
                      test_gi= gi_tuned_list[["test_gi"]],
                      test_gs=gs_tuned_list[["test_gs"]])
  
  saveRDS(output_list, paste0(datafolder, "xgb_results/" ,"stacked_neuro_dmri", ".",batch_idx,".RDS" ))
  
  gc()
}






for(batch_idx in 1:21){
  gi_tuned_list <- readRDS(paste0(datafolder,gi_set ,rsmri_set, ".",batch_idx,".RDS" ))
  
  gs_tuned_list <- readRDS(paste0(datafolder, gs_set ,rsmri_set, ".",batch_idx,".RDS" ))
  
  xgboost_gi_pred <- xgb_final_fit(recipe_input =gi_tuned_list[["recipe_gi"]] , 
                                   wf_input =gi_tuned_list[["xgboost_gi"]],
                                   test_input =gi_tuned_list[["gi_test_select"]] ,
                                   test_data_all =gi_tuned_list[["test_gi"]],
                                   resp_input = "gi")
  
  
  
  xgboost_gs_pred <- xgb_final_fit(recipe_input =gs_tuned_list[["recipe_gs"]], 
                                   wf_input =gs_tuned_list [["xgboost_gs"]],
                                   test_input = gs_tuned_list [["gs_test_select"]],
                                   test_data_all = gs_tuned_list[["test_gs"]],
                                   resp_input = "gs")
  
  
  
  
  xgboost_gi_pred_train <- xgb_final_fit(recipe_input = gi_tuned_list[["recipe_gi"]], 
                                         wf_input =  gi_tuned_list[["xgboost_gi"]],
                                         test_input = gi_tuned_list[["gi_train_select"]],
                                         test_data_all = gi_tuned_list[["train_gi"]],
                                         resp_input = "gi")
  
  
  
  xgboost_gs_pred_train <- xgb_final_fit(recipe_input = gs_tuned_list [["recipe_gs"]], 
                                         wf_input = gs_tuned_list [["xgboost_gs"]],
                                         test_input = gs_tuned_list [["gs_train_select"]],
                                         test_data_all = gs_tuned_list [["train_gs"]],
                                         resp_input = "gs")
  
  
  output_list <- list(xgboost_gs =gs_tuned_list [["xgboost_gs"]],
                      xgboost_gi =gi_tuned_list [["xgboost_gi"]],
                      xgboost_gs_pred = xgboost_gs_pred,
                      xgboost_gi_pred=xgboost_gi_pred,
                      xgboost_gi_pred_train=xgboost_gi_pred_train,
                      xgboost_gs_pred_train = xgboost_gs_pred_train,
                      train_gi =gi_tuned_list [["train_gi"]],
                      train_gs =gs_tuned_list[["train_gs"]] ,
                      test_gi= gi_tuned_list[["test_gi"]],
                      test_gs=gs_tuned_list[["test_gs"]])
  
  saveRDS(output_list, paste0(datafolder, "xgb_results/" ,"stacked_neuro_rsmri", ".",batch_idx,".RDS" ))
  
  gc()
}


for(batch_idx in 1:21){
  gi_tuned_list <- readRDS(paste0(datafolder,gi_set ,smri_set, ".",batch_idx,".RDS" ))
  
  gs_tuned_list <- readRDS(paste0(datafolder, gs_set ,smri_set, ".",batch_idx,".RDS" ))
  
  xgboost_gi_pred <- xgb_final_fit(recipe_input =gi_tuned_list[["recipe_gi"]] , 
                                   wf_input =gi_tuned_list[["xgboost_gi"]],
                                   test_input =gi_tuned_list[["gi_test_select"]] ,
                                   test_data_all =gi_tuned_list[["test_gi"]],
                                   resp_input = "gi")
  
  
  
  xgboost_gs_pred <- xgb_final_fit(recipe_input =gs_tuned_list[["recipe_gs"]], 
                                   wf_input =gs_tuned_list [["xgboost_gs"]],
                                   test_input = gs_tuned_list [["gs_test_select"]],
                                   test_data_all = gs_tuned_list[["test_gs"]],
                                   resp_input = "gs")
  
  
  
  
  xgboost_gi_pred_train <- xgb_final_fit(recipe_input = gi_tuned_list[["recipe_gi"]], 
                                         wf_input =  gi_tuned_list[["xgboost_gi"]],
                                         test_input = gi_tuned_list[["gi_train_select"]],
                                         test_data_all = gi_tuned_list[["train_gi"]],
                                         resp_input = "gi")
  
  
  
  xgboost_gs_pred_train <- xgb_final_fit(recipe_input = gs_tuned_list [["recipe_gs"]], 
                                         wf_input = gs_tuned_list [["xgboost_gs"]],
                                         test_input = gs_tuned_list [["gs_train_select"]],
                                         test_data_all = gs_tuned_list [["train_gs"]],
                                         resp_input = "gs")
  
  
  output_list <- list(xgboost_gs =gs_tuned_list [["xgboost_gs"]],
                      xgboost_gi =gi_tuned_list [["xgboost_gi"]],
                      xgboost_gs_pred = xgboost_gs_pred,
                      xgboost_gi_pred=xgboost_gi_pred,
                      xgboost_gi_pred_train=xgboost_gi_pred_train,
                      xgboost_gs_pred_train = xgboost_gs_pred_train,
                      train_gi =gi_tuned_list [["train_gi"]],
                      train_gs =gs_tuned_list[["train_gs"]] ,
                      test_gi= gi_tuned_list[["test_gi"]],
                      test_gs=gs_tuned_list[["test_gs"]])
  
  saveRDS(output_list, paste0(datafolder, "xgb_results/" ,"stacked_neuro_smri", ".",batch_idx,".RDS" ))
  
  gc()
}


for(batch_idx in 1:21){
  gi_tuned_list <- readRDS(paste0(datafolder,gi_set ,tfmri_set, ".",batch_idx,".RDS" ))
  
  gs_tuned_list <- readRDS(paste0(datafolder, gs_set ,tfmri_set, ".",batch_idx,".RDS" ))
  
  xgboost_gi_pred <- xgb_final_fit(recipe_input =gi_tuned_list[["recipe_gi"]] , 
                                   wf_input =gi_tuned_list[["xgboost_gi"]],
                                   test_input =gi_tuned_list[["gi_test_select"]] ,
                                   test_data_all =gi_tuned_list[["test_gi"]],
                                   resp_input = "gi")
  
  
  
  xgboost_gs_pred <- xgb_final_fit(recipe_input =gs_tuned_list[["recipe_gs"]], 
                                   wf_input =gs_tuned_list [["xgboost_gs"]],
                                   test_input = gs_tuned_list [["gs_test_select"]],
                                   test_data_all = gs_tuned_list[["test_gs"]],
                                   resp_input = "gs")
  
  
  
  
  xgboost_gi_pred_train <- xgb_final_fit(recipe_input = gi_tuned_list[["recipe_gi"]], 
                                         wf_input =  gi_tuned_list[["xgboost_gi"]],
                                         test_input = gi_tuned_list[["gi_train_select"]],
                                         test_data_all = gi_tuned_list[["train_gi"]],
                                         resp_input = "gi")
  
  
  
  xgboost_gs_pred_train <- xgb_final_fit(recipe_input = gs_tuned_list [["recipe_gs"]], 
                                         wf_input = gs_tuned_list [["xgboost_gs"]],
                                         test_input = gs_tuned_list [["gs_train_select"]],
                                         test_data_all = gs_tuned_list [["train_gs"]],
                                         resp_input = "gs")
  
  
  output_list <- list(xgboost_gs =gs_tuned_list [["xgboost_gs"]],
                      xgboost_gi =gi_tuned_list [["xgboost_gi"]],
                      xgboost_gs_pred = xgboost_gs_pred,
                      xgboost_gi_pred=xgboost_gi_pred,
                      xgboost_gi_pred_train=xgboost_gi_pred_train,
                      xgboost_gs_pred_train = xgboost_gs_pred_train,
                      train_gi =gi_tuned_list [["train_gi"]],
                      train_gs =gs_tuned_list[["train_gs"]] ,
                      test_gi= gi_tuned_list[["test_gi"]],
                      test_gs=gs_tuned_list[["test_gs"]])
  
  saveRDS(output_list, paste0(datafolder, "xgb_results/" ,"stacked_neuro_tfmri", ".",batch_idx,".RDS" ))
  
  gc()
}



subj_site <- c("participant_id","ab_g_dyn__design_site" ) 

neuro_nonneuro_set <- "neuro_nonneuro_all"




for(batch_idx in 1:21){
  gi_tuned_list <- readRDS(paste0(datafolder,gi_set ,neuro_nonneuro_set, ".",batch_idx,".RDS" ))
  
  gs_tuned_list <- readRDS(paste0(datafolder, gs_set ,neuro_nonneuro_set, ".",batch_idx,".RDS" ))
  
  
  xgboost_gi_pred <- xgb_final_fit_nominal(wf_input=gi_tuned_list[["xgboost_gi"]],
                                           test_input = gi_tuned_list[["gi_test_select"]],
                                           test_data_all = gi_tuned_list[["test_gi"]],
                                           resp_input = "gi",
                                           train_input = gi_tuned_list[["gi_train_select"]])
  
  
  
  xgboost_gs_pred <- xgb_final_fit_nominal(wf_input=gs_tuned_list[["xgboost_gs"]],
                                           test_input = gs_tuned_list[["gs_test_select"]],
                                           test_data_all = gs_tuned_list[["test_gs"]],
                                           resp_input = "gs",
                                           train_input = gs_tuned_list[["gs_train_select"]])
  
  
  xgboost_gi_pred_train <- xgb_final_fit_nominal(wf_input=gi_tuned_list[["xgboost_gi"]],
                                         test_input = gi_tuned_list[["gi_train_select"]],
                                         test_data_all = gi_tuned_list[["train_gi"]],
                                         resp_input = "gi",
                                         train_input = gi_tuned_list[["gi_train_select"]])
  
  
  
  xgboost_gs_pred_train <- xgb_final_fit_nominal(wf_input=gs_tuned_list[["xgboost_gs"]],
                                         test_input = gs_tuned_list[["gs_train_select"]],
                                         test_data_all = gs_tuned_list[["train_gs"]],
                                         resp_input = "gs",
                                         train_input = gs_tuned_list[["gs_train_select"]])
  
  
  output_list <- list(xgboost_gs =gs_tuned_list [["xgboost_gs"]],
                      xgboost_gi =gi_tuned_list [["xgboost_gi"]],
                      xgboost_gs_pred = xgboost_gs_pred,
                      xgboost_gi_pred=xgboost_gi_pred,
                      xgboost_gi_pred_train=xgboost_gi_pred_train,
                      xgboost_gs_pred_train = xgboost_gs_pred_train,
                      train_gi =gi_tuned_list [["train_gi"]],
                      train_gs =gs_tuned_list[["train_gs"]] ,
                      test_gi= gi_tuned_list[["test_gi"]],
                      test_gs=gs_tuned_list[["test_gs"]])
  
  saveRDS(output_list, paste0(datafolder, "xgb_results/" ,"stacked_neuro_nonneuro", ".",batch_idx,".RDS" ))
 
  
  }




nonneuro_set <- "nonneuro_all"

for(batch_idx in 1:21){
  

  
  gi_tuned_list <- readRDS(paste0(datafolder,gi_set ,nonneuro_set, ".",batch_idx,".RDS" ))
  
  gs_tuned_list <- readRDS(paste0(datafolder, gs_set ,nonneuro_set, ".",batch_idx,".RDS" ))
  
  
  xgboost_gi_pred <- xgb_final_fit_nominal(wf_input=gi_tuned_list[["xgboost_gi"]],
                                           test_input = gi_tuned_list[["gi_test_select"]],
                                           test_data_all = gi_tuned_list[["test_gi"]],
                                           resp_input = "gi",
                                           train_input = gi_tuned_list[["gi_train_select"]])
  
  
  
  xgboost_gs_pred <- xgb_final_fit_nominal(wf_input=gs_tuned_list[["xgboost_gs"]],
                                           test_input = gs_tuned_list[["gs_test_select"]],
                                           test_data_all = gs_tuned_list[["test_gs"]],
                                           resp_input = "gs",
                                           train_input = gs_tuned_list[["gs_train_select"]])
  
  
  xgboost_gi_pred_train <- xgb_final_fit_nominal(wf_input=gi_tuned_list[["xgboost_gi"]],
                                                 test_input = gi_tuned_list[["gi_train_select"]],
                                                 test_data_all = gi_tuned_list[["train_gi"]],
                                                 resp_input = "gi",
                                                 train_input = gi_tuned_list[["gi_train_select"]])
  
  
  
  xgboost_gs_pred_train <- xgb_final_fit_nominal(wf_input=gs_tuned_list[["xgboost_gs"]],
                                                 test_input = gs_tuned_list[["gs_train_select"]],
                                                 test_data_all = gs_tuned_list[["train_gs"]],
                                                 resp_input = "gs",
                                                 train_input = gs_tuned_list[["gs_train_select"]])
  
  
  output_list <- list(xgboost_gs =gs_tuned_list [["xgboost_gs"]],
                      xgboost_gi =gi_tuned_list [["xgboost_gi"]],
                      xgboost_gs_pred = xgboost_gs_pred,
                      xgboost_gi_pred=xgboost_gi_pred,
                      xgboost_gi_pred_train=xgboost_gi_pred_train,
                      xgboost_gs_pred_train = xgboost_gs_pred_train,
                      train_gi =gi_tuned_list [["train_gi"]],
                      train_gs =gs_tuned_list[["train_gs"]] ,
                      test_gi= gi_tuned_list[["test_gi"]],
                      test_gs=gs_tuned_list[["test_gs"]])
  
  saveRDS(output_list, paste0(datafolder, "xgb_results/" ,"stacked_nonneuro", ".",batch_idx,".RDS" ))
}
