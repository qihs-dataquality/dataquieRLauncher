#!/bin/bash
dV=$(docker run --rm dataquality/dataquier-2-shiny Rscript -e 'cat(as.character(packageVersion("dataquieR"))); cat("\n")')
lV=$(Rscript -e 'suppressMessages(source("app/dataquieRLauncher/ui.R")); cat(VERSION); cat("\n")')
V=${dV}_${lV}
echo $V

docker tag dataquality/dataquier-2-shiny dataquality/dataquier:$V
docker push dataquality/dataquier:$V

docker tag dataquality/dataquier-2-shiny dataquality/dataquier:latest
docker push dataquality/dataquier:latest
