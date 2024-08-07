library(treat.sim)

# create experiment and hide all logging
default_exp <- create_experiment(log_level=0)

# run 10 replications of the experiment 
envs <- multiple_replications(default_exp, n_reps=50)

# process simmer environments into simple data.frame of reps by KPIs
rep_table <- replication_results_table(envs, default_exp, 60 * 19)

# printout summary table
create_summary_table(rep_table)

g <- histogram_of_replications(rep_table, "09_throughput", "patients")
g
