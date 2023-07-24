#!/bin/bash

# ensure the newst base image
docker pull r-base

# build the image
docker build -t dataquality/dataquier-2-shiny --progress plain .
