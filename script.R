# Example R script that runs some analysis

library(dplyr)

# How many types of irises are there in the iris dataset?
n_iris <- iris %>% 
    summarise(n_iris = length(unique(Species)))

cat("There are ", n_iris$n_iris, " species of iris flowers.")
