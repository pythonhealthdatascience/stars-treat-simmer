NSPP_PATH = 'https://raw.githubusercontent.com/TomMonks/open-science-for-sim/main/src/notebooks/01_foss_sim/data/ed_arrivals.csv'

#' Time dependent arrival profile from Nelson (2013)
#' 
#' A simple arrival profile for use with treat.sim
#' @format ## `nelson_arrivals`
#' This is a data.frame containing the following columns
#' \describe{
#'     \item{period}{0 to 480 in 60 minute intervals}
#'     \item{arrival_rate}{rate per hour}
#'     \item{arrival_rate2}{rate per minute}
#' }
#' @source 'https://raw.githubusercontent.com/TomMonks/open-science-for-sim/main/src/notebooks/01_foss_sim/data/ed_arrivals.csv'
#' 
#' @returns A data.frame
#' @importFrom RCurl getURL
#' @importFrom utils read.csv
#' @importFrom assertthat assert_that
nelson_arrivals <- function(){
  csv_data <- RCurl::getURL(NSPP_PATH)
  df <- read.csv(text=csv_data)
  
  # arrivals per minute...
  df$arrival_rate2 <- df$arrival_rate/60.0
  
  # create 60 minute increments for period
  df$period = seq(0, (nrow(df)-1)*60, by=60)
  return(df)
}