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
  # queue and use triage bay
  seize(resource = "triage_bay", amount = 1) %>%
  timeout(task = rexp(1, 3.0)) %>%
  release(resource = "triage_bay", amount = 1) %>%
  
  # queue and use registration clerk
  seize(resource = "registration_clerk", amount = 1) %>%
  timeout(task = rlnorm(1, meanlog=5.0, sdlog=sqrt(4.0))) %>%
  release(resource = "registration_clerk", amount = 1)
  
  # queue and use examination room
  seize(resource = "examination_room", amount = 1) %>%
  timeout(task = rnorm(1, 16.0, sqrt(4.0))) %>%
  release(resource = "examination_room", amount = 1)

  # to add...
  
  

  


env <- simmer("TreatSim")
env