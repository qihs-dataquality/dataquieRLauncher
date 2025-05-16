#!/bin/bash

docker pull dataquality/dataquier:latest

docker run --rm -v "$(pwd)":/home/rstudio dataquality/dataquier:latest Rscript /home/rstudio/report.R
