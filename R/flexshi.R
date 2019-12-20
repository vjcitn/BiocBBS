#' developer report on package check process in shiny
#' @import shiny
#' @importFrom RSQLite dbConnect SQLite SQLITE_RO dbGetQuery dbDisconnect dbReadTable
#' @param con SQLiteConnection where tables of check results from rcmdcheck are stored
#' @note dbDisconnect is run if the stop button is pressed to end shiny session.  If
#' stopped via ctrl-C or error, the connection may remain and require closure.
#' @examples
#' if (interactive()) {
#'  con = RSQLite::dbConnect(RSQLite::SQLite(), 
#'   system.file("sqlite/demo2.sqlite", package="BiocBBSpack"), flags=RSQLite::SQLITE_RO)
#'  browse_checks(con)
#' }
#' @export
browse_checks = function (con) 
{
basic = dbReadTable(con, "basic")
stopifnot(is(con, "SQLiteConnection"))
    ui = fluidPage(
      sidebarLayout(
       sidebarPanel( 
        helpText("BiocBBSpack browse_checks"),
        selectInput("pkchoice", "Select a package", choices=sort(basic$package), selected=sort(basic$package)[1]),
        actionButton("stopBtn", "Stop app."),
        width=3
         ),
        mainPanel(tabsetPanel(
         tabPanel("notes", verbatimTextOutput("notes")),
         tabPanel("errors", verbatimTextOutput("errors")),
         tabPanel("inst", verbatimTextOutput("inst")),
         tabPanel("desc", verbatimTextOutput("desc"))
         )
        )
       )
      )
    server = function(input, output) {
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
        observeEvent(input$stopBtn, {
            dbDisconnect(con)
            stopApp(returnValue = NULL)
        })
    }
    runApp(list(ui = ui, server = server))
}

