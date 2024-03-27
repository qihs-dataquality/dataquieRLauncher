#!/bin/bash
dV=$(docker run --rm struckmann/dataquier-2-shiny Rscript -e 'cat(as.character(packageVersion("dataquieR"))); cat("\n")')
lV=$(docker run --rm struckmann/dataquier-2-shiny Rscript -e 'suppressMessages(source("/root/app/dataquieRLauncher/ui.R")); cat(VERSION); cat("\n")')
V=${dV}_${lV}
echo $V

docker tag struckmann/dataquier-2-shiny packages.ship-med.uni-greifswald.de:56789/ship_docker/struckmann/dataquier-2-shiny:$V
docker push packages.ship-med.uni-greifswald.de:56789/ship_docker/struckmann/dataquier-2-shiny:$V
docker tag struckmann/dataquier-2-shiny packages.ship-med.uni-greifswald.de:56789/ship_docker/struckmann/dataquier-2-shiny:latest
docker push packages.ship-med.uni-greifswald.de:56789/ship_docker/struckmann/dataquier-2-shiny:latest


docker tag struckmann/dataquier-2-shiny dataquality/dataquier:$V
docker push dataquality/dataquier:$V

docker tag struckmann/dataquier-2-shiny dataquality/dataquier:latest
docker push dataquality/dataquier:latest
