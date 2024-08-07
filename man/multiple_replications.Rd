% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/run.R
\name{multiple_replications}
\alias{multiple_replications}
\title{Perform multiple replications of the treat.sim model}
\usage{
multiple_replications(exp, n_reps = 5, random_seed = 0)
}
\arguments{
\item{exp}{An experiment in list form - contains all model parameters.}

\item{n_reps}{number of replications to run.}

\item{random_seed}{the random seed for the reps}
}
\value{
a list of simmer environments
}
\description{
The function runs single_run in a loop and returns the list of environments
from each replication. The result can be used for analysis of the model
}
\examples{
exp <- create_experiment(log_level=0)

# run 50 replications of the model
reps <- multiple_replications(exp, n_reps=50, random_seed=0)
}
\seealso{
[single_run()] to perform a single replication with the model
}
