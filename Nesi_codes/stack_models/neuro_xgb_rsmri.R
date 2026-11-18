## library path
.libPaths(new =  "/home/wanyu368/R/foss-2023a/4.3"  )
#for parallel processing

library(tidymodels)
library(tidyverse)
library("sva")
library(future)
library(finetune)
library(butcher)

options(future.globals.maxSize = Inf)
plan(future.callr::callr, workers = strtoi(Sys.getenv('SLURM_CPUS_PER_TASK')),gc = TRUE)
#plan(future.callr::callr, workers = 15,gc = TRUE)


datafolder <- "/nesi/nobackup/uoo03493/Yue/ABCD_7.0_growth/"
#datafolder <- "/Volumes/sci-psy-narun/Nesi/Yue/ABCD_7.0_growth/"

source(paste0(datafolder,"r_functions_7.0.R"))

args <- commandArgs(trailingOnly = TRUE)
dataset <- args[1]
resp_data_set <- "gfactor.RData"

batch_idx <- strtoi(Sys.getenv('SLURM_ARRAY_TASK_ID'))
#batch_idx <- 16
#batch_idx <- 15
#batch_idx <- 20

#print(batch_idx)

# number of threads to use for parallel xgboost
# passed into set_engine()
#threads <- strtoi(Sys.getenv("SLURM_CPU_PER_TASK"))

print("Setup complete!")
message("Setup complete!")


modality_names=c("rsmri_gordon_aseg_data","rsmri_subnet","rsmri_within_avg_data")

gi_list_name = paste0(datafolder, "neuro_gi_enet/", modality_names,".",batch_idx,".RDS")
gs_list_name = paste0(datafolder, "neuro_gs_enet/", modality_names,".",batch_idx,".RDS")



gi_list <- purrr::map(gi_list_name, ~readRDS(.)) 
gi_enet_list <- map(gi_list,"enet_gi_fit_all")
gi_enet_list <- gi_enet_list%>% 
  map(.,~filter(.,if_any(where(is.numeric), ~ !is.na(.))))

gs_list <- purrr::map(gs_list_name, ~readRDS(.)) 
gs_enet_list <- map(gs_list,"enet_gs_fit_all")
gs_enet_list <- gs_enet_list%>% 
  map(.,~filter(.,if_any(where(is.numeric), ~ !is.na(.))))
neuro_gi_all <- plyr::join_all(gi_enet_list,by =c("participant_id", "ab_g_dyn__design_site","fold"),type ="full")
neuro_gs_all <- plyr::join_all(gs_enet_list,by =c("participant_id", "ab_g_dyn__design_site","fold"),type ="full")


resp_input <- readRDS(file = paste0(datafolder, "data/", resp_data_set))

site_vec <- names(resp_input)

site_input <- site_vec[batch_idx]

### comput and process gfactor

gfactor_list <- resp_input[[site_input]]


### processing the features

subj_site <-  c("participant_id","session_id","ab_g_dyn__design_site")   
subj_info <-  c("participant_id","session_id")   
subj_n_site <-  c("participant_id","ab_g_dyn__design_site")   


features_vec <- neuro_gi_all %>% select(-all_of(c("participant_id", "ab_g_dyn__design_site","fold")))%>% colnames()


### get the common participants in both features and the response

common_par <- intersect(neuro_gi_all$participant_id,gfactor_list$participant_id)

train_gi_features <-filter(neuro_gi_all, fold =="train") %>% select(-fold)
test_gi_features <-filter(neuro_gi_all, fold =="test")%>% select(-fold)

train_gs_features <-filter(neuro_gs_all, fold =="train") %>% select(-fold)
test_gs_features <-filter(neuro_gs_all, fold =="test")%>% select(-fold)

gfactor_train <- filter(gfactor_list, fold =="train")%>% select(-fold)
gfactor_test <- filter(gfactor_list, fold =="test")%>% select(-fold)

gi_train <- gfactor_train %>% select(all_of(c("participant_id","ab_g_dyn__design_site","gi")))
gi_test <- gfactor_test %>% select(all_of(c("participant_id","ab_g_dyn__design_site","gi")))

gs_train <- gfactor_train %>% select(all_of(c("participant_id","ab_g_dyn__design_site","gs")))
gs_test <- gfactor_test %>% select(all_of(c("participant_id","ab_g_dyn__design_site","gs")))



train_gi <- left_join(gi_train,train_gi_features, by = c("participant_id","ab_g_dyn__design_site")) %>% filter(participant_id %in% common_par)
test_gi <- left_join(gi_test, test_gi_features,by = c("participant_id","ab_g_dyn__design_site"))%>% filter(participant_id %in% common_par)

gi_train_select <-select(train_gi,"gi",all_of(features_vec))
gi_test_select <- select(test_gi,"gi",all_of(features_vec))


train_gs <- left_join(gs_train,train_gs_features, by = c("participant_id","ab_g_dyn__design_site")) %>% filter(participant_id %in% common_par)
test_gs <- left_join(gs_test, test_gs_features,by = c("participant_id","ab_g_dyn__design_site"))%>% filter(participant_id %in% common_par)

gs_train_select <-select(train_gs,"gs",all_of(features_vec))
gs_test_select <- select(test_gs,"gs",all_of(features_vec))


### model fitting
recipe_gi <-recipe_flat_brain(train_data = gi_train_select,
                              resp_input = "gi",features = features_vec) 

recipe_gs <-recipe_flat_brain(train_data = gs_train_select,
                              resp_input = "gs",features = features_vec) 


xgboost_gi <- xgb_flat(recipe_input = recipe_gi)

xgboost_gs <- xgb_flat(recipe_input = recipe_gs)



output_list_gi <- list(xgboost_gi = xgboost_gi,
                    train_gi = train_gi,
                    test_gi=test_gi,
                    recipe_gi=recipe_gi,
                    gi_train_select=gi_train_select,
                    gi_test_select=gi_test_select)

output_list_gs <- list(xgboost_gs = xgboost_gs,
                       train_gs = train_gs,
                       test_gs=test_gs,
                       recipe_gs=recipe_gs,
                       gs_train_select=gs_train_select,
                       gs_test_select=gs_test_select)

saveRDS(output_list_gi, paste0(datafolder, "neuro_gi_stack/" ,"neuro_rsmri", ".",batch_idx,".RDS" ))


saveRDS(output_list_gs, paste0(datafolder, "neuro_gs_stack/" ,"neuro_rsmri", ".",batch_idx,".RDS" ))

