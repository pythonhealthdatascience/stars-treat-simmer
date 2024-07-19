#' Create and return a trauma pathway simmer trajectory
#' 
#' @description
#' Trauma patients follow this process in the trajectory:
#' 
#' 1. Triage (requires triage bay)
#' 
#' 2. Stabilisation (requires trauma room)
#' 
#' 3. Treatment (requirement trauma cubicle)
#' 
#' 4. Discharge
#' 
#' @param exp An experiment in list form - contains all model parameters. 
#'  Use treat.sim::create_experiment() to generate an experiment list.
#' @returns a simmer trajectory
#' @importFrom simmer trajectory log_ set_attribute get_attribute now
#' @importFrom simmer.bricks visit
#' @importFrom stats rlnorm rexp 
#' @seealso [create_experiment()] to create list containing default and custom experimental parameters.
#' @export
#' @examples
#' default_exp <- create_experiment()
#' trauma_traj <- create_trauma_pathway(default_exp)
create_trauma_pathway <- function(exp){
  
  trauma_pathway <- simmer::trajectory(name="trauma_pathway") %>%
    simmer::set_attribute("patient_type", 1) %>%
    # log patient arrival
    simmer::log_(function() {paste("**Trauma arrival")}, level=1) %>% 
    
    # triage 
    simmer::set_attribute("start_triage_wait", function() {simmer::now(exp$env)}) %>%
    simmer.bricks::visit("triage_bay", function() rexp(1, 1/exp$triage_mean)) %>%
    simmer::log_(function() {paste("(T) Triage wait time:",
                           simmer::now(exp$env) - simmer::get_attribute(exp$env, "start_triage_wait"))},
         level=1) %>%
    
    # request trauma room for stabilization
    simmer::set_attribute("start_trauma_room_wait", function() {simmer::now(exp$env)}) %>%
    simmer.bricks::visit("trauma_room", function() rexp(1, 1/exp$stabilisation_mean)) %>%
    simmer::log_(function() {paste("(T) Trauma room wait time:",
                           simmer::now(exp$env) - simmer::get_attribute(exp$env, "start_trauma_room_wait"))},
         level=1) %>%
    
    # request treatment cubicle
    simmer::set_attribute("start_trauma_treat_wait", function() {simmer::now(exp$env)}) %>%
    simmer.bricks::visit("trauma_treat_cubicle", function() rlnorm(1, exp$trauma_treat_params$mu,
                                                                   exp$trauma_treat_params$sigma)) %>%
    simmer::log_(function() {paste("********************(T) Trauma treatment cubicle wait time:",
                           simmer::now(exp$env) - simmer::get_attribute(exp$env, "start_trauma_treat_wait"))},
         level=1) %>% 
    
    # store the total time in system 
    simmer::set_attribute("total_time", 
                  function() {simmer::now(exp$env) - simmer::get_attribute(exp$env, "start_triage_wait")})
  
  return(trauma_pathway)
}



#' Create and return a simmer::trajectory representing cubicle treatment of non-trauma patients.
#' 
#' @description
#' Simulates cubicle treatment of trauma patients (log normally distributed time)
#' 
#' @param exp An experiment in list form - contains all model parameters. 
#'  Use treat.sim::create_experiment() to generate an experiment list.
#' @returns a simmer trajectory
#' @importFrom simmer trajectory log_ seize release timeout
#' @importFrom stats rlnorm 
#' @seealso [create_experiment()] to create list containing default and custom experimental parameters.
#' @export
#' @examples
#' default_exp <- create_experiment()
#' nt_treatement_traj <- create_nt_cubicle_treatment(default_exp)
create_nt_cubicle_treatment <- function(exp){
  
  nt_cubicle_treatment <- simmer::trajectory() %>% 
    simmer::log_(function() {paste("NT patient requirement treatment")},
         level=1) %>% 
    simmer::seize(resource="nontrauma_treat_cubicle", amount=1) %>% 
    
    simmer::timeout(task = function() rlnorm(1, exp$nontrauma_treat_params$mu,                                                     
                                     exp$nontrauma_treat_params$sigma)) %>%
    simmer::release(resource = "nontrauma_treat_cubicle", amount = 1) %>% 
    simmer::log_(function() {paste("NT treatment complete")},
         level=1) %>% 
    return(nt_cubicle_treatment)
}


#' Create and return a trajectory for non-trauma patients 
#' 
#' @description
#' Simulates the process for a non-trauma patient. Logic is:
#' 
#' 1. Triage (requires triage bay)
#' 
#' 2. Registriation (requires clert)
#' 
#' 3. Examination (requires exam room)
#' 
#' 4. Probabilistic decision about treatment
#'  
#' 4.1. Treatment (requires cubicle)
#' 
#' 5. Discharge 
#' 
#' @param exp An experiment in list form - contains all model parameters. 
#'  Use treat.sim::create_experiment() to generate an experiment list.
#' @returns a simmer trajectory
#' @importFrom simmer trajectory log_ set_attribute get_attribute now branch
#' @importFrom simmer.bricks visit
#' @importFrom stats rlnorm rexp rnorm
#' @seealso [create_experiment()] to create list containing default and custom experimental parameters.
#' @export
#' @examples
#' default_exp <- create_experiment()
#' nt_traj <- create_non_trauma_pathway(default_exp)
create_non_trauma_pathway <- function(exp){
  # log messages
  ARRIVAL_MSG = "**Non-Trauma arrival**"
  TRIAGE_MSG = "(NT) Triage wait time:"
  REG_MSG = "Reg wait time:"
  EXAM_MSG = "Exam wait time:"
  EXIT_MSG = "NT Total time in system:"
  
  # optional trajectory for proportion of patients that requirement treatment
  nt_cubicle_treatment <- create_nt_cubicle_treatment(exp)
  
  non_trauma_pathway <- simmer::trajectory(name="non_trauma_pathway") %>%
    simmer::set_attribute("patient_type", 2) %>%
    # log non_trauma arrival
    simmer::log_(function() {paste(ARRIVAL_MSG)}, level=1) %>% 
    
    # store start of waiting time for log calculations
    simmer::set_attribute("start_triage_wait", function() {simmer::now(exp$env)}) %>%
    # queue and use triage bay
    simmer.bricks::visit("triage_bay", function() rexp(1, 1/exp$triage_mean)) %>%
    simmer::log_(function() {paste(TRIAGE_MSG, simmer::now(exp$env) - simmer::get_attribute(exp$env, "start_triage_wait"))},
         level=1) %>%
    
    # queue and use registration clerk
    simmer::set_attribute("start_reg_wait", function() {simmer::now(exp$env)}) %>%
    simmer.bricks::visit("registration_clerk", function() rlnorm(1, exp$reg_params$mu, 
                                                  exp$reg_params$sigma)) %>%
    simmer::log_(function() {paste(REG_MSG, simmer::now(exp$env) - simmer::get_attribute(exp$env, "start_reg_wait"))},
         level=1) %>%
    
    # queue and use examination room
    simmer::set_attribute("start_exam_wait", function() {simmer::now(exp$env)}) %>%
    simmer.bricks::visit("examination_room",  function() rnorm(1, exp$exam_params$mean, 
                                                sqrt(exp$exam_params$var))) %>%
    simmer::log_(function() {paste(EXAM_MSG, simmer::now(exp$env) - simmer::get_attribute(exp$env, "start_exam_wait"))},
         level=1) %>%
    
    # a Proportion of patients require treatment in a cubicle
    simmer::branch (
      function() sample_nt_trauma_treatment(exp$prob_non_trauma_treat), continue=T,
      nt_cubicle_treatment
    ) %>% 
    simmer::log_(function() {paste(EXIT_MSG, simmer::now(exp$env) - simmer::get_attribute(exp$env, "start_triage_wait"))},
         level=1) %>% 
    # store the total time in system 
    simmer::set_attribute("total_time", 
                  function() {simmer::now(exp$env) - simmer::get_attribute(exp$env, "start_triage_wait")})
  
  return(non_trauma_pathway)
}