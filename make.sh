#!/bin/bash
# ensure the newst base image
docker pull registry.gitlab.com/libreumg/lib/dataqualitybase:latest

# Build the current local dataquieR first, then update the docker image
#if [ /Users/struckmanns/git/gitlab/QualityIndicatorFunctions/QualityIndicatorFunctions/ -nt dataquieR.tar.gz ] ; then
#  R -e 'devtools::document("/Users/struckmanns/git/gitlab/QualityIndicatorFunctions/QualityIndicatorFunctions/")' &&
#    R -e 'devtools::build("/Users/struckmanns/git/gitlab/QualityIndicatorFunctions/QualityIndicatorFunctions/", manual = TRUE, path = "dataquieR.tar.gz")' ||
#      exit -1
#fi
docker build -t struckmann/dataquier-2-shiny --progress plain --platform linux/amd64 .


# build the image
docker build -t dataquality/dataquier-2-shiny --progress plain .
