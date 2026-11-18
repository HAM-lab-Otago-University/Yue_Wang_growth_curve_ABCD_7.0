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


#dataset <- "smri_T2_mean_total_data.RDS"
#dataset <- "antiSmallRewVsNeu_ROI_.RDS"
#print(dataset)
#dataset <- "X2backvs0back_ROI_.RDS"
### smallest dataset for test
## dataset <- "smri_T2_mean_total_data.RDS"
### biggest dataset for test
## dataset <- "rsmri_gordon_aseg_data.RDS"
## dataset <- "ab_p_demo_final_list.RDS"

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


non_imaging_vec <- "sle_act_all_site.RDS"
non_imaging_list_name = paste0(datafolder, "data/", non_imaging_vec)
non_imaging_site <- readRDS(paste0(datafolder, "data/", non_imaging_vec))


resp_input <- readRDS(file = paste0(datafolder, "data/", resp_data_set))
gen_dyn_site_age <- readRDS(file = paste0(datafolder, "data/", "gen_dyn_site_age.RDS")) %>% select(-ab_g_dyn__visit_age)


site_vec <- names(resp_input)

site_input <- site_vec[batch_idx]



### comput and process gfactor

gfactor_list <- resp_input[[site_input]]
features_gs_list <- non_imaging_site[[site_input]]

### processing the features

subj_info <- c("participant_id","ab_g_dyn__design_site","fold")
features_all <- features_gs_list %>% select(-subj_info) %>% colnames()


### get the common participants in both features and the response

common_par <- intersect(features_gs_list$participant_id,gfactor_list$participant_id)


gfactor_train <- filter(gfactor_list, fold =="train")%>% select(-fold)
gfactor_test <- filter(gfactor_list, fold =="test")%>% select(-fold)


train_gs_features <-filter(features_gs_list, fold =="train") %>% select(-fold)
test_gs_features <-filter(features_gs_list, fold =="test")%>% select(-fold)

gs_train <- gfactor_train %>% select(all_of(c("participant_id","ab_g_dyn__design_site","gs")))
gs_test <- gfactor_test %>% select(all_of(c("participant_id","ab_g_dyn__design_site","gs")))


train_gs <- left_join(gs_train,train_gs_features, by = c("participant_id","ab_g_dyn__design_site")) %>% filter(participant_id %in% common_par)
test_gs <- left_join(gs_test, test_gs_features,by = c("participant_id","ab_g_dyn__design_site"))%>% filter(participant_id %in% common_par)
gs_train_select <-select(train_gs,"gs",all_of(features_all))
gs_test_select <- select(test_gs,"gs",all_of(features_all))

### recipe
norm_recipe_gs <- recipe(gs_train_select) %>%
  update_role(all_of(features_all), new_role = "predictor")%>%
  update_role(all_of("gs"), new_role = "outcome" ) %>% 
  # 1. Process your manually ordered factors first
    # NAs here are converted into true numeric NAs and left alone
    step_ordinalscore(all_ordered_predictors()) %>% 
    # 2. Convert raw character text strings to standard unordered factors
    step_string2factor(has_type("character")) %>%
    # 3. Clean nominal variables (This explicitly handles text NAs so step_dummy doesn't crash)
    step_novel(all_nominal_predictors()) %>%
    step_unknown(all_nominal_predictors(), new_level = "unknown") %>% 
    step_other(all_nominal_predictors(), threshold = 0.01) %>% 
    # 4. Turn unordered nominal variables into 0/1 dummy matrices
    step_dummy(all_nominal_predictors(), one_hot = TRUE) %>% 
    # 5. Final feature selection cleanup (Numeric NAs pass right through this)
    step_nzv(all_predictors(), freq_cut = 99/1, unique_cut = 10)                 # Remove near-zero variance predictors
# %>% 
#   step_impute_bag(all_predictors())
# 
### parameter tuning
set.seed(123) 

tuning_cv_folds_gs <- gs_train_select  %>%
  vfold_cv(v = 10)

xgb_spec <- 
  boost_tree(
    trees = tune(), 
    min_n = tune(), 
    tree_depth = tune(), 
    learn_rate = tune(), 
    loss_reduction = tune(),
    sample_size=tune(),
    mtry = tune()
  ) %>%
  set_engine("xgboost",nthread = 1, 
             single_precision_histogram = TRUE,
             tree_method = "hist")  %>% 
  set_mode("regression") # or "classification"

xgb_workflow_gs <- 
  workflow() %>%
  add_recipe(norm_recipe_gs) %>%
  add_model(xgb_spec)


tune_ctrl <- control_race(save_pred = FALSE, 
                          verbose = TRUE,
                          parallel_over = "resamples",
                          allow_par = TRUE,
                          extract = my_extract,
                          save_workflow= FALSE
)

## automate generate grid for hyperparameters

model_grid_gs <- 
  xgb_spec %>% 
  extract_parameter_set_dials(xgb_workflow_gs)%>% 
  ## update the values of the parameters
  update(trees =trees(range = c(100, 1000)))%>%
  update(min_n =min_n(range = c(2,2000)))%>%
  update(tree_depth =tree_depth(range = c(1,10)))%>%
  update(learn_rate =learn_rate(range = c(-3, -1)))%>%
  update(loss_reduction =loss_reduction(range = c(0.01, 1.5)))%>%
  update(sample_size =sample_prop(c(0.4, 1)))%>%
  update(mtry =finalize(mtry(), gs_train_select))%>%
  grid_latin_hypercube(size = 1000)

start <- Sys.time()

tune_res_gs <- tune_race_anova(
  xgb_workflow_gs,
  resamples = tuning_cv_folds_gs,
  metrics = metric_set(rmse),
  grid = model_grid_gs,
  control= tune_ctrl
)

end <- Sys.time()


best_tune_gs <- select_best(tune_res_gs, 
                            metric = "rmse")

best_tuned_param_gs <- show_best(tune_res_gs, 
                                 metric="rmse")

final_wf_gs <- xgb_workflow_gs %>% finalize_workflow(best_tune_gs)

xgboost_gs <- list(wf_final = final_wf_gs, 
                   best_model = best_tune_gs,
                   best_param = best_tuned_param_gs)

output_list <- list(xgboost_gs = xgboost_gs,
                    train_gs = train_gs,
                    test_gs=test_gs,
                    norm_recipe_gs=norm_recipe_gs,
                    gs_train_select=gs_train_select,
                    gs_test_select=gs_test_select)

saveRDS(output_list, paste0(datafolder, "neuro_gs_stack/" ,"sle_act_all", ".",batch_idx,".RDS" ))












