For building, use the sh scripts in this folder, but adjust `make.sh` to your
needs, so far.

For adding dataquieR 2.0 to a shiny server, add something like below to
`application.yml`:

```yaml
    - id: dataquieR2
      display-name: dataquieR 2.0
      description: Run Data Quality Assessments
      container-cmd: ["R", "-e", "shiny::runApp('/root/app/dataquieRLauncher')"]
      container-image: packages.ship-med.uni-greifswald.de:56789/ship_docker/struckmann/dataquier-2-shiny:latest
      access-groups: [developers]
```
