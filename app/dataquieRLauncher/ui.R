#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinyjs)

VERSION <- "0.1.0"

# Define UI for application that draws a histogram
fillPage(
  shinyjs::useShinyjs(),
  htmlOutput("report"),
  div(style = "height: 0px", # to make position of the siblings ignore this div
    downloadButton(style = "position: absolute; top: 5px; right: 20px;", # but w/o chaning the height of the actual button
                   outputId = "download_report",
                   label = "Report")
  ),
  shinyjs::inlineCSS("#shiny-notification-panel { top: 5px; width: 60vw; }"),
  h5("dataquieRLauncher"),
  # Sidebar with a slider input for number of bins
  flowLayout(style = "max-height: 80px; overflow: hidden;",
    # Show a plot of the generated distribution
    # Application title
    fileInput("meta_data", "Metadata v2"),
    fileInput("study_data", "Study Data"),
    checkboxGroupInput("dims",
                       "Dimensions",
                       inline = TRUE,
                       choices = list(
                         Integrity = "int",
                         Completeness = "com",
                         Consistency = "con",
                         Accuracy = "acc"
                       ),
                       selected = c("int", "com", "con")),
    span(
      actionButton(style = "height: 80px; width: 200px", "run", "Compute and Render Report"),
      actionButton(style = "display: none; height: 80px; width: 200px", "cancel", "Cancel computation")
    )
  ),
  shiny.info::version(),
  div(style = "font-size: 10px;position:fixed; bottom:2px; height:1.2em; background-color: #bbbbbb; right:2px; z-index: -99999; color: #333333",
      paste0("dataquieR v", packageVersion("dataquieR")))
)
