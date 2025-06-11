#!/bin/bash

docker pull packages.ship-med.uni-greifswald.de:56789/ship_docker/dataquality/dataquier:latest

docker run --rm -v /opt/dataquieR/:/home/rstudio/ packages.ship-med.uni-greifswald.de:56789/ship_docker/dataquality/dataquier:latest Rscript /home/rstudio/dataquieR/report.R
