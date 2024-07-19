#' Sample a if a non-trauma patient requires treatment
#' 
#' @description
#' `sample_nt_trauma_treatment` samples if a non-trauma patient
#' requires cubicle treatment
#'
#' @details
#' The function uses the Bernouli distribution (Rlab) to sample
#' if a patient is requires treatment or not.  The return values are 
#' 1 = Treatment, 0 = No treatment
#' @param p A number: The probability the patient requires treatment
#' @importFrom Rlab rbern
#' @export
#' @examples
#' treat_flag = sample_nt_trauma_treatment(0.30)
#' 
sample_nt_trauma_treatment <- function(p){
  ifelse(rbern(1, prob = p) == 1, 1, 0)
}

#' Sample a patient type
#' 
#' @description
#' `sample_arrival_type` samples if a patient type is trauma or non-trauma
#' with a given probability.
#'
#' @details
#' The function uses the Bernoulli distribution (Rlab) to sample
#' if a patient is Trauma or Non-Trauma.  The return values are 
#' 1 = Trauma, 2 = Non-trauma.
#' @param p A number: the probability a patient has trauma on arrival
#' @importFrom Rlab rbern
#' @export
#' @examples
#' patient_type = sample_arrival_type(0.4)
#' 
sample_arrival_type <- function(p, n=1){
  ifelse(rbern(n, prob = p) == 1, 1, 2)
}