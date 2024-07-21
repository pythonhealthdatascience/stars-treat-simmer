options(dplyr.summarise.inform = FALSE)

## 9. Results analysis

get_resource_counts <- function(exp) {
  resource = c("triage_bay", 
               "registration_clerk", 
               "examination_room",
               "trauma_room",
               "trauma_treat_cubicle",
               "nontrauma_treat_cubicle")
  
  resource_counts = c(exp$n_triage_bays,
                      exp$n_reg_clerks,
                      exp$n_exam_rooms,
                      exp$n_trauma_rooms,
                      exp$n_trauma_cubicles,
                      exp$n_non_trauma_cubicles)
  
  df_resource <- data.frame(resource)
  df_resource$count <- resource_counts
  return(df_resource)
}


# assumes df is monitored arrivals
waiting_time <- function(df){
  df$waiting_time <-df$end_time - df$start_time - df$activity_time  
  return(df)
}



#' Waiting times for resources by replication 
#' 
#' @description
#' Returns the mean waiting times for resourcse by replication as a data.frame
#' 
#' @param envs simmer environments from each replication of the model
#' @returns data.frame
#' @importFrom simmer get_mon_arrivals 
#' @importFrom tidyr spread
#' @importFrom dplyr mutate group_by summarise arrange
resource_waiting_times_by_replication <- function(reps) {
  # - WAITING TIMES FOR RESOURCES - #
  
  cols <- c("resource", "replication")
  waiting_times_wide <- get_mon_arrivals(reps, per_resource=TRUE) %>%
    # waiting time = end time - start time - activity time
    waiting_time() %>% 
    # mean waiting time in each replication
    group_by(across(all_of(cols))) %>%
    # mean for each replication
    summarise(rep_waiting_time=mean(waiting_time)) %>% 
    # recode kpi names
    mutate(resource=recode(resource,
                           'triage_bay'='01a_triage_wait',
                           'registration_clerk'='02a_registration_wait',
                           'examination_room'='03a_examination_wait',
                           'nontrauma_treat_cubicle'='04a_treatment_wait(non_trauma)',
                           'trauma_room'='06a_stabilisation_wait',
                           'trauma_treat_cubicle'='07a_treatment_wait(trauma)')) %>%
    # organise
    arrange(resource) %>% 
    # long to wide format ...
    spread(resource, rep_waiting_time)
  
  return(waiting_times_wide)
}



get_resource_counts <- function(exp) {
  resource = c("triage_bay", 
               "registration_clerk", 
               "examination_room",
               "trauma_room",
               "trauma_treat_cubicle",
               "nontrauma_treat_cubicle")
  
  resource_counts = c(exp$n_triage_bays,
                      exp$n_reg_clerks,
                      exp$n_exam_rooms,
                      exp$n_trauma_rooms,
                      exp$n_trauma_cubicles,
                      exp$n_non_trauma_cubicles)
  
  df_resource <- data.frame(resource)
  df_resource$count <- resource_counts
  return(df_resource)
}


# simple calculation of total busy time / total scheduled resource time.
resource_utilisation <- function(df, scheduled_time){
  df$util = df$in_use / (scheduled_time * df$count)  
  return(df)
}


#' Resource utilisation by replication 
#' 
#' @description
#' Returns the  utilisation of resource by replication as a data.frame
#' calculation:
#' total busy time / total scheduled resource time.
#' where total scheduled time = n_resource * results collection period.
#' 
#' @param envs simmer environments
#' @param exp list of parameters for experiment
#' @param results_collection_period results collection simulation time
#' @returns data.frame
#' @importFrom simmer get_mon_arrivals 
#' @importFrom tidyr spread
#' @importFrom dplyr mutate group_by summarise recode across
#' 
resource_utilisation_by_replication <- function(reps, exp, results_collection_period){
  
  # get results dataframe broken down by resource and replication.
  cols <- c("resource", "replication")
  
  # utilisation calculation:
  # simple calculation of total busy time / total scheduled resource time.
  # where total scheduled time = n_resource * results collection period.
  util_wide <- get_mon_arrivals(reps, per_resource=TRUE) %>%
    # total activity time in each replication per resource (long format)
    group_by(across(all_of(cols))) %>%
    summarise(in_use=sum(activity_time)) %>% 
    # merge with the number of resources available
    merge(get_resource_counts(exp), by="resource", all=TRUE) %>% 
    # calculate the utilisation using scheduled resource availability
    resource_utilisation(results_collection_period) %>% 
    # drop total activity time and count of resources
    subset(select = c(replication, resource, util)) %>% 
    # recode names
    mutate(resource=recode(resource,
                           'triage_bay'='01b_triage_util',
                           'registration_clerk'='02b_registration_util',
                           'examination_room'='03b_examination_util',
                           'nontrauma_treat_cubicle'='04b_treatment_util(non_trauma)',
                           'trauma_room'='06b_stabilisation_util',
                           'trauma_treat_cubicle'='07b_treatment_util(trauma)')) %>%
    arrange(resource) %>% 
    # long to wide format...
    spread(resource, util)
  
  return(util_wide)
}



#' Number of arrivals in each replication
#' 
#' @description
#' Returns the number of arrivals by replication as a data.frame
#' 
#' @param envs simmer environments
#' @returns data.frame
#' @importFrom simmer get_n_generated
#' 
arrivals_by_replication <- function(envs){
  results <- vector()
  for(env in envs){
    results <- c(results, get_n_generated(env, "Patient"))
  }
  
  results <- data.frame(replication = c(1:length(results)), 
                        arrivals = results)
  colnames(results) <- c("replication", "00_arrivals")
  return(results)
}


#' System level KPIs
#' 
#' @description
#' Calculates mean time in system and throughput for a replication
#' 
#' @param reps list of simmer environments
#' @param rep_i replication for calculation
#' @returns data.frame
#' @importFrom simmer get_mon_attributes
#' 
system_kpi_for_rep_i <- function(reps, rep_i){
  
  # get attributes
  att <- get_mon_attributes(reps)
  
  # for speed - limit to replication number.
  data_wide <- subset(att[att$replication == rep_i,], select = c(name, key, value)) %>% 
    spread(key, value)
  
  # Patient type 1: trauma
  # take the mean and ignore patients still in pathway
  mean_time_1 = mean(data_wide[data_wide$patient_type == 1,]$total_time, na.rm = TRUE)
  
  # Patient type 2: non_trauma
  # take the mean and ignore patients still in pathway
  mean_time_2 = mean(data_wide[data_wide$patient_type == 2,]$total_time, na.rm = TRUE)
  
  # Throughput - discharges during opening hours.
  throughput <- sum(data_wide$departed, na.rm=TRUE)
  
  # store and return data.frame of results
  rep_results <- data.frame("replication" = rep_i,
                            "05_total_time(non-trauma)" = mean_time_2,
                            "08_total_time(trauma)" = mean_time_1, 
                            "09_throughput"= throughput)
  
  colnames(rep_results) = c("replication",
                            "05_total_time(non-trauma)",
                            "08_total_time(trauma)", 
                            "09_throughput")
  return(rep_results)
}


system_kpi_by_replication <- function(reps){
  # calcs total time by patient type and total throughput
  
  # empty dataframe for attribute calculations.
  att_results <- data.frame(matrix(ncol = 4, nrow = 0))
  colnames(att_results) <- c("replication", 
                             "05_total_time(non-trauma)", 
                             "08_total_time(trauma)", 
                             "_09_throughput")
  
  # add each rep separately as this works faster with pivot
  for(rep_i in 1:length(reps)){
    att_results <- rbind(att_results, system_kpi_for_rep_i(reps, rep_i))
  }
  
  # return the KPIs by replications
  return(att_results)
}


#' Function to create the replications table
#' 
#' @description
#' Accepts a list of simmer environments and converts to a data,frame
#' of replications (rows) x KPIs (cols).
#' 
#' @param reps list of simmer environments
#' @param exp list of "experiment" contains all of the model 
#'     parameters used to create the results
#' @param results_collection_period the length of time results were collected.
#' @returns data.frame
#' @importFrom assertthat assert_that
#' @importFrom tidyselect peek_vars
#' @importFrom dplyr select
#' 
#' @export
replication_results_table <- function(reps, exp, results_collection_period){
  # generate and merge all results tables on the replication column
  results_table <- arrivals_by_replication(reps) %>% 
    merge(resource_waiting_times_by_replication(reps), by="replication", all=TRUE) %>% 
    merge(resource_utilisation_by_replication(reps, exp,
                                              results_collection_period),
          by="replication", all=TRUE) %>% 
    merge(system_kpi_by_replication(reps), by="replication", all=TRUE) %>% 
    # sort by column names to get "replication" followed by ordered 00_, 01a, 01b and so on...
    select(replication, sort(tidyselect::peek_vars()))
  
  return(results_table)
}


#' Histogram of replications for a selected KPI
#' 
#' @description
#' Accepts a table of replication results and a ggplot histogram object
#' for a selected column.
#' 
#' @param rep_table data.frame containing replications (rows) and KPIs (cols)
#' @param column_name string name of the KPI to plot
#' @param unit_label string of the x-axis label unit
#' @param n_bins number of bins for the histogram
#' 
#' @returns plot
#' @importFrom ggplot2 ggplot geom_histogram xlab ylab aes
#' @importFrom tidyselect all_of
#' 
#' @export
histogram_of_replications <- function(rep_table, column_name, unit_label, n_bins=10){
  
  # Divide the x range for selected column into n_bins
  binwidth <- diff(range(select(rep_table, all_of(column_name))))/n_bins
  
  g <- ggplot(rep_table, aes(.data[[column_name]])) +
    geom_histogram(binwidth = binwidth, fill="steelblue", colour = "black") + 
    xlab(paste(column_name, " (", unit_label, ")")) + 
    ylab("Replications")
  
  return(g)
}


#' Create a summary table of multiple replications data
#' 
#' @description
#' Accepts a table of replication results and returns the mean of those
#' values in a data.frame
#' 
#' @param rep_table data.frame containing replications (rows) and KPIs (cols)
#' @param dp the number of decimal places
#' @returns data.frame
#' @importFrom assertthat assert_that
#' 
#' @seealso [replication_results_table()] to create a table of replications
#' @export
create_summary_table <- function(rep_table, dp=2){
  
  # quick validation of inputs
  assertthat::assert_that(
    is.numeric(dp),
    msg = "dp (decimal places) must be a numeric value."
  )
  
  assertthat::assert_that(
    is.data.frame(rep_table) ,
    msg = "rep_table must be a data.frame."
  )
  
  # mean of all columns, but ignore rep number
  mean_values <- data.frame(colMeans(rep_table[c(2:length(rep_table))]))
  colnames(mean_values) <- c("mean")
  return(round(mean_values, dp))
  
}