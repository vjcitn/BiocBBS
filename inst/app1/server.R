# from flexshi.R 25 dec 2019
    server = function(input, output) {
        library(RSQLite)
        library(BiocBBSpack)
        con = RSQLite::dbConnect(RSQLite::SQLite(),
           system.file("sqlite/demo2.sqlite", package="BiocBBSpack"), flags=RSQLite::SQLITE_RO)
#            "demo3.sqlite", flags=RSQLite::SQLITE_RO)
        putmeta = reactive({
            dbGetQuery(con, paste0("select * from basic where package = '", input$pkchoice, "'"))
            })
        output$vers = renderPrint({
           cat("BiocCheck result for\n")
           cat(unlist(putmeta()), "\n---\n")
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
        output$testcov = DT::renderDataTable({
#> dbGetQuery(con, "select * from testcov limit 10")
#         package                                  func   pctcov
#1  BiocFileCache                  .sql_filter_metadata  0.00000
#2  BiocFileCache                        .sql_migration  0.00000
           ans = dbGetQuery(con, paste0("select * from testcov where package = '", input$pkchoice, "'"))
           if (nrow(ans)>0) ans$pctcov = round(ans$pctcov, 3)
           ans
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
          helpText("This app", 
             tags$ul(tags$li("uses rcmdcheck::rcmdcheck to parse and organize the check log to separate errors, warnings, and notes,"), 
                     tags$li("ingests the BiocCheck log and decorates it lightly to simplify discovery of adverse conditions,"),
                     tags$li("formats results of covr::package_coverage to summarize test coverage (testthat or RUnit tests only) at the function level.")
              ) # end ul
             )  # end helpText
           }) 
        observeEvent(input$stopBtn, {
            dbDisconnect(con)
            stopApp(returnValue = NULL)
        })
    }
