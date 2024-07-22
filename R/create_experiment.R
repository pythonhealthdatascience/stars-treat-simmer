#' Mean and Variance of the underlying Normal Distribution
#' 
#' @description
#' Calculates the mu and sigma of the normal distribution underlying a lognormal
#' 
#'
#' @details
#' `rlnorm` from `stats` is designed to sample from the lognormal distribution. 
#' The parameters is expects are moments of the underlying normal distribution
#' Using sample mean and standard deviation this function calculates 
#' the mu and sigma of the normal distribution. 
#' @source https://blogs.sas.com/content/iml/2014/06/04/simulate-lognormal-data-with-specified-mean-and-variance.html
#' 
#' @param mean A number. Sample mean.
#' @param std A number. Sample standard deviation
#' @returns A list containing mu and sigma
#' @importFrom assertthat assert_that
#' @export
#' @examples
#' normal_moments_from_lognormal(mean = 125.0, std = 5.0)
normal_moments_from_lognormal <- function(mean, std){
  # Check that all inputs are numeric
  assertthat::assert_that(
    is.numeric(c(mean, std)),
    msg = "Mean and standard deviation parameters must be numeric"
  )
  
  phi <- sqrt(std^2 + mean^2)
  mu <- log(mean**2/phi)
  sigma <- sqrt(log(phi^2/mean^2))
  return(list("mu" = mu, "sigma" = sigma))
}


# Default values for experiment
# sign-in/triage parameters
DEFAULT_TRIAGE_MEAN <- 3.0

# registration parameters (lognormal distribution)
DEFAULT_REG_PARAMS <- normal_moments_from_lognormal(5.0, sqrt(2.0))

# examination parameters
DEFAULT_EXAM_PARAMS = list(mean=16.0, var=3.0)

# trauma/stabilisation
DEFAULT_TRAUMA_MEAN <- 90.0

# Trauma treatment (lognormal distribution)
DEFAULT_TRAUMA_TREATMENT_PARAMS <- normal_moments_from_lognormal(30.0, sqrt(4.0))

# Non trauma treatment (lognormal distribution)
DEFAULT_NON_TRAUMA_TREATMENT_PARAMS <- normal_moments_from_lognormal(13.3, sqrt(2.0))

# prob patient requires treatment given trauma
DEFAULT_NON_TRAUMA_TREAT_P <- 0.60

# proportion of patients triaged as trauma
DEFAULT_PROB_TRAUMA <- 0.12

# RESOURCE COUNTS
DEFAULT_N_TRIAGE <- 1
DEFAULT_N_REG <- 1
DEFAULT_N_EXAM <- 3

# stabilisation rooms
DEFAULT_N_TRAUMA <- 1

# Non-trauma cubicles
DEFAULT_NON_TRAUMA_CUBICLES <- 1

# trauma pathway cubicles
DEFAULT_TRAUMA_CUBICLES <- 1

#' Create a simulation experiment parameter list
#' 
#' @description
#' Create and return a list containing all of the parameters used by the 
#' treat.sim model.
#'
#' @details
#' If no parameters are passed to the function then a default experiment
#' is created.
#' 
#' Users can choose to create custom experiments by passing values to 
#' the corresponding parameters in the function.
#' 
#' @param n_triage_bays Number of triage bays
#' @param n_reg_clerks Number of booking clerks
#' @param n_exam_rooms Number of exam rooms
#' @param n_trauma_rooms Number of trauma rooms for stabilisation 
#' @param n_non_trauma_cubicles Number of non-trauma treatment cubicles
#' @param n_trauma_cubicles Number of trauma treatment cubicles
#' @param triage_mean Mean triage duration (exponential distribution)
#' @param stabilisation_mean Mean trauma stabilisation time (exponential distribution)
#' @param trauma_treat_params list - mu and sigma for trauma treatment (lognormal)
#' @param reg_params list - mu and signma for registration (lognormal)
#' @param exam_params list mu and sigma for examination time (normal)
#' @param prob_non_trauma_treat probability trauma patient requires treatment
#' @param nontrauma_treat_params list - mu and signma for non trauma cubicle treatment (lognormal)
#' @param prob_trauma probability arrival has trauma injuries
#' @param arrival_profile time dependent arrival profile
#'    The default value used is the package internal datset `nelson_arrivals`. 
#'    A new dataset should include three columns: 
#'    1. period (equally spaced 60 min intervals 0 to 1020)
#'    2. arrival_rate (per hour)
#'    3. arrival_rate2 (per minute)
#'  
#' @param log_level simmer log level. Set to 0 to hide all debug info as model runs.
#' 
#' @returns A list
#' @export
#' @examples
#' # sample from Nelson arrivals at time 20.0
#' default_experiment <- create_experiment()
#' 
#' # set number of triage bays to 3
#' default_experiment <- create_experiment(n_triage_bays=3)
create_experiment <- function(n_triage_bays=DEFAULT_N_TRIAGE,
                              n_reg_clerks=DEFAULT_N_REG,
                              n_exam_rooms=DEFAULT_N_EXAM,
                              n_trauma_rooms=DEFAULT_N_TRAUMA,
                              n_non_trauma_cubicles=DEFAULT_NON_TRAUMA_CUBICLES,
                              n_trauma_cubicles=DEFAULT_TRAUMA_CUBICLES,
                              triage_mean=DEFAULT_TRIAGE_MEAN,
                              stabilisation_mean=DEFAULT_TRAUMA_MEAN,
                              trauma_treat_params=DEFAULT_TRAUMA_TREATMENT_PARAMS,
                              reg_params=DEFAULT_REG_PARAMS,
                              exam_params=DEFAULT_EXAM_PARAMS,
                              prob_non_trauma_treat=DEFAULT_NON_TRAUMA_TREAT_P,
                              nontrauma_treat_params=DEFAULT_NON_TRAUMA_TREATMENT_PARAMS,
                              prob_trauma=DEFAULT_PROB_TRAUMA,
                              arrival_profile=nelson_arrivals,
                              log_level=LOG_LEVEL) {
  
  # create list of parameters
  experiment <- list(n_triage_bays=n_triage_bays,
                     n_reg_clerks=n_reg_clerks,
                     n_exam_rooms=n_exam_rooms,
                     n_trauma_rooms=n_trauma_rooms,
                     n_non_trauma_cubicles=n_non_trauma_cubicles,
                     n_trauma_cubicles=n_trauma_cubicles,
                     triage_mean=triage_mean,
                     stabilisation_mean=stabilisation_mean,
                     trauma_treat_params=trauma_treat_params,
                     reg_params=reg_params,
                     exam_params=exam_params,
                     prob_non_trauma_treat=prob_non_trauma_treat,
                     nontrauma_treat_params=nontrauma_treat_params,
                     prob_trauma=prob_trauma,
                     arrival_data=arrival_profile,
                     log_level=log_level)
  
  return(experiment)
}     