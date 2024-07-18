#' Non-stationary Poisson Process (NSPP) via thinning
#' 
#' @description
#' Use the current simulation time to sample an appropriate
#' inter-arrival time from a user set NSPP.  Assumes equal spaced intervals.
#'
#' @details
#' Thinning is an acceptance-rejection approach to sampling
#' inter-arrival times (IAT) from a time dependent distribution
#' where each time period follows its own exponential distribution.
#'
#' There are two random variables employed in sampling: an exponential
#' distribution (used to sample IAT) and a uniform distribution (used to accept/reject samples).
#'
#' All IATs are sampled from an Exponential distribution with the highest
#' arrival rate (most frequent). These arrivals are then rejected (thinned)
#' proportional to the ratio of the current arrival rate to the maximum
#' arrival rate.  The algorithm executes until a sample is accepted. The IAT
#' returned is the sum of all the IATs that were sampled.
#' 
#' @param simulation_time A number. The current simulation time
#' @param arrival_profile A data.frame The time dependent arrival profile
#' @param debug bool. 
#'      TRUE = printout log of thinning after a sample has been accepted.
#'      FALSE = no debug info provided.
#' @returns A number 
#' @importFrom assertthat assert_that
#' @export
#' @examples
#' # sample from Nelson arrivals at time 20.0
#' nspp_thinning(20.0, nelson_arrivals, debug=TRUE)
nspp_thinning <- function(simulation_time, arrival_profile, debug=FALSE){
  
  # quick validation of inputs
  assertthat::assert_that(
    is.numeric(simulation_time),
    msg = "simulation_time must be numeric."
  )
  
  assertthat::assert_that(
    is.data.frame(arrival_profile) ,
    msg = "Time dependent profile must be a data.frame."
  )
  
  # calc time interval: assumes intervals are of equal length
  interval <- arrival_profile$period[2] - arrival_profile$period[1]
  
  # maximum arrival rate (smallest time between arrivals)
  lambda_max <- max(arrival_profile$arrival_rate2)
  
  while(TRUE){
    # get time bucket (row of dataframe to use)
    t <- floor(simulation_time / interval) %% nrow(arrival_profile) + 1
    lambda_t <- arrival_profile$arrival_rate2[t]
    
    # set to a large number so that at least 1 sample is taken
    u <- Inf
    rejects <- -1
    
    # running total of time until next arrival
    inter_arrival_time <- 0.0
    
    # reject proportionate to lambda_t / lambda_max
    ratio <- lambda_t / lambda_max
    while(u >= ratio){
      rejects <- rejects + 1
      # sample using max arrival rate
      inter_arrival_time <- inter_arrival_time + stats::rexp(1, lambda_max)
      u <- runif(1, 0.0, 1.0)
    }
    
    if(debug){
      print({paste("Time:", simulation_time, 
                   " Rejections:", rejects, 
                   " t:", t, 
                   " lambda_t:", lambda_t, 
                   " IAT:", inter_arrival_time)})
    }
    
    return(inter_arrival_time)
  }
}