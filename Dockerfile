FROM registry.gitlab.com/libreumg/lib/dataqualitybase/next:latest
LABEL maintainer "Stephan Struckmann <stephan.struckmann@uni-greifswald.de>"

# Support docker build . --build-arg version=2.0.1
# Note: If a file dataquieR.tar.gz exists in the docker build context root,
# this file will be installed as a latest step.
ARG BUILD_ENV=version

ENV PLATFORM="docker"

# system libraries of general use
RUN apt-get clean && rm -rf /var/cache/apt/archives/* \
    && apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    libsodium-dev \
    libpq-dev \
    cmake \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# system library dependency for the euler app
RUN apt-get clean && rm -rf /var/cache/apt/archives/* \
    && apt-get update && apt-get install -y --no-install-recommends \
    libmpfr-dev \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# remotes for installing specific version of dataquieR from the beta mirror
RUN R -e "install.packages(c('remotes'), repos='https://cloud.r-project.org/', lib=.Library.site)"

# basic shiny functionality
RUN R -e "install.packages(c('shiny', 'plumber'), repos='https://cloud.r-project.org/', lib=.Library.site)"
RUN R -e "install.packages(c('shinyjs', 'callr', 'htmltools', 'plumber'), repos='https://cloud.r-project.org/', lib=.Library.site)"
RUN R -e "install.packages(c('DT'), repos='https://cloud.r-project.org/', lib=.Library.site)"
RUN R -e "install.packages('markdown', repos='https://cloud.r-project.org/', lib=.Library.site)"
RUN R -e "install.packages('dbx', repos='https://cloud.r-project.org/', lib=.Library.site)"
RUN R -e "install.packages('RMySQL', repos='https://cloud.r-project.org/', lib=.Library.site)"
RUN R -e "install.packages('urltools', repos='https://cloud.r-project.org/', lib=.Library.site)"
RUN R -e "install.packages('RPostgres', repos='https://cloud.r-project.org/', lib=.Library.site)"

# RUN R -e 'remotes::install_github("Appsilon/shiny.info")'

## for summarytools
#RUN apt-get update && apt-get install -y \
#    libmagick++-dev tcl-dev tk-dev

# for units
RUN apt-get clean && rm -rf /var/cache/apt/archives/* \
    && apt-get update && apt-get install -y --no-install-recommends \
    libudunits2-dev \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

RUN R -e "install.packages('units', repos='https://cloud.r-project.org/', lib=.Library.site)"
#RUN R -e "install.packages('summarytools', repos='https://cloud.r-project.org/')"

ADD https://packages.qihs.uni-greifswald.de/service/rest/repository/browse/ship-snapshot-r/src/contrib/dataquieR/$version/ /root/version

# install desired version of dataquieR
RUN R -e "if (nzchar(Sys.getenv('version'))) { \
            remotes::install_version('dataquieR', version=Sys.getenv('version'), upgrade='always', dependencies=TRUE, repos=c('https://packages.qihs.uni-greifswald.de/repository/ship-snapshot-r/', 'https://cloud.r-project.org/'), lib=.Library.site) \
          } else { \
            remotes::install_version('dataquieR', upgrade='always', dependencies=TRUE, repos=c('https://packages.qihs.uni-greifswald.de/repository/ship-snapshot-r/', 'https://cloud.r-project.org/'), lib=.Library.site) \
          }"

# If dataquieR.tar.gz exists, use this version
# https://stackoverflow.com/a/46801962
COPY LICENSE dataquieR.tar.g[z] /root/
RUN if test -e /root/dataquieR.tar.gz; then \
      R CMD INSTALL -l "$(Rscript -e 'cat(.Library.site[1L])')" /root/dataquieR.tar.gz; \
    fi

# copy the app to the image and run it as an unprivileged user
RUN groupadd --gid 10001 dataquier \
    && useradd --uid 10001 --gid dataquier --home-dir /home/dataquier --create-home --shell /usr/sbin/nologin dataquier \
    && mkdir -p /opt/dataquieRLauncher /home/dataquier/tmp \
    && chown -R dataquier:dataquier /opt/dataquieRLauncher /home/dataquier \
    && chmod 700 /home/dataquier/tmp
COPY --chown=dataquier:dataquier app/dataquieRLauncher /opt/dataquieRLauncher

COPY Rprofile.site /usr/lib/R/etc/

ENV HOME=/home/dataquier \
    TMPDIR=/home/dataquier/tmp

USER 10001:10001
WORKDIR /opt/dataquieRLauncher

EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('/opt/dataquieRLauncher', port=3838, host='0.0.0.0')"]
