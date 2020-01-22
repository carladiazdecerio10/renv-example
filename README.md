# Building R Docker Images with renv

This is a minimal example demonstrating how R projects using renv can be Dockerized.

## In the development phase

During the development phase of the project (eg. data exploration, model building), `renv` should be used as a project-specific package manager. The typical day-to-day `renv` is summarised below, and can also be found [here](https://rstudio.github.io/renv/articles/renv.html#workflow).

```{r}
# At the beginning of a project, initialize a new project environment with a project-specific R library

renv::init()

# Carry out development/analysis as usual. When you make changes to the project library (eg. when you install and load a new package), update the project lockfile (`renv.lock`)

renv::snapshot()
```

## Project collaboration and version control

Version controlling your `renv` lockfile allows teams to track and share changes to the project environment. The following `renv` files should be tracked by version control: 

1. `.Rprofile` - specifies R Project startup commands (eg. calls `source("renv/activate.R")` to activate `renv` project-local environment)
2. `renv.lock` - lockfile that specifies R version and R library versions, as well as the repository to install from
3. `renv/activate.R` - R script that `renv` runs on project startup to ensure session is set up properly

The `renv/library` folder contains the project-specific R library, and should not be tracked by version control. When calling `renv::init()` at the start of the project, several files will be created, including a `.gitignore` in the `renv/` subfolder. This `.gitignore` will by default ignore the `renv/library` folder.

By tracking these files and maintaining them in the remote project repository (eg. on GitHub), team members can ensure that their R development environments are consistent. 

**Collaboration workflow:**

1. During project development, a new library dependency was added to the project library by a team member. They add this dependency into the lockfile by running `renv::snapshot()` and push the updated lockfile to the remote repository. 
2. Team members can pull the changes and update their local lockfiles. **However, pulling the lockfile alone will not update the local project environment.** 
3. To update your own local project environment, you must run `renv::restore()` after pulling the updated lockfile. This will restore your project library to match the current lockfile.

## Dockerizing the project

When you are ready to Dockerize your project for deployment, you can leverage `renv` to reproduce the R library that is necessary for this project and consistent with the development environment. In the example `Dockerfile`, I've listed a high-level skeleton of the necessary steps for creating a Docker image from an R project managed by renv.


In the first section, this simply declares the base Docker image we will be building from as well as a few Linux dependencies that are commonly required for R packages.

```
FROM rocker/r-ver:3.6.0

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    apt-utils \
    libcurl4-openssl-dev \
    libssl-dev \
    wget \
    ca-certificates \
    zlib1g-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
    
```

Next, we need to install the `renv` package. For consistency, we will install version 0.9.2 of the `renv` package to match our development environment. Unfortunately, this needs to be manually defined (please let me know if you think of a clever way to automate this).

```
# Install renv
RUN R -e "install.packages('remotes', repos = c(CRAN = 'https://cloud.r-project.org'))"
RUN R -e "remotes::install_version('renv', version = '0.9.2', repos = 'https://cloud.r-project.org')"
```

After installing `renv`, we are ready to leverage the lockfile to restore the R project library.

```
COPY renv.lock /project/renv.lock

WORKDIR /project

RUN R -e 'renv::restore(repos = c(CRAN = "https://cloud.r-project.org"))'
```

Then we just copy the project codebase and execute the appropriate command.

```
COPY script.R script.R

CMD Rscript script.R
```