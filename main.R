library(simmer)
set.seed(42)

trauma_pathway <- trajectory() %>%
  # request triage bay
  seize(resource = "triage_bay", amount = 1) %>%
  timeout(task = rexp(1, 3.0)) %>%
  release(resource = "triage_bay", amount = 1) %>%
  
  # request trauma room for stabilization
  seize(resource = "trauma_room", amount = 1) %>%
  timeout(task = rexp(1, 90.0)) %>%
  release(resource = "trauma_room", amount = 1) %>%
  
  # request treatment cubicle
  seize(resource = "trauma_treat_cubicle", amount = 1) %>%
  timeout(task = rlnorm(1, meanlog=30.0, sdlog=sqrt(4.0))) %>%
  release(resource = "trauma_treat_cubicle", amount = 1)
  

non_trauma_pathway <- trajectory() %>%
  
  # store start of waiting time.
  set_attribute("start_time", function() {now(env)}) %>%
  
  # queue and use triage bay
  seize(resource = "triage_bay", amount = 1) %>%
  
  log_(function() {paste("Triage wait time:", 
                         now(env) - get_attribute(env, "start_time"))}) %>%
  
  timeout(task = rexp(1, 3.0)) %>%
  release(resource = "triage_bay", amount = 1) %>%
  
  # queue and use registration clerk
  seize(resource = "registration_clerk", amount = 1) %>%
  timeout(task = rlnorm(1, meanlog=5.0, sdlog=sqrt(4.0))) %>%
  release(resource = "registration_clerk", amount = 1) %>%
  
  # queue and use examination room
  seize(resource = "examination_room", amount = 1) %>%
  timeout(task = rnorm(1, 16.0, sqrt(4.0))) %>%
  release(resource = "examination_room", amount = 1)

  

  
# script to run the model
env <- simmer("TreatSim") %>%
  add_resource("triage_bay", 1) %>%
  add_resource("registration_clerk", 1) %>%
  add_resource("examination_room", 3) %>%
  add_resource("trauma_room", 2) %>%
  add_resource("trauma_treat_cubicle", 1) %>%
  add_resource("nontrauma_treat_cubicle", 1) %>%
  add_generator("patient", trauma_pathway, function() rexp(1, 3.0)) 

env %>% run(until=400)

#arrivals <- get_mon_arrivals(env)
#env %>% get_mon_resources()

