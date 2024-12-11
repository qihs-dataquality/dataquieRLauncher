popup <- shiny::modalDialog(id="preferences",
                      title = "Auswahl Spezifikationen",
                      footer = actionButton(style = "height: 80px; width: 200px", "run", "Compute and Render Report"),
                      size = "xl",
                      easyClose = FALSE,
                      fade = TRUE,
                      tabsetPanel(
                        tabPanel("General",
                          fileInput("meta_data", "Metadata v2"),
                          uiOutput("tables"),
                          checkboxGroupInput("dims",
                                             "Dimensions",
                                             inline = TRUE,
                                             choices = list(
                                               `Descriptive Statistics` = "des",
                                               Integrity = "int",
                                               Completeness = "com",
                                               Consistency = "con",
                                               Accuracy = "acc"
                                             ),
                                             selected = c("des", "int", "com", "con")),
                          htmltools::tags$script("$('#dims [value=int]').attr('disabled', true); $('#dims [value=des]').attr('disabled', true)"),
                          ),
                        tabPanel("Advanced",
                                 shiny::checkboxInput("parallel", "Use parallel computing", TRUE),
                                 shiny::numericInput("cores",
                                                     label = "Number of cores to use",
                                                     value = dataquieR::.get_internal_api(
                                                       "util_detect_cores",
                                                       version = "0.0.1")(),
                                                     min = 1,
                                                     max = dataquieR::.get_internal_api(
                                                       "util_detect_cores",
                                                       version = "0.0.1")(),
                                                     step = 1)
                        )
                      )
)
