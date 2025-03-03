FROM r-base:4.3.2
LABEL maintainer "Gordon A. Shumway <alf@star-treck.melmac.gov>"

# system libraries of general use
RUN apt-get update && apt-get install -y \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    libsodium-dev \
    cmake

# system library dependency for the euler app
RUN apt-get update && apt-get install -y \
    libmpfr-dev

# basic shiny functionality
RUN R -e "install.packages(c('shiny', 'plumber'), repos='https://cloud.r-project.org/')"
RUN R -e "install.packages(c('shiny.info', 'shinyjs', 'callr', 'htmltools', 'plumber'), repos='https://cloud.r-project.org/')"
RUN R -e "install.packages(c('DT'), repos='https://cloud.r-project.org/')"
RUN R -e "install.packages('dataquieR', dependencies = TRUE, repos='https://cloud.r-project.org/')"
RUN R -e "install.packages('markdown', repos='https://cloud.r-project.org/')"

RUN apt-get update && apt-get install -y \
    libmagick++-dev
RUN R -e "install.packages('summarytools', repos='https://cloud.r-project.org/')"

RUN apt-get update && apt-get install -y \
    libudunits2-dev
RUN R -e "install.packages('units', repos='https://cloud.r-project.org/')"

RUN apt-get update && apt-get install -y \
    tcl-dev tk-dev
RUN R -e "install.packages('summarytools', repos='https://cloud.r-project.org/')"

RUN R -e "install.packages('remotes', repos='https://cloud.r-project.org/')"


# install desired version of dataquieR
RUN R -e "if (nzchar(Sys.getenv('version'))) { \
            remotes::install_version('dataquieR', version=Sys.getenv('version'), upgrade='always', dependencies=TRUE, repos=c('https://packages.qihs.uni-greifswald.de/repository/ship-snapshot-r/', 'https://cloud.r-project.org/')) \
          } else { \
            remotes::install_version('dataquieR', upgrade='always', dependencies=TRUE, repos=c('https://packages.qihs.uni-greifswald.de/repository/ship-snapshot-r/', 'https://cloud.r-project.org/')) \
          }"

# If dataquieR.tar.gz exists, use this version
# https://stackoverflow.com/a/46801962
COPY LICENSE dataquieR.tar.g[z] /root/
RUN if test -e /root/dataquieR.tar.gz; then \
      R CMD INSTALL /root/dataquieR.tar.gz; \
    fi

# copy the app to the image
RUN mkdir /root/app
COPY app /root/app

COPY Rprofile.site /usr/lib/R/etc/

EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('/root/app/dataquieRLauncher')"]
# CMD ["R", "-e", "plumber::plumb(file='/root/test/plumber.R')$run(port = as.integer(eval(formals(shiny::runApp)$port)), host = eval(formals(shiny::runApp)$host), docs = TRUE, debug = FALSE, swaggerCallback = NULL)"]
