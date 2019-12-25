# from flexshi.R 25 dec 2019
    server = function(input, output) {
        library(RSQLite)
        library(BiocBBSpack)
        con = RSQLite::dbConnect(RSQLite::SQLite(),
           system.file("sqlite/demo2.sqlite", package="BiocBBSpack"), flags=RSQLite::SQLITE_RO)
        putmeta = reactive({
            dbGetQuery(con, paste0("select * from basic where package = '", input$pkchoice, "'"))
            })
        output$notes = renderPrint({
           lis = dbGetQuery(con, paste0("select * from notes where package = '", input$pkchoice, "'"))
           cat(unlist(putmeta()), "\n---\n")
           cat(unlist(lapply(lis$notes, function(x) c(x, "---"))), sep="\n")
           })
        output$errors = renderPrint({
           lis = dbGetQuery(con, paste0("select * from errors where package = '", input$pkchoice, "'"))
           cat(unlist(putmeta()), "\n---\n")
           cat(unlist(lapply(lis$errors, function(x) c(x, "---"))), sep="\n")
           })
        output$inst = renderPrint({
           lis = dbGetQuery(con, paste0("select * from inst where package = '", input$pkchoice, "'"))
           cat(unlist(putmeta()), "\n---\n")
           cat(unlist(lapply(lis$inst, function(x) c(x, "---"))), sep="\n")
           })
        output$desc = renderPrint({
           lis = dbGetQuery(con, paste0("select * from desc where package = '", input$pkchoice, "'"))
           cat(unlist(lis$description), sep="\n")
           })
        output$bcchk = renderUI({
           lis = dbGetQuery(con, paste0("select * from bccheck where package = '", input$pkchoice, "'"))
           do.call(helpText, BiocBBSpack:::process_log(lis$bcchk))
           })
        output$about = renderUI({
          helpText("This app uses rcmdcheck::rcmdcheck, which parses and organizes the check log to separate 
           errors, warnings, and notes.  It also ingests the BiocCheck log and decorates it lightly 
           to simplify discovery of adverse conditions.")
           }) 
        observeEvent(input$stopBtn, {
            dbDisconnect(con)
            stopApp(returnValue = NULL)
        })
    }
