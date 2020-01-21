# Example R script that runs some analysis

library(dplyr)

# How many types of irises are there in the iris dataset?
n_iris <- iris %>% 
    summarise(n_iris = length(unique(Species)))

cat("There are ", n_iris$n_iris, " species of iris flowers.")
cat("\n")
# Some weird things about using renv in our setting
cat("When on the LAN network, you may run into issues installing packages from https sources. This may be resolved by disconnecting from LAN and using SMH_PRIME.")
cat("\n")
cat("Sometimes, renv::restore() will try to look for a package version from the CRAN archive instead of the most recent list. This may be resolved by specifying a current CRAN repository during renv::restore(). Eg. renv::restore(repos = c(CRAN = 'https://cloud.r-project.org'))")