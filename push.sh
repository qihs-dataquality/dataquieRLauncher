#!/bin/bash
dV=$(docker run --rm packages.qihs.uni-greifswald.de:56789/ship-docker/dataquality/dataquier-2-shiny-nako Rscript -e 'cat(as.character(packageVersion("dataquieR"))); cat("\n")')
lV=$(Rscript -e 'suppressMessages(source("app/dataquieRLauncher/ui.R")); cat(VERSION); cat("\n")')
V=${dV}_${lV}
echo $V

docker tag packages.qihs.uni-greifswald.de:56789/ship-docker/dataquality/dataquier-2-shiny-nako packages.qihs.uni-greifswald.de:56789/ship-docker/dataquality/dataquier-nako:$V
docker push packages.qihs.uni-greifswald.de:56789/ship-docker/dataquality/dataquier-nako:$V

docker tag packages.qihs.uni-greifswald.de:56789/ship-docker/dataquality/dataquier-2-shiny-nako packages.qihs.uni-greifswald.de:56789/ship-docker/dataquality/dataquier-nako:latest
docker push packages.qihs.uni-greifswald.de:56789/ship-docker/dataquality/dataquier-nako:latest
