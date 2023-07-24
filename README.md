# Data Quality in Epidemiological Research

Data quality assessments guided by a
[data quality framework introduced by Schmidt and colleagues, 2021](doi:10.1186/s12874-021-01252-7)
target the data quality dimensions integrity, completeness, consistency, and
accuracy. The scope of applicable functions rests on the
availability of extensive metadata which can be provided in
spreadsheet tables. Either standardized (e.g. as 'html5' reports) or
individually tailored reports can be generated. For an introduction
into the specification of corresponding metadata, please refer to the
[package website](https://dataquality.qihs.uni-greifswald.de/Annotation_of_Metadata.html).

This docker image provides a Shiny app to easily run data quality assessments.
It uses the dataquieR R package
available from [CRAN](https://cran.r-project.org/package=dataquieR).

## Tags

The tags display the version of the `dataquieR` package and of its Shiny UI:
`dataquality/dataquier:<dataquieR version>_<dataquieRLauncher version>`

## Usage

```bash
docker run --rm -p3838:3838 dataquality/dataquier
```

Then navigate your browser to 

http://localhost:3838/

The image does not use TLS and it uses the port 3838 internally. You can find
the image sources at https://github.com/qihs-dataquality/dataquieRLauncher and 
the R package is hosted at https://gitlab.com/libreumg/dataquier.

The RAM usage of the image depends on the size of the assessed data files, 
mostly. You should configure your Docker to allow at least 6 GBytes of RAM
by the container to compute `dataquieR`'s example reports.

The launcher underlies the same license conditions as the `dataquieR` package,
i.e.,	the "BSD 2-clause license", see [below](#license).

# License

BSD 2-Clause License, see LICENSE.

# Internal notes

For building, use the sh scripts in this folder, but adjust `make.sh` to your
needs, so far.

For adding `dataquieR 2.0.1` to a `shinyproxy` server, add something like below to
`application.yml`:

```yaml
    - id: dataquieR2
      display-name: dataquieR 2.0.1
      description: Run Data Quality Assessments
      container-cmd: ["R", "-e", "shiny::runApp('/root/app/dataquieRLauncher')"]
      container-image: dataquality/dataquier:latest
      access-groups: [developers]
```
