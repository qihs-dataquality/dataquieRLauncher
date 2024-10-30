#!/bin/bash

# ensure the newst base image
docker pull rocker/verse:latest-daily

# build the image
# docker build -t dataquality/dataquier-2-shiny --progress plain .

docker build -t packages.qihs.uni-greifswald.de:56789/ship-docker/dataquality/dataquier-2-shiny-nako --progress plain .
