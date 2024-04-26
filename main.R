library(simmer)
library(Rlab)

set.seed(42)

#' Sample a patient type
#' 
#' @description
#' `sample_arrival_type` samples if a patient type is trauma or non-trauma
#' with a given probability.
#'
#' @details
#' The function uses the Bernouli distribution (Rlab) to sample
#' if a patient is Trauma or Non-Trauma.  The return values are 
#' 1 = Trauma, 2 = Non-trauma.
sample_arrival_type <- function(){
  if (rbern(1, prob = 0.1) == 1) {
    return(1)
  } else{
    return (2)
  }
}


trauma_pathway <- trajectory(name="trauma_pathway") %>%
  log_(function() {paste("**Trauma arrival")}) %>% 
  
  # request triage bay
  set_attribute("start_triage_wait", function() {now(env)}) %>%
  seize(resource = "triage_bay", amount = 1) %>%
  timeout(task = rexp(1, 3.0)) %>%
  release(resource = "triage_bay", amount = 1) %>%
  
  log_(function() {paste("Triage wait time:",
                   now(env) - get_attribute(env, "start_triage_wait"))}) %>%
  
  # request trauma room for stabilization
  seize(resource = "trauma_room", amount = 1) %>%
  timeout(task = rexp(1, 90.0)) %>%
  release(resource = "trauma_room", amount = 1) %>%
  
  # request treatment cubicle
  seize(resource = "trauma_treat_cubicle", amount = 1) %>%
  timeout(task = rlnorm(1, meanlog=30.0, sdlog=sqrt(4.0))) %>%
  release(resource = "trauma_treat_cubicle", amount = 1)
  

non_trauma_pathway <- trajectory(name="non_trauma_pathway") %>%
  log_(function() {paste("**Non-Trauma arrival")}) %>% 
  # store start of waiting time.
  set_attribute("start_triage_wait", function() {now(env)}) %>%
  
  # queue and use triage bay
  seize(resource = "triage_bay", amount = 1) %>%
  
  log_(function() {paste("Triage wait time:",
                         now(env) - get_attribute(env, "start_triage_wait"))}) %>%
  
  timeout(task = rexp(1, 3.0)) %>%
  release(resource = "triage_bay", amount = 1) %>%
  
  # queue and use registration clerk
  set_attribute("start_reg_wait", function() {now(env)}) %>%
  seize(resource = "registration_clerk", amount = 1) %>%
  log_(function() {paste("Reg wait time:",
                         now(env) - get_attribute(env, "start_reg_wait"))}) %>%
  
  timeout(task = rlnorm(1, meanlog=5.0, sdlog=sqrt(4.0))) %>%
  release(resource = "registration_clerk", amount = 1) %>%
  
  # queue and use examination room
  set_attribute("start_exam_wait", function() {now(env)}) %>%
  seize(resource = "examination_room", amount = 1) %>%
  log_(function() {paste("Reg wait time:",
                         now(env) - get_attribute(env, "start_exam_wait"))}) %>%
  timeout(task = rnorm(1, 16.0, sqrt(4.0))) %>%
  release(resource = "examination_room", amount = 1)

  
  
patient_arrival <- trajectory() %>%
  branch(
    patient_has_trauma, continue=T,
      trauma_pathway,
      non_trauma_pathway
  ) %>%
  log_(function() {paste("EXIT************")})
  
  
# script to run the model
env <- simmer("TreatSim") %>%
  add_resource("triage_bay", 1) %>%
  add_resource("registration_clerk", 1) %>%
  add_resource("examination_room", 3) %>%
  add_resource("trauma_room", 2) %>%
  add_resource("trauma_treat_cubicle", 1) %>%
  add_resource("nontrauma_treat_cubicle", 1) %>%
  add_generator("patient", patient_arrival, function() rexp(1, 10.0))

env %>% run(until=400) %>% invisible
#arrivals <- get_mon_arrivals(env)
#env %>% get_mon_resources()

