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

data_input <- readRDS(file = paste0(datafolder, "data/", dataset))%>% 
  filter(if_any(where(is.numeric), ~ !is.na(.)))
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
### processing features

# %>%
#   mutate(na_ratio = rowMeans(is.na(.)))

processed_features <- brain_features_processing(data_input = data_event_site,
                                                features_input =features_vec,
                                                session_input = event_vec)

# processed_features_na_rate <- processed_features %>% select(starts_with("X2backvs0back_ROI_"))%>%
#        mutate(na_ratio = rowMeans(is.na(.))) %>% select(-starts_with("X2backvs0back_ROI_"))

data_name <- gsub(dataset, pattern = "\\.RDS", replacement = "" )

saveRDS(processed_features, paste0(datafolder, "neuro_processed_data/" ,data_name, ".",batch_idx,".RDS" ))
