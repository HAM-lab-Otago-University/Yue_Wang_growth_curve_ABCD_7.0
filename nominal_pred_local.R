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

source(paste0(datafolder,"r_functions_7.0.R"))
subj_info <- c("participant_id","ab_g_dyn__design_site","fold")
subj_site <- c("participant_id","ab_g_dyn__design_site")


data_name <- "su_all"
for(batch_idx in seq(1:21)){
#batch_idx <- 1

gi_tuned_list <- readRDS(paste0(datafolder, "neuro_gi_stack/" ,data_name, ".",batch_idx,".RDS" ))

gs_tuned_list <- readRDS(paste0(datafolder, "neuro_gs_stack/" ,data_name, ".",batch_idx,".RDS" ))


xgboost_gi_pred <- xgb_final_fit_nominal(wf_input=gi_tuned_list[["xgboost_gi"]],
                                         test_input = gi_tuned_list[["gi_test_select"]] ,
                                         test_data_all = gi_tuned_list[["test_gi"]],
                                         resp_input = "gi",
                                         train_input = gi_tuned_list[["gi_train_select"]])



xgboost_gs_pred <- xgb_final_fit_nominal(wf_input=gs_tuned_list[["xgboost_gs"]],
                                         test_input = gs_tuned_list[["gs_test_select"]] ,
                                         test_data_all = gs_tuned_list[["test_gs"]],
                                         resp_input = "gs",
                                         train_input = gs_tuned_list[["gs_train_select"]])


output_list <- list(xgboost_gs =gs_tuned_list [["xgboost_gs"]],
                    xgboost_gi =gi_tuned_list [["xgboost_gi"]],
                    xgboost_gs_pred = xgboost_gs_pred,
                    xgboost_gi_pred=xgboost_gi_pred,
                    train_gi =gi_tuned_list [["train_gi"]],
                    train_gs =gs_tuned_list[["train_gs"]] ,
                    test_gi= gi_tuned_list[["test_gi"]],
                    test_gs=gs_tuned_list[["test_gs"]])

saveRDS(output_list, paste0(datafolder, "xgb_results/" ,data_name, ".",batch_idx,".RDS" ))
}



data_name <- "culture_all"
for(batch_idx in seq(1:21)){
  #batch_idx <- 1
  
  gi_tuned_list <- readRDS(paste0(datafolder, "neuro_gi_stack/" ,data_name, ".",batch_idx,".RDS" ))
  
  gs_tuned_list <- readRDS(paste0(datafolder, "neuro_gs_stack/" ,data_name, ".",batch_idx,".RDS" ))
  
  
  xgboost_gi_pred <- xgb_final_fit_nominal(wf_input=gi_tuned_list[["xgboost_gi"]],
                                           test_input = gi_tuned_list[["gi_test_select"]] ,
                                           test_data_all = gi_tuned_list[["test_gi"]],
                                           resp_input = "gi",
                                           train_input = gi_tuned_list[["gi_train_select"]])
  
  
  
  xgboost_gs_pred <- xgb_final_fit_nominal(wf_input=gs_tuned_list[["xgboost_gs"]],
                                           test_input = gs_tuned_list[["gs_test_select"]] ,
                                           test_data_all = gs_tuned_list[["test_gs"]],
                                           resp_input = "gs",
                                           train_input = gs_tuned_list[["gs_train_select"]])
  
  
  output_list <- list(xgboost_gs =gs_tuned_list [["xgboost_gs"]],
                      xgboost_gi =gi_tuned_list [["xgboost_gi"]],
                      xgboost_gs_pred = xgboost_gs_pred,
                      xgboost_gi_pred=xgboost_gi_pred,
                      train_gi =gi_tuned_list [["train_gi"]],
                      train_gs =gs_tuned_list[["train_gs"]] ,
                      test_gi= gi_tuned_list[["test_gi"]],
                      test_gs=gs_tuned_list[["test_gs"]])
  
  saveRDS(output_list, paste0(datafolder, "xgb_results/" ,data_name, ".",batch_idx,".RDS" ))
}


data_name <- "envi_nei_all"
for(batch_idx in seq(1:21)){
  #batch_idx <- 1
  
  gi_tuned_list <- readRDS(paste0(datafolder, "neuro_gi_stack/" ,data_name, ".",batch_idx,".RDS" ))
  
  gs_tuned_list <- readRDS(paste0(datafolder, "neuro_gs_stack/" ,data_name, ".",batch_idx,".RDS" ))
  
  
  xgboost_gi_pred <- xgb_final_fit_nominal(wf_input=gi_tuned_list[["xgboost_gi"]],
                                           test_input = gi_tuned_list[["gi_test_select"]] ,
                                           test_data_all = gi_tuned_list[["test_gi"]],
                                           resp_input = "gi",
                                           train_input = gi_tuned_list[["gi_train_select"]])
  
  
  
  xgboost_gs_pred <- xgb_final_fit_nominal(wf_input=gs_tuned_list[["xgboost_gs"]],
                                           test_input = gs_tuned_list[["gs_test_select"]] ,
                                           test_data_all = gs_tuned_list[["test_gs"]],
                                           resp_input = "gs",
                                           train_input = gs_tuned_list[["gs_train_select"]])
  
  
  output_list <- list(xgboost_gs =gs_tuned_list [["xgboost_gs"]],
                      xgboost_gi =gi_tuned_list [["xgboost_gi"]],
                      xgboost_gs_pred = xgboost_gs_pred,
                      xgboost_gi_pred=xgboost_gi_pred,
                      train_gi =gi_tuned_list [["train_gi"]],
                      train_gs =gs_tuned_list[["train_gs"]] ,
                      test_gi= gi_tuned_list[["test_gi"]],
                      test_gs=gs_tuned_list[["test_gs"]])
  
  saveRDS(output_list, paste0(datafolder, "xgb_results/" ,data_name, ".",batch_idx,".RDS" ))
}


data_name <- "mh_per_all"
for(batch_idx in seq(1:21)){
  #batch_idx <- 1
  
  gi_tuned_list <- readRDS(paste0(datafolder, "neuro_gi_stack/" ,data_name, ".",batch_idx,".RDS" ))
  
  gs_tuned_list <- readRDS(paste0(datafolder, "neuro_gs_stack/" ,data_name, ".",batch_idx,".RDS" ))
  
  
  xgboost_gi_pred <- xgb_final_fit_nominal(wf_input=gi_tuned_list[["xgboost_gi"]],
                                           test_input = gi_tuned_list[["gi_test_select"]] ,
                                           test_data_all = gi_tuned_list[["test_gi"]],
                                           resp_input = "gi",
                                           train_input = gi_tuned_list[["gi_train_select"]])
  
  
  
  xgboost_gs_pred <- xgb_final_fit_nominal(wf_input=gs_tuned_list[["xgboost_gs"]],
                                           test_input = gs_tuned_list[["gs_test_select"]] ,
                                           test_data_all = gs_tuned_list[["test_gs"]],
                                           resp_input = "gs",
                                           train_input = gs_tuned_list[["gs_train_select"]])
  
  
  output_list <- list(xgboost_gs =gs_tuned_list [["xgboost_gs"]],
                      xgboost_gi =gi_tuned_list [["xgboost_gi"]],
                      xgboost_gs_pred = xgboost_gs_pred,
                      xgboost_gi_pred=xgboost_gi_pred,
                      train_gi =gi_tuned_list [["train_gi"]],
                      train_gs =gs_tuned_list[["train_gs"]] ,
                      test_gi= gi_tuned_list[["test_gi"]],
                      test_gs=gs_tuned_list[["test_gs"]])
  
  saveRDS(output_list, paste0(datafolder, "xgb_results/" ,data_name, ".",batch_idx,".RDS" ))
}


data_name <- "neuro_nonneuro_all"
for(batch_idx in seq(1:21)){
  #batch_idx <- 1
  
  gi_tuned_list <- readRDS(paste0(datafolder, "neuro_gi_stack/" ,data_name, ".",batch_idx,".RDS" ))
  
  gs_tuned_list <- readRDS(paste0(datafolder, "neuro_gs_stack/" ,data_name, ".",batch_idx,".RDS" ))
  
  
  xgboost_gi_pred <- xgb_final_fit_nominal(wf_input=gi_tuned_list[["xgboost_gi"]],
                                           test_input = gi_tuned_list[["gi_test_select"]] ,
                                           test_data_all = gi_tuned_list[["test_gi"]],
                                           resp_input = "gi",
                                           train_input = gi_tuned_list[["gi_train_select"]])
  
  
  
  xgboost_gs_pred <- xgb_final_fit_nominal(wf_input=gs_tuned_list[["xgboost_gs"]],
                                           test_input = gs_tuned_list[["gs_test_select"]] ,
                                           test_data_all = gs_tuned_list[["test_gs"]],
                                           resp_input = "gs",
                                           train_input = gs_tuned_list[["gs_train_select"]])
  
  
  output_list <- list(xgboost_gs =gs_tuned_list [["xgboost_gs"]],
                      xgboost_gi =gi_tuned_list [["xgboost_gi"]],
                      xgboost_gs_pred = xgboost_gs_pred,
                      xgboost_gi_pred=xgboost_gi_pred,
                      train_gi =gi_tuned_list [["train_gi"]],
                      train_gs =gs_tuned_list[["train_gs"]] ,
                      test_gi= gi_tuned_list[["test_gi"]],
                      test_gs=gs_tuned_list[["test_gs"]])
  
  saveRDS(output_list, paste0(datafolder, "xgb_results/" ,data_name, ".",batch_idx,".RDS" ))
}



data_name <- "nonneuro_all"
for(batch_idx in seq(1:21)){
  #batch_idx <- 1
  
  gi_tuned_list <- readRDS(paste0(datafolder, "neuro_gi_stack/" ,data_name, ".",batch_idx,".RDS" ))
  
  gs_tuned_list <- readRDS(paste0(datafolder, "neuro_gs_stack/" ,data_name, ".",batch_idx,".RDS" ))
  
  
  xgboost_gi_pred <- xgb_final_fit_nominal(wf_input=gi_tuned_list[["xgboost_gi"]],
                                           test_input = gi_tuned_list[["gi_test_select"]] ,
                                           test_data_all = gi_tuned_list[["test_gi"]],
                                           resp_input = "gi",
                                           train_input = gi_tuned_list[["gi_train_select"]])
  
  
  
  xgboost_gs_pred <- xgb_final_fit_nominal(wf_input=gs_tuned_list[["xgboost_gs"]],
                                           test_input = gs_tuned_list[["gs_test_select"]] ,
                                           test_data_all = gs_tuned_list[["test_gs"]],
                                           resp_input = "gs",
                                           train_input = gs_tuned_list[["gs_train_select"]])
  
  
  output_list <- list(xgboost_gs =gs_tuned_list [["xgboost_gs"]],
                      xgboost_gi =gi_tuned_list [["xgboost_gi"]],
                      xgboost_gs_pred = xgboost_gs_pred,
                      xgboost_gi_pred=xgboost_gi_pred,
                      train_gi =gi_tuned_list [["train_gi"]],
                      train_gs =gs_tuned_list[["train_gs"]] ,
                      test_gi= gi_tuned_list[["test_gi"]],
                      test_gs=gs_tuned_list[["test_gs"]])
  
  saveRDS(output_list, paste0(datafolder, "xgb_results/" ,data_name, ".",batch_idx,".RDS" ))
}



data_name <- "par_fam_all"
for(batch_idx in seq(1:21)){
  #batch_idx <- 1
  
  gi_tuned_list <- readRDS(paste0(datafolder, "neuro_gi_stack/" ,data_name, ".",batch_idx,".RDS" ))
  
  gs_tuned_list <- readRDS(paste0(datafolder, "neuro_gs_stack/" ,data_name, ".",batch_idx,".RDS" ))
  
  
  xgboost_gi_pred <- xgb_final_fit_nominal(wf_input=gi_tuned_list[["xgboost_gi"]],
                                           test_input = gi_tuned_list[["gi_test_select"]] ,
                                           test_data_all = gi_tuned_list[["test_gi"]],
                                           resp_input = "gi",
                                           train_input = gi_tuned_list[["gi_train_select"]])
  
  
  
  xgboost_gs_pred <- xgb_final_fit_nominal(wf_input=gs_tuned_list[["xgboost_gs"]],
                                           test_input = gs_tuned_list[["gs_test_select"]] ,
                                           test_data_all = gs_tuned_list[["test_gs"]],
                                           resp_input = "gs",
                                           train_input = gs_tuned_list[["gs_train_select"]])
  
  
  output_list <- list(xgboost_gs =gs_tuned_list [["xgboost_gs"]],
                      xgboost_gi =gi_tuned_list [["xgboost_gi"]],
                      xgboost_gs_pred = xgboost_gs_pred,
                      xgboost_gi_pred=xgboost_gi_pred,
                      train_gi =gi_tuned_list [["train_gi"]],
                      train_gs =gs_tuned_list[["train_gs"]] ,
                      test_gi= gi_tuned_list[["test_gi"]],
                      test_gs=gs_tuned_list[["test_gs"]])
  
  saveRDS(output_list, paste0(datafolder, "xgb_results/" ,data_name, ".",batch_idx,".RDS" ))
}


data_name <- "peers_all"
for(batch_idx in seq(1:21)){
  #batch_idx <- 1
  
  gi_tuned_list <- readRDS(paste0(datafolder, "neuro_gi_stack/" ,data_name, ".",batch_idx,".RDS" ))
  
  gs_tuned_list <- readRDS(paste0(datafolder, "neuro_gs_stack/" ,data_name, ".",batch_idx,".RDS" ))
  
  
  xgboost_gi_pred <- xgb_final_fit_nominal(wf_input=gi_tuned_list[["xgboost_gi"]],
                                           test_input = gi_tuned_list[["gi_test_select"]] ,
                                           test_data_all = gi_tuned_list[["test_gi"]],
                                           resp_input = "gi",
                                           train_input = gi_tuned_list[["gi_train_select"]])
  
  
  
  xgboost_gs_pred <- xgb_final_fit_nominal(wf_input=gs_tuned_list[["xgboost_gs"]],
                                           test_input = gs_tuned_list[["gs_test_select"]] ,
                                           test_data_all = gs_tuned_list[["test_gs"]],
                                           resp_input = "gs",
                                           train_input = gs_tuned_list[["gs_train_select"]])
  
  
  output_list <- list(xgboost_gs =gs_tuned_list [["xgboost_gs"]],
                      xgboost_gi =gi_tuned_list [["xgboost_gi"]],
                      xgboost_gs_pred = xgboost_gs_pred,
                      xgboost_gi_pred=xgboost_gi_pred,
                      train_gi =gi_tuned_list [["train_gi"]],
                      train_gs =gs_tuned_list[["train_gs"]] ,
                      test_gi= gi_tuned_list[["test_gi"]],
                      test_gs=gs_tuned_list[["test_gs"]])
  
  saveRDS(output_list, paste0(datafolder, "xgb_results/" ,data_name, ".",batch_idx,".RDS" ))
}


data_name <- "phy_fo_all"
for(batch_idx in seq(1:21)){
  #batch_idx <- 1
  
  gi_tuned_list <- readRDS(paste0(datafolder, "neuro_gi_stack/" ,data_name, ".",batch_idx,".RDS" ))
  
  gs_tuned_list <- readRDS(paste0(datafolder, "neuro_gs_stack/" ,data_name, ".",batch_idx,".RDS" ))
  
  
  xgboost_gi_pred <- xgb_final_fit_nominal(wf_input=gi_tuned_list[["xgboost_gi"]],
                                           test_input = gi_tuned_list[["gi_test_select"]] ,
                                           test_data_all = gi_tuned_list[["test_gi"]],
                                           resp_input = "gi",
                                           train_input = gi_tuned_list[["gi_train_select"]])
  
  
  
  xgboost_gs_pred <- xgb_final_fit_nominal(wf_input=gs_tuned_list[["xgboost_gs"]],
                                           test_input = gs_tuned_list[["gs_test_select"]] ,
                                           test_data_all = gs_tuned_list[["test_gs"]],
                                           resp_input = "gs",
                                           train_input = gs_tuned_list[["gs_train_select"]])
  
  
  output_list <- list(xgboost_gs =gs_tuned_list [["xgboost_gs"]],
                      xgboost_gi =gi_tuned_list [["xgboost_gi"]],
                      xgboost_gs_pred = xgboost_gs_pred,
                      xgboost_gi_pred=xgboost_gi_pred,
                      train_gi =gi_tuned_list [["train_gi"]],
                      train_gs =gs_tuned_list[["train_gs"]] ,
                      test_gi= gi_tuned_list[["test_gi"]],
                      test_gs=gs_tuned_list[["test_gs"]])
  
  saveRDS(output_list, paste0(datafolder, "xgb_results/" ,data_name, ".",batch_idx,".RDS" ))
}


data_name <- "school_all"
for(batch_idx in seq(1:21)){
  #batch_idx <- 1
  
  gi_tuned_list <- readRDS(paste0(datafolder, "neuro_gi_stack/" ,data_name, ".",batch_idx,".RDS" ))
  
  gs_tuned_list <- readRDS(paste0(datafolder, "neuro_gs_stack/" ,data_name, ".",batch_idx,".RDS" ))
  
  
  xgboost_gi_pred <- xgb_final_fit_nominal(wf_input=gi_tuned_list[["xgboost_gi"]],
                                           test_input = gi_tuned_list[["gi_test_select"]] ,
                                           test_data_all = gi_tuned_list[["test_gi"]],
                                           resp_input = "gi",
                                           train_input = gi_tuned_list[["gi_train_select"]])
  
  
  
  xgboost_gs_pred <- xgb_final_fit_nominal(wf_input=gs_tuned_list[["xgboost_gs"]],
                                           test_input = gs_tuned_list[["gs_test_select"]] ,
                                           test_data_all = gs_tuned_list[["test_gs"]],
                                           resp_input = "gs",
                                           train_input = gs_tuned_list[["gs_train_select"]])
  
  
  output_list <- list(xgboost_gs =gs_tuned_list [["xgboost_gs"]],
                      xgboost_gi =gi_tuned_list [["xgboost_gi"]],
                      xgboost_gs_pred = xgboost_gs_pred,
                      xgboost_gi_pred=xgboost_gi_pred,
                      train_gi =gi_tuned_list [["train_gi"]],
                      train_gs =gs_tuned_list[["train_gs"]] ,
                      test_gi= gi_tuned_list[["test_gi"]],
                      test_gs=gs_tuned_list[["test_gs"]])
  
  saveRDS(output_list, paste0(datafolder, "xgb_results/" ,data_name, ".",batch_idx,".RDS" ))
}


data_name <- "sle_act_all"
for(batch_idx in seq(1:21)){
  #batch_idx <- 1
  
  gi_tuned_list <- readRDS(paste0(datafolder, "neuro_gi_stack/" ,data_name, ".",batch_idx,".RDS" ))
  
  gs_tuned_list <- readRDS(paste0(datafolder, "neuro_gs_stack/" ,data_name, ".",batch_idx,".RDS" ))
  
  
  xgboost_gi_pred <- xgb_final_fit_nominal(wf_input=gi_tuned_list[["xgboost_gi"]],
                                           test_input = gi_tuned_list[["gi_test_select"]] ,
                                           test_data_all = gi_tuned_list[["test_gi"]],
                                           resp_input = "gi",
                                           train_input = gi_tuned_list[["gi_train_select"]])
  
  
  
  xgboost_gs_pred <- xgb_final_fit_nominal(wf_input=gs_tuned_list[["xgboost_gs"]],
                                           test_input = gs_tuned_list[["gs_test_select"]] ,
                                           test_data_all = gs_tuned_list[["test_gs"]],
                                           resp_input = "gs",
                                           train_input = gs_tuned_list[["gs_train_select"]])
  
  
  output_list <- list(xgboost_gs =gs_tuned_list [["xgboost_gs"]],
                      xgboost_gi =gi_tuned_list [["xgboost_gi"]],
                      xgboost_gs_pred = xgboost_gs_pred,
                      xgboost_gi_pred=xgboost_gi_pred,
                      train_gi =gi_tuned_list [["train_gi"]],
                      train_gs =gs_tuned_list[["train_gs"]] ,
                      test_gi= gi_tuned_list[["test_gi"]],
                      test_gs=gs_tuned_list[["test_gs"]])
  
  saveRDS(output_list, paste0(datafolder, "xgb_results/" ,data_name, ".",batch_idx,".RDS" ))
}


