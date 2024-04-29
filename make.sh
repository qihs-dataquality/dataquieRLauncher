#!/bin/bash

# ensure the newst base image
docker pull rocker/verse:latest-daily

# build the image
docker build -t dataquality/dataquier-2-shiny --progress plain .
