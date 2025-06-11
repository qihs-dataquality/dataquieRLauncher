#! /usr/bin/env Rscript

print(paste("dataquieR", packageVersion("dataquieR")))
print(Sys.time())

library(dataquieR)

config <- read.dcf("/home/rstudio/config.dcf")

config <- as.list(as.data.frame(config, stringsAsFactors=FALSE))

config[["also_print"]] <- TRUE

config[["dimensions"]] <- c("des", "int", "com", "con", "acc")

print(config)

do.call(dq_report_by, config)
