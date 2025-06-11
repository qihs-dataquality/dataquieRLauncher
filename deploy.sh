#!/bin/bash
security find-generic-password -w -s kojote.ship-med.uni-greifswald.de | ssh kojote sudo -S docker pull packages.ship-med.uni-greifswald.de:56789/ship_docker/struckmann/dataquier-2-shiny
