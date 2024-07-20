# SIMULATION CONFIG
# Random seed - this will be investigated for CRN
SEED <- 42

# default results collection period
DEFAULT_RESULTS_COLLECTION_PERIOD <- 60 * 19

# number of replications.
DEFAULT_N_REPS <- 5

# Show the a trace of simulated events
# 1 = show, 0 = do not show.
LOG_LEVEL <- 1


#' Perform a single replication of the model
#' 
#' @description
#' The function adds treat.sim resources to an environment.
#' The model is then run for a single replication. The environment is
#' returned for use in results analysis.
#' 
#' @param env simmer:environment
#' @param exp An experiment in list form - contains all model parameters. 
#' @param rep_number the replication number (default=1)
#' @param run_length run length of the simulation
#' @param debug_arrivals boolean flag to show debug info for the thinning process
#'  Use treat.sim::create_experiment() to generate an experiment list.
#' @returns a simmer environment
#' @importFrom simmer add_resource add_generator now run simmer
#' 
#' @seealso [create_experiment()] to create list containing default and custom experimental parameters.
#' @export
#' @examples
#' set.seed(42)
#' exp <- create_experiment(log_level=0)
#' treat_sim <- simmer::simmer("TreatSim", log_level=exp$log_level)
#' treat_sim <- single_run(treat_sim, exp)
#' print("Simulation Complete.")
single_run <- function(env, 
                       exp, 
                       rep_number=1, 
                       run_length=DEFAULT_RESULTS_COLLECTION_PERIOD, 
                       debug_arrivals=FALSE){
  # add the simmer environment to the experiment list.
  exp <- c(exp, env=env) 
  
  # Create the arrivals generator
  arrival_gen <- create_arrival_generator(exp)
  
  # create model and run.
  env %>% 
    add_resource("triage_bay", exp$n_triage_bays) %>%
    add_resource("registration_clerk", exp$n_reg_clerks) %>%
    add_resource("examination_room", exp$n_exam_rooms) %>%
    add_resource("trauma_room", exp$n_trauma_rooms) %>%
    add_resource("trauma_treat_cubicle", exp$n_trauma_cubicles) %>%
    add_resource("nontrauma_treat_cubicle", exp$n_non_trauma_cubicles) %>%
    add_generator("Patient", arrival_gen, 
                          function() nspp_thinning(now(env), exp$arrival_data, 
                                            debug=debug_arrivals), mon=2) %>% 
    run(until=run_length)
  
  # return environment and all of its results.
  return(env)
}


#' Perform multiple replications of the treat.sim model
#' 
#' @description
#' The function runs single_run in a loop and returns the list of environments
#' from each replication. The result can be used for analysis of the model
#' 
#' @param exp An experiment in list form - contains all model parameters. 
#' @param n_reps number of replications to run.
#' @param random_seed the random seed for the reps
#' @returns a list of simmer environments
#' @importFrom simmer simmer
#' 
#' @seealso [single_run()] to perform a single replication with the model
#' @export
#' @examples
# create experiment
#' exp <- create_experiment(log_level=0)
#'
#' # run 50 replications of the model
#' reps <- multiple_replications(exp, n_reps=50, random_seed=0)
multiple_replications <- function(exp, n_reps=5, random_seed=0){
  
  # set seed in once place.  No CRN
  set.seed(random_seed)
  
  # note unlike in simmer documentation we use a traditional for loop
  # instead of lapply. This allows us to separate env creation
  # from run and preserve the environment interaction between NSPP 
  # and current sim time.
  # TO DO: look again -> can treat_sim be created inside single_run()
  print("running replications...")
  reps = vector()
  for(rep in 1:n_reps){
    treat_sim <- simmer::simmer("TreatSimmer", log_level=exp$log_level)
    treat_sim <- single_run(treat_sim, exp)
    # store the latest simulation environment and its results.
    reps <- c(reps, treat_sim)
  }
  print("Complete.")
  return(reps)
}