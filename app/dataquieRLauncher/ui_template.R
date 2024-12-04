popup <- shiny::modalDialog(id="preferences",
                      title = "Auswahl Spezifikationen",
                      footer = actionButton(style = "height: 80px; width: 200px", "run", "Compute and Render Report"),
                      size = "xl",
                      easyClose = FALSE,
                      fade = TRUE,
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
                      htmltools::tags$script("$('#dims [value=int]').attr('disabled', true); $('#dims [value=des]').attr('disabled', true)")
                      )

