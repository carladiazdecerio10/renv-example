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
    
# Install renv
RUN R -e "install.packages('remotes', repos = c(CRAN = 'https://cloud.r-project.org'))"
RUN R -e "remotes::install_version('renv', version = '0.9.2', repos = 'https://cloud.r-project.org')"

COPY renv.lock /project/renv.lock

WORKDIR /project

RUN R -e 'renv::restore(repos = c(CRAN = "https://cloud.r-project.org"))'

COPY script.R script.R

CMD Rscript script.R