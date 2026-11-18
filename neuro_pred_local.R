## library path
.libPaths(new =  "/home/wanyu368/R/foss-2023a/4.3"  )
#for parallel processing

library(tidymodels)
library(tidyverse)
library("sva")
library(future)
library(finetune)



options(future.globals.maxSize = Inf)
plan(future.callr::callr, workers = strtoi(Sys.getenv('SLURM_CPUS_PER_TASK')),gc = TRUE)
#plan(future.callr::callr, workers = 15,gc = TRUE)


datafolder <- "/nesi/nobackup/uoo03493/Yue/ABCD_7.0_growth/"
#datafolder <- "/Volumes/sci-psy-narun/Nesi/Yue/ABCD_7.0_growth/"

source(paste0(datafolder,"r_functions_7.0.R"))

args <- commandArgs(trailingOnly = TRUE)
dataset <- args[1]
resp_data_set <- "gfactor.RData"


#dataset <- "smri_T2_mean_total_data.RDS"
#dataset <- "antiSmallRewVsNeu_ROI_.RDS"
#print(dataset)
#dataset <- "X2backvs0back_ROI_.RDS"
### smallest dataset for test
## dataset <- "smri_T2_mean_total_data.RDS"
### biggest dataset for test
## dataset <- "rsmri_gordon_aseg_data.RDS"

for(batch_idx in 1:21){
  data_input <- readRDS(file = paste0(datafolder, "data/", dataset))
  resp_input <- readRDS(file = paste0(datafolder, "data/", resp_data_set))
  gen_dyn_site_age <- readRDS(file = paste0(datafolder, "data/", "gen_dyn_site_age.RDS")) %>% select(-ab_g_dyn__visit_age)
  
  
  site_vec <- names(resp_input)
  
  site_input <- site_vec[batch_idx]
  
  ### comput and process gfactor
  
  gfactor_list <- resp_input[[site_input]]
  
  
  ### processing the features
  
  subj_site <-  c("participant_id","session_id","ab_g_dyn__design_site")   
  subj_info <-  c("participant_id","session_id")   
  subj_n_site <-  c("participant_id","ab_g_dyn__design_site")   
  
  
  event_vec <- unique(data_input$session_id)
  features_vec <- data_input %>% select(-all_of(subj_info))%>% colnames()
  data_event_site <- left_join(data_input,gen_dyn_site_age, by =  c("participant_id","session_id")) %>% drop_na()
  
  
  data_name <- gsub(dataset, pattern = "\\.RDS", replacement = "" )
  processed_features <- readRDS(file = paste0(datafolder, "neuro_processed_data/" ,data_name, ".",batch_idx,".RDS" ))
  
  
  features_gc_all <- processed_features %>% select(-all_of(c("participant_id", "ab_g_dyn__design_site","fold"))) %>% colnames()
  
  
  ### get the common participants in both features and the response
  
  common_par <- intersect(processed_features$participant_id,gfactor_list$participant_id)
  
  train_features <-filter(processed_features, fold =="train") %>% select(-fold)
  
  test_features <-filter(processed_features, fold =="test")%>% select(-fold)
  
  gfactor_train <- filter(gfactor_list, fold =="train")%>% select(-fold)
  
  gi_train <- gfactor_train %>% select(all_of(c("participant_id","ab_g_dyn__design_site","gi")))
  
  gfactor_test <- filter(gfactor_list, fold =="test")%>% select(-fold)
  
  gi_test <- gfactor_test %>% select(all_of(c("participant_id","ab_g_dyn__design_site","gi")))
  
  train_gi <- left_join(gi_train,train_features, by = c("participant_id","ab_g_dyn__design_site")) %>% filter(participant_id %in% common_par)
  
  test_gi <- left_join(gi_test, test_features,by = c("participant_id","ab_g_dyn__design_site"))%>% filter(participant_id %in% common_par)
  
  gi_train_select <-select(train_gi,"gi",all_of(features_gc_all))
  
  gi_test_select <- select(test_gi,"gi",all_of(features_gc_all))
  
  
  gi_tuned_list <- readRDS(paste0(datafolder, "neuro_gi_tune/" ,data_name, ".",batch_idx,".RDS" ))
  
  gs_tuned_list <- readRDS(paste0(datafolder, "neuro_gs_tune/" ,data_name, ".",batch_idx,".RDS" ))
  
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
  
  saveRDS(output_list, paste0(datafolder, "xgb_results/" ,data_name, ".",batch_idx,".RDS" ))
}


