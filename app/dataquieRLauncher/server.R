#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinyjs)

# Define server logic required to draw a histogram
function(input, output, session) {

  shinyjs::runjs('$("#dims [value=int]").attr("disabled", true)')
  shinyjs::hide("download_report")

  my_basedir <- getwd()

  withdirs <-
    list.files(file.path(my_basedir, "www"),
               all.files = TRUE,
               include.dirs = TRUE,
               full.names = TRUE,
               pattern = "tmp_rep_dir_.*")
  dirs <- withdirs[dir.exists(withdirs)]

  if (length(dirs) > 0)
    unlink(dirs, recursive = TRUE, force = TRUE, expand = FALSE)

  d <- tempfile(tmpdir = file.path("www"), ## no absolute path, otherwise, code below assuming startsWith www fails, and maybe more...
                pattern = "tmp_rep_dir_")
  dir.create(d)

  cat("No Report to Display", file = file.path(d, "report.html"))

  e <- new.env(parent = emptyenv())
  e$mtm <- as.character(file.mtime(file.path(d, "report.html")))

  rx <- NULL

  e$progress <- NULL

  output$download_report <- downloadHandler(
    filename <- function() {
      "report.zip"
    },
    content <- function(file) {
      oldwd <- setwd(d)
      on.exit(setwd(oldwd))
      setwd("..")
      if (.Platform$OS.type == "unix") {
        if (file.exists("report") &&
            Sys.readlink("report") != "") {
          try(unlink("report"), silent = TRUE)
        }
        if (file.exists("report")) {
          shiny::showNotification(
            sprintf("There is already a non-symblink %s. So, I cannot give the report folder in the zip file a nice name.",
                    dQuote(file.path(getwd(), "report")))
            )
          bn <- basename(d)
        } else {
          file.symlink(basename(d), "report")
          fullnm <- force(file.path(getwd(), "report"))
          on.exit(unlink(fullnm, recursive = TRUE, force = TRUE), add = TRUE)
          bn <- "report"
        }
      } else {
        bn <- basename(d)
        shiny::showNotification("On Windows, I cannot give the report folder in the zip file a nice name")
      }
      report_files <- file.path(bn, list.files(bn, all.files = TRUE, recursive = TRUE, no.. = TRUE))
      zip(zipfile = file, files = report_files)
    },
    contentType = "application/zip"
  )

  # https://www.r-bloggers.com/2020/04/asynchronous-background-execution-in-shiny-using-callr/
  long_run <- eventReactive(input$run, {
    if (is.null(input$meta_data) ||
        is.null(input$meta_data$datapath) ||
        !file.exists(input$meta_data$datapath)) {
      try(unlink(input$meta_data$datapath), silent = TRUE)
      shinyjs::reset("meta_data")
      md <- NULL
    } else {
      md <- input$meta_data$datapath
    }
    running <- FALSE
    try({
      running <- e$process$is_alive()
    }, silent = TRUE)
    if (running) {
      shinyjs::logjs("Process is still running, cancel first")
      return(e$process)
    }
    shinyjs::show("cancel")
    shinyjs::hide("run")
    if (!is.null(e$progress)) {
      e$progress$close()
      e$progress <- NULL
    }
    try(e$process$kill_tree(), silent = TRUE)
    if (dir.exists(d) && startsWith(d, file.path("www", "")))
      try(unlink(file.path(d, "progress*"), recursive = TRUE, force = TRUE,
                 expand = TRUE))
    # remove all notifications, when shiny app starts, the new shiny progress
    # indicator uses notifications, but we want to hide the close 'x'. for the
    # progress indicator (w/o hindering the user from closing existing
    # notifications)
    shinyjs::runjs('Shiny.notifications.show("test"); $("#shiny-notification-panel").remove()')
    e$progress <- Progress$new(min = 0, max = 100)
    # Hide the x for the progress notification
    shinyjs::runjs('$(".shiny-notification-close").hide()')
    e$msg_shown <- list()
    e$wrn_shown <- list()
    e$err_shown <- list()
    e$progress$set(message = "Perparing computation...")
    e$mtm <- ""
    x <- callr::r_bg(
      stderr = "",
      stdout = "",
      wd = d,
      func = function(study_data, meta_data, d, dims) {
        library(dataquieR)
        # see https://stackoverflow.com/a/34520450/4242747 -- which,
        # unfortunately still is the trueth (June, 1st of 2023, STS)
        # Not using shiny::withProgress(), this lacks process control, but is
        # supported by dataquieR, if it would be used
        # Here, we need to run the job in r_bg, so that we can cancel it from
        # the single threaded Shiny app. This requireds a specific progress
        # handler, which can now be registered for dataquieR as follows:
        options(dataquieR.progress_fkt = function(percent, is_rstudio, is_shiny, is_cli, e) {
          cat(as.character(percent), file = file.path(getwd(), "progress"), append = FALSE) # perform all IPC via files to avoid fiddling aroudn with pipes
        },
        dataquieR.progress_msg_fkt = function(status, msg = "", is_rstudio, is_shiny, e) { # TODO: split status and msg to different files
          cat(status, msg, file = file.path(getwd(), "progress_msg"), append = FALSE) # perform all IPC via files to avoid fiddling aroudn with pipes
        })
        withCallingHandlers(
          warning = function(w) {
            cat(paste(conditionMessage(w), collapse = " "),
                sep = "\n",
                file = file.path(d, "warnings"),
                append = TRUE)
            tryInvokeRestart("muffleWarning")
          },
          message = function(m) {
            cat(paste(conditionMessage(m), collapse = " "),
                sep = "\n",
                file = file.path(d, "messages"),
                append = TRUE)
            tryInvokeRestart("muffleMessage")
          },
          expr = {
            if (is.null(meta_data))
              meta_data <- formals(function(x){})[["x"]] # tweak to save missing argument explicitly
            error <- try(report <- dataquieR::dq_report2(study_data = study_data,
                                                         meta_data_v2 = meta_data,
                                                         dimensions = dims), silent = TRUE)
            if (inherits(error, "try-error")) {
              cat(capture.output(traceback()),
                  sep = "\n",
                  file = file.path(d, "error_trace"),
                  append = FALSE)
              cat(conditionMessage(attr(error, "condition")),
                  file = file.path(d, "error"))
              cat(paste(deparse1(conditionCall(attr(error, "condition"))),
                        collapse = "\n"),
                  sep = "\n",
                  file = file.path(d, "error_trace"),
                  append = TRUE)
              error <- TRUE
            } else {
              error <- FALSE
            }
            if (!error) {
              if (dir.exists(d) && startsWith(d, file.path("www", "")))
                try(unlink(file.path(d, "*"), recursive = TRUE, force = TRUE,
                           expand = TRUE))
              error <- try(print(report, dir = d, view = FALSE), silent = TRUE)
              if (inherits(error, "try-error")) {
                cat(capture.output(traceback()),
                    sep = "\n",
                    file = file.path(d, "error_trace"),
                    append = FALSE)
                cat(conditionMessage(attr(error, "condition")),
                    file = file.path(d, "error"))
                cat(paste(deparse1(conditionCall(attr(error, "condition"))),
                          collapse = "\n"),
                    sep = "\n",
                    file = file.path(d, "error_trace"),
                    append = TRUE)
              }
              rm(error)
            }
          }
        )
        file.exists(file.path(d, "renderinfo.json")) # one of the last files written
      },
      args = list(study_data = input$study_data$datapath,
                       meta_data = md,
                       d = file.path(getwd(), d),
                  dims = input$dims),
      supervise = TRUE
    )
    e$process <- x
    return(x)
  })

  update_needed <- reactive({
    if (is.null(session) || session$isClosed()) {
      return(FALSE)
    }
    invalidateLater(millis = 1000, session = session)

    if (long_run()$is_alive()) {
      x <- FALSE
    } else {
      x <- TRUE
    }

    x <- x && file.exists(file.path(d, "report.html")) &&
      e$mtm != as.character(file.mtime(file.path(d, "report.html")))

    return(x)
  })

  observeEvent(input$cancel, {
    try(e$process$kill_tree(), silent = TRUE)
  })

  observeEvent(update_needed(), {
    if (file.exists(file.path(d, "messages"))) {
      try(unlink(file.path(d, "messages_shown"), force = TRUE), silent = TRUE)
      nmsg <- readLines(file.path(d, "messages"))
      shinyjs::logjs(nmsg)
      nmsg <- unique(nmsg)
      nmsg <- nmsg[!(nmsg %in% names(e$msg_shown))]
      e$msg_shown[nmsg] <- TRUE
      nmsg <- paste(nmsg, collapse = "\n")
      if (trimws(nmsg) != "")
        shiny::showNotification(nmsg, duration = 2, type = "message")
      file.rename(file.path(d, "messages"),
                  file.path(d, "messages_shown"))
    }
    if (file.exists(file.path(d, "warnings"))) {
      try(unlink(file.path(d, "warnings_shown"), force = TRUE), silent = TRUE)
      warnmsg <- readLines(file.path(d, "warnings"))
      shinyjs::logjs(warnmsg)
      warnmsg <- unique(warnmsg)
      warnmsg <- warnmsg[!(warnmsg %in% names(e$wrn_shown))]
      e$wrn_shown[warnmsg] <- TRUE
      warnmsg <- paste(warnmsg, collapse = "\n")
      if (trimws(warnmsg) != "")
        shiny::showNotification(warnmsg, duration = 20, type = "warning")
      file.rename(file.path(d, "warnings"),
                  file.path(d, "warnings_shown"))
    }
    if (file.exists(file.path(d, "error"))) {
      try(unlink(file.path(d, "error_shown"), force = TRUE), silent = TRUE)
      errmsg <- readLines(file.path(d, "error"))
      shinyjs::logjs(errmsg)
      errmsg <- unique(errmsg)
      errmsg <- errmsg[!(errmsg %in% names(e$err_shown))]
      e$err_shown[errmsg] <- TRUE
      errmsg <- paste(errmsg, collapse = "\n")
      if (trimws(errmsg) != "")
        shiny::showNotification(errmsg, duration = NULL, type = "error")
      file.rename(file.path(d, "error"),
                  file.path(d, "error_shown"))
    }
    if (file.exists(file.path(d, "error_trace"))) {
      try(unlink(file.path(d, "error_trace_shown"), force = TRUE), silent = TRUE)
      errmsg <- paste(readLines(file.path(d, "error_trace")), collapse = "\n")
      shinyjs::logjs(errmsg)
      file.rename(file.path(d, "error_trace"),
                  file.path(d, "error_trace_shown"))
    }
    if (update_needed()) {
      # render the background process message to the UI
      output$report <- shiny::renderUI({
        e$mtm <- as.character(file.mtime(file.path(d, "report.html")))
        htmltools::tags$iframe(
          style = "width: 100vw; height: calc(100vh - 130px); border: 0;",
          src = file.path(basename(d), "report.html")
        ) # https://stackoverflow.com/a/59005942/4242747
      })

      try(e$progress$close(), silent = TRUE)
      e$progress <- NULL
      if (file.exists(file.path(d, "renderinfo.json"))) {
        try(unlink(input$study_data$datapath), silent = TRUE)
        shinyjs::reset("study_data")
        try(unlink(input$meta_data$datapath), silent = TRUE)
        shinyjs::reset("meta_data")
      }
      shinyjs::show("run")
      shinyjs::hide("cancel")
      shinyjs::show("download_report")
    } else if (long_run()$is_alive()) {
      # perform all IPC via files to avoid fiddling aroudn with pipes
      progress <- suppressWarnings(try(readLines(file.path(getwd(), d, "progress"))[[1]], silent = TRUE))
      progress_msg <- suppressWarnings(try(readLines(file.path(getwd(), d, "progress_msg"))[[1]],
                                           silent = TRUE))
      if (!inherits(progress_msg, "try-error")) {
        e$progress$set(message = paste(substr(progress_msg, 1, min(50,
                                                          nchar(progress_msg))),
                                       ifelse(nchar(progress_msg) > 50, "...",
                                              "")))
      }
      if (!inherits(progress, "try-error")) {
        progress <- suppressWarnings(as.numeric(progress))
        e$progress$set(value = progress)
      }
    } else {
      ok <- try(long_run()$get_result(), silent = TRUE)
      if (inherits(ok, "try-error")) {
        ok <- FALSE
      }
      if (!ok) {
        if (!is.null(e$progress)) {
          e$progress$close()
          e$progress <- NULL
        }
        shinyjs::show("run")
        shinyjs::hide("cancel")
      }
    }

  })

  session$onSessionEnded(function() {
    try(e$progress$close(), silent = TRUE)
    try(e$progress <- NULL, silent = TRUE)
    try(e$process$kill_tree(), silent = TRUE)
    try(e$process <- NULL, silent = TRUE)
    try(unlink(d, recursive = TRUE), silent = TRUE)
    try(unlink(input$study_data$datapath), silent = TRUE)
    try(unlink(input$meta_data$datapath), silent = TRUE)

    on.exit({
      try({
        withdirs <-
          list.files(file.path(my_basedir, "www"),
                     all.files = TRUE,
                     full.names = TRUE,
                     include.dirs = TRUE,
                     pattern = "tmp_rep_dir_.*")
        dirs <- withdirs[dir.exists(withdirs)]
        if (length(dirs) > 0)
          unlink(dirs, recursive = TRUE, force = TRUE, expand = FALSE)
      }, silent = TRUE)
    })

  })

}
