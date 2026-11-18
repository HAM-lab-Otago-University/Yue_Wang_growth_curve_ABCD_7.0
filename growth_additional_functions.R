## process one feature at one time
features_event_clean <- function(data_input = BISBAS_select, 
                                 features_input =BISBAS_features[1],
                                 ratio_threshold= 0.7){
  data_select <- data_input %>% select(all_of(c(subj_info_site,features_input))) %>% drop_na()%>% 
    mutate(session_id = as.factor(session_id))%>%
    mutate(session_id = factor(session_id,levels =ordered_session_vec)) %>% 
    arrange(session_id)
  session_vec <- data_select$session_id %>% unique()
  sessing_include_num <- max_par_session_all %>% filter(session_id %in% session_vec)
  data_list <- data_select %>% group_by(session_id) %>% group_split() 
  rows_data_check <- data_list %>% map(.,~ drop_na(.) %>% nrow()) %>% do.call(rbind,.)
  get_session <- unique(data_select$session_id)
  data_session_all <- tibble(session_id = get_session, count = rows_data_check[,1] )%>% 
    mutate(session_id = as.factor(session_id))%>%
    mutate(session_id = factor(session_id,levels =ordered_session_vec)) %>% 
    arrange(session_id) %>% # make sure the first session is always at the baseline of the certain test
    left_join(max_par_session_all, by = "session_id") %>% 
    mutate(ratio = count/n) 
  
  data_session_count <- data_session_all %>% 
    filter(ratio >= ratio_threshold)
  
  return(list(feature = features_input, baseline = data_session_count$session_id[1],session_select = data_session_count$session_id,
              data_session_count=data_session_count,data_session_all=data_session_all))
}


long_to_wide_session <- function(list_input = train_input[[1]]){
  session_names <-unique(list_input$session_id) %>% str_remove_all("ses-")
  features_table <- list_input %>% dplyr::select(-all_of(subj_info_site))
  subj_table <- list_input %>% dplyr::select(all_of(subj_info_site))
  table_new_names <- features_table
  names(table_new_names) <- paste0(names(features_table),"_",session_names)
  output_data <- bind_cols(subj_table,table_new_names) %>% dplyr::select(-session_id)
  return(output_data)
}



long_to_wide_site <- function(data_input = scaled_data_site[[1]]){
  train_input = data_input[["train_list"]] %>% group_by(session_id) %>% group_split()
  test_input = data_input[["test_list"]]%>% group_by(session_id) %>% group_split()
  train_output <- train_input %>% map(.,~long_to_wide_session(list_input = .))
  train_output_table <- plyr::join_all(train_output, by = subj_site,type = "full")%>% mutate(fold = "train")
  test_output <- test_input %>% map(.,~long_to_wide_session(list_input = .))
  test_output_table <- plyr::join_all(test_output, by = subj_site,type = "full")%>% mutate(fold = "test")
  output_table <- bind_rows(train_output_table,test_output_table)## checked there are no duplicates in participant ID
  return(output_table)
}




mh_features_processing_multi <- function(data_input = BISBAS_select,
                                   features_input =BISBAS_features[1],
                                   session_input = BISBAS_session
){
  ### deal with session
  baseline_input <- session_input[[features_input]][["baseline"]]
  session_vec <- session_input[[features_input]][["session_select"]]
  data_session_select <- data_input %>% 
    select(all_of(c(subj_info_site,features_input))) %>% 
    mutate(session_id = as.factor(session_id))%>%
    mutate(session_id = factor(session_id,levels =ordered_session_vec)) %>% 
    arrange(session_id) %>% 
    filter(session_id %in% session_vec)
  ### make site splits
  data_site_split <- map(site_list, ~split_func(.x,data_input = data_session_select)) 
  ### procession features by site
  
  scaled_data_site <- data_site_split %>% map(.,~mh_site_scale(split_input=., 
                                                               baseline_input = baseline_input,
                                                               features=features_input))
  #### change the scaled data from long to wide
  
  output_scaled_data <- scaled_data_site %>% map(.,~long_to_wide_site(data_input = .))
  names(output_scaled_data) <- site_char
  return(output_scaled_data)
}




mh_features_processing <- function(data_input = ph_p_covid_select,
                                         features_input =ph_p_covid_features[1],
                                         session_input = ph_p_covid_session
){
  session_current <- session_input[[features_input]]
  session_count <-nrow(session_current[["data_session_count"]])
  if(session_count == 1){
    output_list <- mh_features_one_session(data_input = data_input,
                                           features_input =features_input,
                                           session_input = session_input)
  }
  if(session_count > 1){
    output_list <- mh_features_processing_multi(data_input = data_input,
                                           features_input =features_input,
                                           session_input = session_input)
  }
  return(output_list)
}

mh_features_nominal <- function(data_input = ph_p_covid_select,
                                   features_input =ph_p_covid_features[1],
                                   session_input = ph_p_covid_session
){
  session_current <- session_input[[features_input]]
  session_count <-nrow(session_current[["data_session_count"]])
  if(session_count == 1){
    output_list <- mh_features_one_session_char(data_input = data_input,
                                           features_input =features_input,
                                           session_input = session_input)
  }
  if(session_count > 1){
    output_list <- mh_nominal_features_multi(data_input = data_input,
                                                features_input =features_input,
                                                session_input = session_input)
  }
  return(output_list)
}

mh_nominal_features_multi <- function(data_input = ab_p_demo_nominal_cleaned,
                                   features_input =ab_p_demo_nominal_features[1],
                                   session_input = ab_p_demo_nominal_session
){
  ### deal with session
  baseline_input <- session_input[[features_input]][["baseline"]]
  session_vec <- session_input[[features_input]][["session_select"]]
  data_session_select <- data_input %>% 
    select(all_of(c(subj_info_site,features_input))) %>% 
    mutate(session_id = as.factor(session_id))%>%
    mutate(session_id = factor(session_id,levels =ordered_session_vec)) %>% 
    arrange(session_id) %>% 
    filter(session_id %in% session_vec)
  ### make site splits
  data_site_split <- map(site_list, ~split_func(.x,data_input = data_session_select)) 
  ### procession features by site
  
  scaled_data_site <- data_site_split %>% map(.,~mh_site_no_scale(split_input=., 
                                                               baseline_input = baseline_input,
                                                               features=features_input))
  #### change the scaled data from long to wide
  
  output_scaled_data <- scaled_data_site %>% map(.,~long_to_wide_site(data_input = .))
  names(output_scaled_data) <- site_char
  return(output_scaled_data)
}

mh_features_one_session <- function(data_input = le_l_urban_select,
                                    features_input =le_l_urban_features[1],
                                    session_input = le_l_urban_session
){
  ### deal with session
  baseline_input <- session_input[[features_input]][["baseline"]]
  session_vec <- session_input[[features_input]][["session_select"]]
  data_session_select <- data_input %>% 
    select(all_of(c(subj_info_site,features_input))) %>% 
    mutate(session_id = as.factor(session_id))%>%
    mutate(session_id = factor(session_id,levels =ordered_session_vec)) %>% 
    arrange(session_id) %>% 
    filter(session_id %in% session_vec)
  ### make site splits
  data_site_split <- map(site_list, ~split_func(.x,data_input = data_session_select)) 
  ### procession features by site
  
  scaled_data_site <- data_site_split %>% map(.,~mh_site_scale_one_seeion(split_input=., 
                                                                          features=features_input))
  #### change the scaled data from long to wide
  
  output_scaled_data <- scaled_data_site %>% map(.,~long_to_wide_site(data_input = .))
  names(output_scaled_data) <- site_char
  return(output_scaled_data)
}

mh_features_one_session_char <- function(data_input = le_l_urban_select,
                                    features_input =le_l_urban_features[1],
                                    session_input = le_l_urban_session
){
  ### deal with session
  baseline_input <- session_input[[features_input]][["baseline"]]
  session_vec <- session_input[[features_input]][["session_select"]]
  data_session_select <- data_input %>% 
    select(all_of(c(subj_info_site,features_input))) %>% 
    mutate(session_id = as.factor(session_id))%>%
    mutate(session_id = factor(session_id,levels =ordered_session_vec)) %>% 
    arrange(session_id) %>% 
    filter(session_id %in% session_vec)
  ### make site splits
  data_site_split <- map(site_list, ~split_func(.x,data_input = data_session_select)) 
  ### procession features by site
  
  scaled_data_site <- data_site_split %>% map(.,~mh_site_scale_one_seeion_char(split_input=., 
                                                                          features=features_input))
  #### change the scaled data from long to wide
  
  output_scaled_data <- scaled_data_site %>% map(.,~long_to_wide_site(data_input = .))
  names(output_scaled_data) <- site_char
  return(output_scaled_data)
}



mh_site_scale <- function(split_input=data_site_split[[1]], 
                          baseline_input = baseline_input,
                          features=features_input){
  
  train_all <- training(split_input) %>%drop_na()
  test_all <- testing(split_input) %>%drop_na()
  ### select the variables
  
  train_baseline <- train_all %>% filter(session_id==baseline_input) 
  train_baseline_features <- train_baseline %>% dplyr::select(all_of(features))
  train_baseline_rest <- train_baseline %>% dplyr::select(-all_of(features))
  
  
  test_baseline <- test_all %>% filter(session_id==baseline_input)
  test_baseline_features <- test_baseline %>% dplyr::select(all_of(features))
  test_baseline_rest <- test_baseline %>% dplyr::select(-all_of(features))
  
  
  
  train_followup <- train_all%>%filter(session_id !=baseline_input) 
  train_followup_features <- train_followup %>% dplyr::select(all_of(features))
  train_followup_rest <- train_followup %>% dplyr::select(-all_of(features))
  
  
  test_followup <- test_all%>%filter(session_id !=baseline_input) 
  test_followup_features <- test_followup %>% dplyr::select(all_of(features))
  test_followup_rest <- test_followup %>% dplyr::select(-all_of(features))
  
  
  
  scaled_train_list <- scale_train(baseline_data = train_baseline_features,
                                   followup_data = train_followup_features)
  scaled_test_list <- scale_train(baseline_data = test_baseline_features,
                                  followup_data = test_followup_features)
  
  scaled_train_baseline_features <- scaled_train_list[["output_baseline_data"]]
  scaled_train_followup_features <- scaled_train_list[["output_followup_data"]]
  scaled_test_baseline_features <-scaled_test_list[["output_baseline_data"]]
  scaled_test_followup_features <-scaled_test_list[["output_followup_data"]]
  
  
  scaled_train_baseline_all <- bind_cols(train_baseline_rest,scaled_train_baseline_features) #%>% mutate(fold = "train")
  scaled_train_followup_all <- bind_cols(train_followup_rest,scaled_train_followup_features)#%>% mutate(fold = "train")
  scaled_test_baseline_all <- bind_cols(test_baseline_rest,scaled_test_baseline_features)#%>% mutate(fold = "test")
  scaled_test_followup_all <- bind_cols(test_followup_rest,scaled_test_followup_features)#%>% mutate(fold = "test")
  
  output_data <- list(train_list = bind_rows(scaled_train_baseline_all,scaled_train_followup_all),
                      test_list = bind_rows(scaled_test_baseline_all,scaled_test_followup_all)) 
  return(output_data)
}


join_features_to_site <- function(list_input = BISBAS_processed_list,
                                  site_input = site_char[1]
){
  features_list <- map(list_input,site_input)
  output_table <- plyr::join_all(features_list, by = subj_site_fold, type = "full")
  return(output_table)
}


mh_site_no_scale <- function(split_input=data_site_split[[1]], 
                          baseline_input = baseline_input,
                          features=features_input){
  
  train_all <- training(split_input) %>%drop_na()
  test_all <- testing(split_input) %>%drop_na()
  ### select the variables
  
  train_baseline <- train_all %>% filter(session_id==baseline_input) 
  
  test_baseline <- test_all %>% filter(session_id==baseline_input)
  
  train_followup <- train_all%>%filter(session_id !=baseline_input) 
  
  
  test_followup <- test_all%>%filter(session_id !=baseline_input) 
  
  train_baseline_all <- train_baseline #%>% mutate(fold = "train")
  train_followup_all <- train_followup #%>% mutate(fold = "train")
  test_baseline_all <- test_baseline #%>% mutate(fold = "test")
  test_followup_all <- test_followup #%>% mutate(fold = "test")
  
  output_data <- list(train_list = bind_rows(train_baseline_all,train_followup_all),
                      test_list = bind_rows(test_baseline_all,test_followup_all)) 
  return(output_data)
}


join_features_to_site <- function(list_input = BISBAS_processed_list,
                                  site_input = site_char[1]
){
  features_list <- map(list_input,site_input)
  output_table <- plyr::join_all(features_list, by = subj_site_fold, type = "full")
  return(output_table)
}

mh_site_scale_one_seeion <- function(split_input=data_site_split[[1]], 
                                     features=features_input){
  
  train_all <- training(split_input) %>%drop_na()
  train_features <- train_all %>% dplyr::select(all_of(features)) %>% scale() 
  train_scaled <- train_all %>% dplyr::select(-all_of(features)) %>% 
    mutate(feature = train_features[,1])
  names(train_scaled) <- names(train_all)
  
  test_all <- testing(split_input) %>%drop_na()
  test_features <- test_all %>% dplyr::select(all_of(features)) %>% scale() 
  test_scaled <- test_all %>% dplyr::select(-all_of(features)) %>% 
    mutate(feature = test_features[,1])
  names(test_scaled) <- names(test_all)
  
  
  output_data <- list(train_list = train_scaled,
                      test_list = test_scaled) 
  return(output_data)
}

mh_site_scale_one_seeion_char <- function(split_input = data_site_split[[1]], 
                                     features=features_input){
  
  train_all <- training(split_input) %>%drop_na()
  
  
  test_all <- testing(split_input) %>%drop_na()
  
  
  output_data <- list(train_list = train_all,
                      test_list = test_all) 
  return(output_data)
}

join_features_resp <- function(features_input = features_list[[1]],
                               resp_input = gfactor_all[[1]]){
  data_all <- left_join(resp_input,features_input, by = subj_site_fold)
  features<- features_input %>% select(-all_of(subj_site_fold)) %>% colnames()
  train_all <- data_all %>% filter(fold == "train") %>% select(-fold)
  test_all <- data_all %>% filter(fold == "test") %>% select(-fold)
  train_features_resp <- train_all %>%  select(all_of(c(features,"gi","gs")))
  train_subj_site <- train_all %>%  select(all_of(subj_site))
  
  test_features_resp <- test_all %>%  select(all_of(c(features,"gi","gs")))
  test_subj_site <- test_all %>%  select(all_of(subj_site))
  
  return(list(train_features_resp=train_features_resp,
              train_subj_site=train_subj_site,
              test_features_resp=test_features_resp,
              test_subj_site=test_subj_site,
              features=features))
}

recipe_gc <- function(list_input = processed_feature_resp[[1]],
                      resp_input = "gs"){
  train_data <- list_input[["train_features_resp"]]
  features <- list_input[["features"]]
  train_select <- train_data %>%  select(all_of(c(features,resp_input)))
  
  norm_recipe <- recipe( as.formula(paste0(resp_input,"~.")), data = train_select) %>%
    update_role(all_of(features), new_role = "predictor")%>%
    update_role(all_of(resp_input), new_role = "outcome" )%>%
    step_dummy(all_nominal()) 
  # %>% 
  #   step_impute_bag(all_predictors())
  # 
  
  preped_recipe <- norm_recipe%>%
    prep(training = train_select, retain = TRUE)
  return(list(norm_recipe= norm_recipe,preped_recipe=preped_recipe))
}

xgb_gc <- function(recipe_input = gs_list[[1]]){
  
  set.seed(123) 
  train_input <- recipe_input[["preped_recipe"]] %>% bake(new_data=NULL)
  tuning_cv_folds <- train_input  %>%
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
    set_engine("xgboost") %>% 
    set_mode("regression") # or "classification"
  
  xgb_workflow <- 
    workflow() %>%
    add_recipe(recipe_input[["norm_recipe"]]) %>%
    add_model(xgb_spec)
  
  
  tune_ctrl <- control_race(save_pred = TRUE, verbose = TRUE
                            ,parallel_over = "everything")
  
  ## automate generate grid for hyperparameters
  
  model_grid <- 
    xgb_spec %>% 
    extract_parameter_set_dials(xgb_workflow)%>% 
    ## update the values of the parameters
    update(trees =trees(range = c(100, 1000)))%>%
    update(min_n =min_n(range = c(2,2000)))%>%
    update(tree_depth =tree_depth(range = c(1,10)))%>%
    update(learn_rate =learn_rate(range = c(-3, -1)))%>%
    update(loss_reduction =loss_reduction(range = c(0.01, 1.5)))%>%
    update(sample_size =sample_prop(c(0.4, 1)))%>%
    update(mtry =finalize(mtry(), train_input))%>%
    grid_latin_hypercube(size = 200)
  
  start <- Sys.time()
  
  tune_res <- tune_race_anova(
    xgb_workflow,
    resamples = tuning_cv_folds,
    metrics = metric_set(rmse),
    grid = model_grid,
    control= tune_ctrl
  )
  
  end <- Sys.time()
  
  
  best_tune <- select_best(tune_res, 
                           metric = "rmse")
  
  best_tuned_param <- show_best(tune_res, 
                                metric="rmse")
  
  final_wf <- xgb_workflow %>% finalize_workflow(best_tune)
  
  return(list(wf_final = final_wf, 
              best_model = best_tune,
              best_param = best_tuned_param))
}


xgb_final_fit <- function(recipe_input=gs_mh_y_recipe[[1]],
                          wf_input=xgboost_gs_mh_y_fit_200[[1]],
                          data_list = processed_feature_resp[[1]],
                          resp_input = "gs"){
  train_input <- recipe_input[["preped_recipe"]] %>% 
    bake(new_data=NULL) #%>% drop_na()
  
  ##baked recipe scale the test data with the mean and sd in the training data
  test_input <-  bake( recipe_input[["preped_recipe"]],
                       new_data=data_list[["test_features_resp"]]) #%>% drop_na()
  
  model_final_fit <- fit(wf_input[["wf_final"]],data = train_input)
  model_predict <- predict(model_final_fit, new_data = test_input) 
  test_data_all <- bind_cols(data_list[["test_features_resp"]],data_list[["test_subj_site"]]) %>% 
    select(all_of(c(subj_site,resp_input)))
  
  test_pred_all <-  bind_cols(model_predict,test_data_all)%>%
    rename(model_predict = .pred) 
  
  ##processing output
  
  output_list <- vector("list",length=2)
  names(output_list) <- c(paste0("model","_final_fit"),
                          paste0("model","_predict"))
  
  output_list[[paste0("model","_final_fit")]] <- model_final_fit
  output_list[[paste0("model","_predict")]] <- test_pred_all
  return(output_list)
}


metric_gc <- function(data_input=gc_mh_pred_data[[1]],
                      resp_input = "gs"){
  cor_model <- cor(data_input$model_predict,
                   data_input[[resp_input]],
                   use = "pairwise.complete.obs")
  
  tradrsq_model <- yardstick::rsq_trad(data=data_input, 
                                       truth=all_of(resp_input), 
                                       estimate=all_of(c("model_predict")))
  
  mae_model <- yardstick::mae(data=data_input, 
                              truth=all_of(resp_input), 
                              estimate=all_of(c("model_predict")))
  
  rmse_model <- yardstick::rmse(data=data_input, 
                                truth=all_of(resp_input), 
                                estimate=all_of(c("model_predict")))
  return(tibble(correlation=cor_model,  tradrsq= tradrsq_model$.estimate ,MAE= mae_model$.estimate, RMSE=rmse_model$.estimate,
                site = unique(data_input$ab_g_dyn__design_site)))
} 


list_features_select<- function(session_list=su_y_itu_session,
                                feature_input = su_y_itu_features){
  session_size <- map(su_y_itu_session,"data_session_count") %>% 
    map(.,~dim(.)[1]) %>% unlist()
  featues_select_tibbble <- tibble(feature=feature_input,
                                   session_number =  session_size) %>% filter(session_number >0)
  return(featues_select_tibbble$feature)
}




no_session_list_process <-function( list_input=scaled_data_site[[1]]){
  train_input <- list_input[["train_list"]] %>% mutate(fold ="train")
  test_input <- list_input[["test_list"]] %>% mutate(fold ="test")
  output_table <- bind_rows(train_input,test_input)
  return(output_table)
}


mh_features_no_session <- function(data_input = mh_y_ppsss_select,
                                   features_input =mh_y_ppsss_features[1]){
  ### deal with session
  data_session_select <- data_input %>% 
    select(all_of(c("participant_id","ab_g_dyn__design_site",features_input))) 
  ### make site splits
  data_site_split <- map(site_list, ~split_func(.x,data_input = data_session_select)) 
  ### procession features by site
  
  scaled_data_site <- data_site_split %>% map(.,~mh_site_scale_one_seeion(split_input=., 
                                                                          features=features_input))
  #### change the scaled data from long to wide
  
  output_data  <- scaled_data_site %>%map(., ~no_session_list_process(list_input=.))
  
  
  
  names(output_data) <- site_char
  return(output_data)
}


mh_features_no_session_nominal <- function(data_input = mh_y_ppsss_select,
                                   features_input =mh_y_ppsss_features[1]){
  ### deal with session
  data_session_select <- data_input %>% 
    select(all_of(c("participant_id","ab_g_dyn__design_site",features_input))) 
  ### make site splits
  data_site_split <- map(site_list, ~split_func(.x,data_input = data_session_select)) 
  ### procession features by site
  
  scaled_data_site <- data_site_split %>% map(.,~mh_site_scale_one_seeion_char(split_input=., 
                                                                          features=features_input))
  #### change the scaled data from long to wide
  
  output_data  <- scaled_data_site %>%map(., ~no_session_list_process(list_input=.))
  
  
  
  names(output_data) <- site_char
  return(output_data)
}

join_features_to_site_no_ses <- function(list_input = mh_y_ppsss_processed_list,
                                         site_input = site_char[1]
){
  features_list <- map(list_input,site_input)
  output_table <- plyr::join_all(features_list, by = c("participant_id" ,"ab_g_dyn__design_site", "fold" ), type = "full")
  return(output_table)
}



med_processing_one_subj <- function(subj_input = subj_vec[12],
                                    filtered_data = data_process){
  row_input <- filtered_data %>% filter(participant_id == subj_input)
  # get the numbers of the med information
  med_info_vec <- row_input %>% select(starts_with("su_y_plus__otc__rx__id__"))  %>% do.call(rbind,.)%>% 
    as.vector()   %>% na.omit() 
  # %>% 
  #                             stringr::word(.,1) %>% as.numeric()
  ## get the information in the package
  med_class_vec <- med_info_vec %>% map(.,~rxnorm::get_atc(.,"first"))
  med_class_vec_trial <- med_class_vec %>% do.call(rbind,.) %>% as.vector() %>% unique()
  ### create a output tibble
  output_tibble <- tibble(participant_id =row_input$participant_id,session_id= row_input$session_id,
                          is_ATC_A = ifelse("alimentary tract and metabolism" %in% med_class_vec_trial, 1,0), 
                          is_ATC_B = ifelse("blood and blood forming organs" %in% med_class_vec_trial, 1,0),
                          is_ATC_C = ifelse("cardiovascular system" %in% med_class_vec_trial, 1,0),
                          is_ATC_D = ifelse("dermatologicals" %in% med_class_vec_trial, 1,0),
                          is_ATC_G = ifelse("genito urinary system and sex hormones" %in% med_class_vec_trial, 1,0),
                          is_ATC_H = ifelse("systemic hormonal preparations, excl. sex hormones and insulins" %in% med_class_vec_trial, 1,0),
                          is_ATC_J = ifelse("antiinfectives for systemic use" %in% med_class_vec_trial, 1,0),
                          is_ATC_L = ifelse("antineoplastic and immunomodulating agents" %in% med_class_vec_trial, 1,0),
                          is_ATC_M = ifelse("musculo-skeletal system" %in% med_class_vec_trial, 1,0),
                          is_ATC_N = ifelse("nervous system" %in% med_class_vec_trial, 1,0),
                          is_ATC_P = ifelse("antiparasitic products, insecticides and repellents" %in% med_class_vec_trial, 1,0),
                          is_ATC_R = ifelse("respiratory system" %in% med_class_vec_trial, 1,0),
                          is_ATC_S = ifelse("sensory organs" %in% med_class_vec_trial, 1,0),
                          is_ATC_V = ifelse("various" %in% med_class_vec_trial, 1,0)) 
  return(output_tibble)
}




med_processing <- function(session_input = su_y_plus_session_count$session_id[7],
                           data_input = su_y_plus_select,
                           data_filter = su_y_plus_session_na_sum
){
  data_input_session <- data_input %>% filter(session_id == session_input)
  data_filter_session <- data_filter %>% filter(session_id == session_input)
  
  data_process <- data_input_session %>% filter(participant_id %in% data_filter_session$participant_id )
  data_no_process <- data_input_session %>% filter(!participant_id %in% data_filter_session$participant_id )
  
  subj_vec <- data_filter_session$participant_id
  #trial_subj_vec <- subj_vec[1:5]
  
  # med_info_table_trial <- trial_subj_vec %>% map(.,~med_processing_one_subj(subj_input = ., filtered_data = data_input_filter )) %>% 
  #                        do.call(rbind,.)
  
  med_info_table <- subj_vec %>%furrr::future_map(.,~med_processing_one_subj(subj_input = ., filtered_data = data_process )) %>% 
    do.call(rbind,.) 
  
  data_process_site <- data_process %>% select(all_of(subj_info_site))
  
  med_info_output <- full_join(med_info_table,data_process_site, by = subj_info)
  
  med_no_table <- tibble(participant_id = data_no_process$participant_id,
                         session_id = data_no_process$session_id,
                         ab_g_dyn__design_site=data_no_process$ab_g_dyn__design_site,
                         is_ATC_A=0, 
                         is_ATC_B = 0,
                         is_ATC_C = 0,
                         is_ATC_D = 0,
                         is_ATC_G = 0,
                         is_ATC_H = 0,
                         is_ATC_J = 0,
                         is_ATC_L = 0,
                         is_ATC_M = 0,
                         is_ATC_N = 0,
                         is_ATC_P = 0,
                         is_ATC_R = 0,
                         is_ATC_S = 0,              
                         is_ATC_V = 0 )
  med_output <- bind_rows(med_info_output,med_no_table)
  
  return(med_output)
}


get_session_used <- function(list_input =mh_y_bisbas_session){
  trial_list <- map(list_input,"data_session_count")
  trial_column <-  map(trial_list,~select(.,session_name)) %>% do.call(rbind,.)
  print(unique(trial_column$session_name))
}




detect_num_obs<- function(data_input = sumCog_select,
                          id_input = c("participant_id", "ab_g_dyn__design_site")){
  features_vec <- data_input %>% select(-c(id_input,"session_id")) %>% colnames()
  
  sumCog_wide <- data_input %>%
    pivot_wider(
      # Keep participant and site as rows
      id_cols = id_input, 
      
      # Use session_id to differentiate the new columns
      names_from = session_id, 
      
      # Grab values from all your continuous score columns
      values_from = features_vec,
      
      # Puts the session name first in the new column titles (e.g., ses-00A_picvcb...)
      names_glue = "{session_id}_{.value}" 
    )%>% 
    filter(if_any(everything(), ~ !is.na(.)))
  
 return(sumCog_wide$participant_id %>% unique() %>% length())
}