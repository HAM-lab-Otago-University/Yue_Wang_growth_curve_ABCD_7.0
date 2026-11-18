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

data_name <- gsub(dataset, pattern = "\\.RDS", replacement = "" )

#dataset <- "smri_T2_mean_total_data.RDS"
#dataset <- "antiSmallRewVsNeu_ROI_.RDS"
#print(dataset)
#dataset <- "X2backvs0back_ROI_.RDS"
### smallest dataset for test
## dataset <- "smri_T2_mean_total_data.RDS"
### biggest dataset for test
## dataset <- "rsmri_gordon_aseg_data.RDS"


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

data_input <- readRDS(file = paste0(datafolder, "neuro_processed_data/", data_name,".",batch_idx,".RDS"))
resp_input <- readRDS(file = paste0(datafolder, "data/", resp_data_set))


site_vec <- names(resp_input)

site_input <- site_vec[batch_idx]

### comput and process gfactor

gfactor_list <- resp_input[[site_input]]


### processing the features

subj_site <-  c("participant_id","session_id","ab_g_dyn__design_site")   
subj_info <-  c("participant_id","session_id")   
subj_n_site <-  c("participant_id","ab_g_dyn__design_site")   
subj_fold_site <-  c("participant_id","ab_g_dyn__design_site","fold")   


data_00_all <- data_input %>% select(all_of(subj_fold_site),contains("_00A"))
data_02_all <- data_input %>% select(all_of(subj_fold_site),contains("_02A"))
data_04_all <- data_input %>% select(all_of(subj_fold_site),contains("_04A"))
data_06_all <- data_input %>% select(all_of(subj_fold_site),contains("_06A"))


features_00 <- data_input %>% select(contains("_00A"))%>% colnames()
features_02 <- data_input %>% select(contains("_02A"))%>% colnames()
features_04 <- data_input %>% select(contains("_04A"))%>% colnames()
features_06 <- data_input %>% select(contains("_06A"))%>% colnames()


### get the common participants in both features and the response



train_features_00 <-filter(data_00_all, fold =="train") %>% select(-fold)
test_features_00 <-filter(data_00_all, fold =="test")%>% select(-fold)
train_features_02 <-filter(data_02_all, fold =="train") %>% select(-fold)
test_features_02 <-filter(data_02_all, fold =="test")%>% select(-fold)
train_features_04 <-filter(data_04_all, fold =="train") %>% select(-fold)
test_features_04 <-filter(data_04_all, fold =="test")%>% select(-fold)
train_features_06 <-filter(data_06_all, fold =="train") %>% select(-fold)
test_features_06 <-filter(data_06_all, fold =="test")%>% select(-fold)


gfactor_train <- filter(gfactor_list, fold =="train")%>% select(-fold)
gfactor_test <- filter(gfactor_list, fold =="test")%>% select(-fold)



gi_train <- gfactor_train %>% select(all_of(c("participant_id","ab_g_dyn__design_site","gi")))
gi_test <- gfactor_test %>% select(all_of(c("participant_id","ab_g_dyn__design_site","gi")))
gs_train <- gfactor_train %>% select(all_of(c("participant_id","ab_g_dyn__design_site","gs")))
gs_test <- gfactor_test %>% select(all_of(c("participant_id","ab_g_dyn__design_site","gs")))




train_gi_00 <- left_join(gi_train,train_features_00, by = c("participant_id","ab_g_dyn__design_site")) %>% 
               drop_na()
test_gi_00 <- left_join(gi_test, test_features_00,by = c("participant_id","ab_g_dyn__design_site"))%>% 
  drop_na()
gi_train_select_00 <-select(train_gi_00,"gi",all_of(features_00))
gi_test_select_00 <- select(test_gi_00,"gi",all_of(features_00))

train_gi_02 <- left_join(gi_train,train_features_02, by = c("participant_id","ab_g_dyn__design_site")) %>% 
  drop_na()
test_gi_02 <- left_join(gi_test, test_features_02,by = c("participant_id","ab_g_dyn__design_site"))%>% 
  drop_na()
gi_train_select_02 <-select(train_gi_02,"gi",all_of(features_02))
gi_test_select_02 <- select(test_gi_02,"gi",all_of(features_02))

train_gi_04 <- left_join(gi_train,train_features_04, by = c("participant_id","ab_g_dyn__design_site")) %>% 
  drop_na()
test_gi_04 <- left_join(gi_test, test_features_04,by = c("participant_id","ab_g_dyn__design_site"))%>% 
  drop_na()
gi_train_select_04 <-select(train_gi_04,"gi",all_of(features_04))
gi_test_select_04 <- select(test_gi_04,"gi",all_of(features_04))

train_gi_06 <- left_join(gi_train,train_features_06, by = c("participant_id","ab_g_dyn__design_site")) %>% 
  drop_na()
test_gi_06 <- left_join(gi_test, test_features_06,by = c("participant_id","ab_g_dyn__design_site"))%>% 
  drop_na()
gi_train_select_06 <-select(train_gi_06,"gi",all_of(features_06))
gi_test_select_06 <- select(test_gi_06,"gi",all_of(features_06))



train_gs_00 <- left_join(gs_train,train_features_00, by = c("participant_id","ab_g_dyn__design_site")) %>% 
  drop_na()
test_gs_00 <- left_join(gs_test, test_features_00,by = c("participant_id","ab_g_dyn__design_site"))%>% 
  drop_na()
gs_train_select_00 <-select(train_gs_00,"gs",all_of(features_00))
gs_test_select_00 <- select(test_gs_00,"gs",all_of(features_00))
train_gs_02 <- left_join(gs_train,train_features_02, by = c("participant_id","ab_g_dyn__design_site")) %>% 
  drop_na()
test_gs_02 <- left_join(gs_test, test_features_02,by = c("participant_id","ab_g_dyn__design_site"))%>% 
  drop_na()
gs_train_select_02 <-select(train_gs_02,"gs",all_of(features_02))
gs_test_select_02 <- select(test_gs_02,"gs",all_of(features_02))

train_gs_04 <- left_join(gs_train,train_features_04, by = c("participant_id","ab_g_dyn__design_site")) %>% 
  drop_na()
test_gs_04 <- left_join(gs_test, test_features_04,by = c("participant_id","ab_g_dyn__design_site"))%>% 
  drop_na()
gs_train_select_04 <-select(train_gs_04,"gs",all_of(features_04))
gs_test_select_04 <- select(test_gs_04,"gs",all_of(features_04))

train_gs_06 <- left_join(gs_train,train_features_06, by = c("participant_id","ab_g_dyn__design_site")) %>% 
  drop_na()
test_gs_06 <- left_join(gs_test, test_features_06,by = c("participant_id","ab_g_dyn__design_site"))%>% 
  drop_na()
gs_train_select_06 <-select(train_gs_06,"gs",all_of(features_06))
gs_test_select_06 <- select(test_gs_06,"gs",all_of(features_06))





### model fitting
recipe_gi_00 <-recipe_flat_brain(train_data = gi_train_select_00,
                            resp_input = "gi",
                            features = features_00) 
recipe_gi_02 <-recipe_flat_brain(train_data = gi_train_select_02,
                            resp_input = "gi",
                            features = features_02) 
recipe_gi_04 <-recipe_flat_brain(train_data = gi_train_select_04,
                            resp_input = "gi",
                            features = features_04) 
recipe_gi_06 <-recipe_flat_brain(train_data = gi_train_select_06,
                            resp_input = "gi",
                            features = features_06) 



recipe_gs_00 <-recipe_flat_brain(train_data = gs_train_select_00,
                                 resp_input = "gs",
                                 features = features_00) 
recipe_gs_02 <-recipe_flat_brain(train_data = gs_train_select_02,
                                 resp_input = "gs",
                                 features = features_02) 
recipe_gs_04 <-recipe_flat_brain(train_data = gs_train_select_04,
                                 resp_input = "gs",
                                 features = features_04) 
recipe_gs_06 <-recipe_flat_brain(train_data = gs_train_select_06,
                                 resp_input = "gs",
                                 features = features_06) 


enet_gi_00 <- enet_tuning(recipe_input = recipe_gi_00)
enet_gi_02 <- enet_tuning(recipe_input = recipe_gi_02)
enet_gi_04 <- enet_tuning(recipe_input = recipe_gi_04)
enet_gi_06 <- enet_tuning(recipe_input = recipe_gi_06)

enet_gs_00 <- enet_tuning(recipe_input = recipe_gs_00)
enet_gs_02 <- enet_tuning(recipe_input = recipe_gs_02)
enet_gs_04 <- enet_tuning(recipe_input = recipe_gs_04)
enet_gs_06 <- enet_tuning(recipe_input = recipe_gs_06)


enet_gi_00_fit <- enet_final_fit(recipe_input=recipe_gi_00,
                wf_input=enet_gi_00[["enet_wf_final" ]],
              test_input=gi_test_select_00,
              test_data_all = test_gi_00,
              resp_input = "gi")
enet_gi_00_fit_table <- enet_gi_00_fit[["model_predict"]] %>% 
  select(all_of(c("participant_id","ab_g_dyn__design_site","gi","model_predict")))
names(enet_gi_00_fit_table) <- c("participant_id","ab_g_dyn__design_site","gi",paste0(data_name,"_00A")) 
enet_gi_00_fit_table <- enet_gi_00_fit_table  %>% 
  mutate(fold ="test") %>% 
  select(-"gi")


enet_gi_00_fit_train <- enet_final_fit(recipe_input=recipe_gi_00,
                                 wf_input=enet_gi_00[["enet_wf_final" ]],
                                 test_input=gi_train_select_00,
                                 test_data_all = train_gi_00,
                                 resp_input = "gi")
enet_gi_00_fit_train_table <- enet_gi_00_fit_train[["model_predict"]] %>% 
                              select(all_of(c("participant_id","ab_g_dyn__design_site","gi","model_predict")))
names(enet_gi_00_fit_train_table) <- c("participant_id","ab_g_dyn__design_site","gi",paste0(data_name,"_00A")) 
enet_gi_00_fit_train_table <- enet_gi_00_fit_train_table  %>% 
                              mutate(fold ="train") %>% 
                              select(-"gi")
enet_gi_00_fit_all <- bind_rows(enet_gi_00_fit_train_table,enet_gi_00_fit_table)


enet_gi_02_fit <- enet_final_fit(recipe_input=recipe_gi_02,
                                 wf_input=enet_gi_02[["enet_wf_final" ]],
                                 test_input=gi_test_select_02,
                                 test_data_all = test_gi_02,
                                 resp_input = "gi")
enet_gi_02_fit_table <- enet_gi_02_fit[["model_predict"]] %>% 
  select(all_of(c("participant_id","ab_g_dyn__design_site","gi","model_predict")))
names(enet_gi_02_fit_table) <- c("participant_id","ab_g_dyn__design_site","gi",paste0(data_name,"_02A")) 
enet_gi_02_fit_table <- enet_gi_02_fit_table  %>% 
  mutate(fold ="test") %>% 
  select(-"gi")


enet_gi_02_fit_train <- enet_final_fit(recipe_input=recipe_gi_02,
                                       wf_input=enet_gi_02[["enet_wf_final" ]],
                                       test_input=gi_train_select_02,
                                       test_data_all = train_gi_02,
                                       resp_input = "gi")
enet_gi_02_fit_train_table <- enet_gi_02_fit_train[["model_predict"]] %>% 
  select(all_of(c("participant_id","ab_g_dyn__design_site","gi","model_predict")))
names(enet_gi_02_fit_train_table) <- c("participant_id","ab_g_dyn__design_site","gi",paste0(data_name,"_02A")) 
enet_gi_02_fit_train_table <- enet_gi_02_fit_train_table  %>% 
  mutate(fold ="train") %>% 
  select(-"gi")
enet_gi_02_fit_all <- bind_rows(enet_gi_02_fit_train_table,enet_gi_02_fit_table)


enet_gi_04_fit <- enet_final_fit(recipe_input=recipe_gi_04,
                                 wf_input=enet_gi_04[["enet_wf_final" ]],
                                 test_input=gi_test_select_04,
                                 test_data_all = test_gi_04,
                                 resp_input = "gi")
enet_gi_04_fit_table <- enet_gi_04_fit[["model_predict"]] %>% 
  select(all_of(c("participant_id","ab_g_dyn__design_site","gi","model_predict")))
names(enet_gi_04_fit_table) <- c("participant_id","ab_g_dyn__design_site","gi",paste0(data_name,"_04A")) 
enet_gi_04_fit_table <- enet_gi_04_fit_table  %>% 
  mutate(fold ="test") %>% 
  select(-"gi")


enet_gi_04_fit_train <- enet_final_fit(recipe_input=recipe_gi_04,
                                       wf_input=enet_gi_04[["enet_wf_final" ]],
                                       test_input=gi_train_select_04,
                                       test_data_all = train_gi_04,
                                       resp_input = "gi")
enet_gi_04_fit_train_table <- enet_gi_04_fit_train[["model_predict"]] %>% 
  select(all_of(c("participant_id","ab_g_dyn__design_site","gi","model_predict")))
names(enet_gi_04_fit_train_table) <- c("participant_id","ab_g_dyn__design_site","gi",paste0(data_name,"_04A")) 
enet_gi_04_fit_train_table <- enet_gi_04_fit_train_table  %>% 
  mutate(fold ="train") %>% 
  select(-"gi")
enet_gi_04_fit_all <- bind_rows(enet_gi_04_fit_train_table,enet_gi_04_fit_table)


enet_gi_06_fit <- enet_final_fit(recipe_input=recipe_gi_06,
                                 wf_input=enet_gi_06[["enet_wf_final" ]],
                                 test_input=gi_test_select_06,
                                 test_data_all = test_gi_06,
                                 resp_input = "gi")
enet_gi_06_fit_table <- enet_gi_06_fit[["model_predict"]] %>% 
  select(all_of(c("participant_id","ab_g_dyn__design_site","gi","model_predict")))
names(enet_gi_06_fit_table) <- c("participant_id","ab_g_dyn__design_site","gi",paste0(data_name,"_06A")) 
enet_gi_06_fit_table <- enet_gi_06_fit_table  %>% 
  mutate(fold ="test") %>% 
  select(-"gi")


enet_gi_06_fit_train <- enet_final_fit(recipe_input=recipe_gi_06,
                                       wf_input=enet_gi_06[["enet_wf_final" ]],
                                       test_input=gi_train_select_06,
                                       test_data_all = train_gi_06,
                                       resp_input = "gi")
enet_gi_06_fit_train_table <- enet_gi_06_fit_train[["model_predict"]] %>% 
  select(all_of(c("participant_id","ab_g_dyn__design_site","gi","model_predict")))
names(enet_gi_06_fit_train_table) <- c("participant_id","ab_g_dyn__design_site","gi",paste0(data_name,"_06A")) 
enet_gi_06_fit_train_table <- enet_gi_06_fit_train_table  %>% 
  mutate(fold ="train") %>% 
  select(-"gi")
enet_gi_06_fit_all <- bind_rows(enet_gi_06_fit_train_table,enet_gi_06_fit_table)

enet_gi_fit_all <- plyr::join_all(list(enet_gi_00_fit_all,
                                       enet_gi_02_fit_all,
                                       enet_gi_04_fit_all,
                                       enet_gi_06_fit_all),by = subj_fold_site, type = "full")


enet_gs_00_fit <- enet_final_fit(recipe_input=recipe_gs_00,
                                 wf_input=enet_gs_00[["enet_wf_final" ]],
                                 test_input=gs_test_select_00,
                                 test_data_all = test_gs_00,
                                 resp_input = "gs")
enet_gs_00_fit_table <- enet_gs_00_fit[["model_predict"]] %>% 
  select(all_of(c("participant_id","ab_g_dyn__design_site","gs","model_predict")))
names(enet_gs_00_fit_table) <- c("participant_id","ab_g_dyn__design_site","gs",paste0(data_name,"_00A")) 
enet_gs_00_fit_table <- enet_gs_00_fit_table  %>% 
  mutate(fold ="test") %>% 
  select(-"gs")


enet_gs_00_fit_train <- enet_final_fit(recipe_input=recipe_gs_00,
                                       wf_input=enet_gs_00[["enet_wf_final" ]],
                                       test_input=gs_train_select_00,
                                       test_data_all = train_gs_00,
                                       resp_input = "gs")
enet_gs_00_fit_train_table <- enet_gs_00_fit_train[["model_predict"]] %>% 
  select(all_of(c("participant_id","ab_g_dyn__design_site","gs","model_predict")))
names(enet_gs_00_fit_train_table) <- c("participant_id","ab_g_dyn__design_site","gs",paste0(data_name,"_00A")) 
enet_gs_00_fit_train_table <- enet_gs_00_fit_train_table  %>% 
  mutate(fold ="train") %>% 
  select(-"gs")
enet_gs_00_fit_all <- bind_rows(enet_gs_00_fit_train_table,enet_gs_00_fit_table)


enet_gs_02_fit <- enet_final_fit(recipe_input=recipe_gs_02,
                                 wf_input=enet_gs_02[["enet_wf_final" ]],
                                 test_input=gs_test_select_02,
                                 test_data_all = test_gs_02,
                                 resp_input = "gs")
enet_gs_02_fit_table <- enet_gs_02_fit[["model_predict"]] %>% 
  select(all_of(c("participant_id","ab_g_dyn__design_site","gs","model_predict")))
names(enet_gs_02_fit_table) <- c("participant_id","ab_g_dyn__design_site","gs",paste0(data_name,"_02A")) 
enet_gs_02_fit_table <- enet_gs_02_fit_table  %>% 
  mutate(fold ="test") %>% 
  select(-"gs")


enet_gs_02_fit_train <- enet_final_fit(recipe_input=recipe_gs_02,
                                       wf_input=enet_gs_02[["enet_wf_final" ]],
                                       test_input=gs_train_select_02,
                                       test_data_all = train_gs_02,
                                       resp_input = "gs")
enet_gs_02_fit_train_table <- enet_gs_02_fit_train[["model_predict"]] %>% 
  select(all_of(c("participant_id","ab_g_dyn__design_site","gs","model_predict")))
names(enet_gs_02_fit_train_table) <- c("participant_id","ab_g_dyn__design_site","gs",paste0(data_name,"_02A")) 
enet_gs_02_fit_train_table <- enet_gs_02_fit_train_table  %>% 
  mutate(fold ="train") %>% 
  select(-"gs")
enet_gs_02_fit_all <- bind_rows(enet_gs_02_fit_train_table,enet_gs_02_fit_table)


enet_gs_04_fit <- enet_final_fit(recipe_input=recipe_gs_04,
                                 wf_input=enet_gs_04[["enet_wf_final" ]],
                                 test_input=gs_test_select_04,
                                 test_data_all = test_gs_04,
                                 resp_input = "gs")
enet_gs_04_fit_table <- enet_gs_04_fit[["model_predict"]] %>% 
  select(all_of(c("participant_id","ab_g_dyn__design_site","gs","model_predict")))
names(enet_gs_04_fit_table) <- c("participant_id","ab_g_dyn__design_site","gs",paste0(data_name,"_04A")) 
enet_gs_04_fit_table <- enet_gs_04_fit_table  %>% 
  mutate(fold ="test") %>% 
  select(-"gs")


enet_gs_04_fit_train <- enet_final_fit(recipe_input=recipe_gs_04,
                                       wf_input=enet_gs_04[["enet_wf_final" ]],
                                       test_input=gs_train_select_04,
                                       test_data_all = train_gs_04,
                                       resp_input = "gs")
enet_gs_04_fit_train_table <- enet_gs_04_fit_train[["model_predict"]] %>% 
  select(all_of(c("participant_id","ab_g_dyn__design_site","gs","model_predict")))
names(enet_gs_04_fit_train_table) <- c("participant_id","ab_g_dyn__design_site","gs",paste0(data_name,"_04A")) 
enet_gs_04_fit_train_table <- enet_gs_04_fit_train_table  %>% 
  mutate(fold ="train") %>% 
  select(-"gs")
enet_gs_04_fit_all <- bind_rows(enet_gs_04_fit_train_table,enet_gs_04_fit_table)


enet_gs_06_fit <- enet_final_fit(recipe_input=recipe_gs_06,
                                 wf_input=enet_gs_06[["enet_wf_final" ]],
                                 test_input=gs_test_select_06,
                                 test_data_all = test_gs_06,
                                 resp_input = "gs")
enet_gs_06_fit_table <- enet_gs_06_fit[["model_predict"]] %>% 
  select(all_of(c("participant_id","ab_g_dyn__design_site","gs","model_predict")))
names(enet_gs_06_fit_table) <- c("participant_id","ab_g_dyn__design_site","gs",paste0(data_name,"_06A")) 
enet_gs_06_fit_table <- enet_gs_06_fit_table  %>% 
  mutate(fold ="test") %>% 
  select(-"gs")


enet_gs_06_fit_train <- enet_final_fit(recipe_input=recipe_gs_06,
                                       wf_input=enet_gs_06[["enet_wf_final" ]],
                                       test_input=gs_train_select_06,
                                       test_data_all = train_gs_06,
                                       resp_input = "gs")
enet_gs_06_fit_train_table <- enet_gs_06_fit_train[["model_predict"]] %>% 
  select(all_of(c("participant_id","ab_g_dyn__design_site","gs","model_predict")))
names(enet_gs_06_fit_train_table) <- c("participant_id","ab_g_dyn__design_site","gs",paste0(data_name,"_06A")) 
enet_gs_06_fit_train_table <- enet_gs_06_fit_train_table  %>% 
  mutate(fold ="train") %>% 
  select(-"gs")
enet_gs_06_fit_all <- bind_rows(enet_gs_06_fit_train_table,enet_gs_06_fit_table)

enet_gs_fit_all <- plyr::join_all(list(enet_gs_00_fit_all,
                                       enet_gs_02_fit_all,
                                       enet_gs_04_fit_all,
                                       enet_gs_06_fit_all),by = subj_fold_site, type = "full")


enet_gi_output_list <- list(enet_gi_fit_all=enet_gi_fit_all,
                            enet_gi_00=enet_gi_00,
                            enet_gi_02=enet_gi_02,
                            enet_gi_04=enet_gi_04,
                            enet_gi_06=enet_gi_06)

enet_gs_output_list <- list(enet_gs_fit_all=enet_gs_fit_all,
                            enet_gs_00=enet_gs_00,
                            enet_gs_02=enet_gs_02,
                            enet_gs_04=enet_gs_04,
                            enet_gs_06=enet_gs_06)



saveRDS(enet_gi_output_list, paste0(datafolder, "neuro_gi_enet/" ,data_name, ".",batch_idx,".RDS" ))
saveRDS(enet_gs_output_list, paste0(datafolder, "neuro_gs_enet/" ,data_name, ".",batch_idx,".RDS" ))
