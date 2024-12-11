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

VERSION <- "0.1.5"

# Define UI for application that draws a histogram
fillPage(
  shinyjs::useShinyjs(),
  htmlOutput(style = "min-height: 80px;", "report"),
  div(style = "height: 0px", # to make position of the siblings ignore this div
    actionButton(inputId = "show_preferences",
                 style = "position: absolute; top: 5px; right: 128px;",
                 label = "Recalculate"),
    downloadButton(outputId = "download_report",
                   style = "position: absolute; top: 5px; right: 46px;", # but w/o chaning the height of the actual button
                   label = "Report"),
    actionButton(inputId = "cancel", "Cancel computation",
                 style = "position: absolute; top: 5px; right: 46px; display: none")
  ),
  shinyjs::inlineCSS("#shiny-notification-panel { top: 5px; left: 30vw; width: 40vw; }"),
  shiny.info::version(),
  div(style = "font-size: 10px;position:fixed; bottom:2px; height:1.2em; background-color: #bbbbbb; right:2px; z-index: -99999; color: #333333",
      paste0("dataquieR v", packageVersion("dataquieR")))
)
