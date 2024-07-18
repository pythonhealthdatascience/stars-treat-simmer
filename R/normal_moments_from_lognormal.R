#' Mean and Variance of the underlying Normal Distribution
#' 
#' @description
#' `normal_moments_from_lognormal` calculates the mu and sigma
#' of the normal distribution underlying a lognormal
#' mean and standard 
#'
#' @details
#' `rlnorm` from `stats` is designed to sample from the lognormal distribution. 
#' The parameters is expects are moments of the underlying normal distribution
#' Using sample mean and standard deviation this function calculates 
#' the mu and sigma of the normal distribution. 
#' source: https://blogs.sas.com/content/iml/2014/06/04/simulate-lognormal-data-with-specified-mean-and-variance.html
#' 
#' @param mean A number. Sample mean.
#' @param stdev A number. Sample standard deviation
#' @returns A list 
#' @export
#' @examples
#' normal_moments_from_lognormal(mean = 125.0,
#'                               std = 5.0)
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