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
RUN R -e "remotes::install_version('renv', version = '0.9.2', repos = c(CRAN = 'https://cloud.r-project.org'))"

WORKDIR project/

# Copy files to image
COPY renv.lock renv.lock

RUN R -e 'renv::consent(provided = TRUE);renv::restore()'
#RUN Rscript "script.R"

CMD ["/bin/bash"]