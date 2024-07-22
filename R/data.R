#' Time dependent arrival profile from Nelson (2013)
#' 
#' A simple default arrival profile for use with treat.sim
#' @format ## `nelson_arrivals`
#' This is a data.frame containing the following columns
#' \describe{
#'     \item{period}{0 to 480 in 60 minute intervals}
#'     \item{arrival_rate}{rate per hour}
#'     \item{arrival_rate2}{rate per minute}
#' }
#' @source 'https://raw.githubusercontent.com/TomMonks/open-science-for-sim/main/src/notebooks/01_foss_sim/data/ed_arrivals.csv'
"nelson_arrivals"