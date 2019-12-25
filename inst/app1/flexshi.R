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
         tabPanel("bcchk", uiOutput("bcchk")),
         tabPanel("notes", verbatimTextOutput("notes")),
         tabPanel("errors", verbatimTextOutput("errors")),
         tabPanel("inst", verbatimTextOutput("inst")),
         tabPanel("desc", verbatimTextOutput("desc")),
         tabPanel("about", uiOutput("about"))
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
        output$bcchk = renderUI({
           lis = dbGetQuery(con, paste0("select * from bccheck where package = '", input$pkchoice, "'"))
           do.call(helpText, process_log(lis$bcchk))
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
    runApp(list(ui = ui, server = server))
}


format_bcchk = function(txt, out_suffix=".html") {
 cur = readLines(txt)
 cur = gsub("(\\* WARNING..*|^Warning..*)", "</pre><mark>\\1</mark><pre>", cur) 
 cur = gsub("(\\* NOTE..*)", "</pre><mark>\\1</mark><pre>", cur) 
 cur = gsub("(^ERROR..*|^WARNING..*|^NOTE..*)", "</pre><mark>\\1</mark><pre>", cur) 
 writeLines(c("<pre>", cur, "</pre>"), paste0(txt, out_suffix))
}


# find * NOTE, WARNING, ERROR and produce a list for markup
process_log = function(curtxt, 
    event_regexp = c("\\* NOTE..*|\\* WARNING..*|\\* ERROR..*"), ...) {
#  curtxt = readLines(txt)
  nlines = length(curtxt)
  evlocs = grep(event_regexp, curtxt)
  dev = diff(evlocs)
  if (any(dev==1)) stop("contiguous events -- code needs revision")
#
# curtxt divides into event and non-event text
# non-event chunks are marked pre(), events marked strong()
#
# assume first and last chunks free of events
  markedtxt = vector("list", 2*length(evlocs)+1)
  curch = 1
  cursor = 1
  for (i in seq_along(evlocs)) {
    markedtxt[[curch]] = pre(xx <- paste(curtxt[cursor:(evlocs[i]-1)],collapse="\n"))
    curch = curch+1
    markedtxt[[curch]] = strong(paste(curtxt[evlocs[i]], collapse="\n"))
    cursor = evlocs[i]+1
    curch = curch+1
    }
  markedtxt[[curch]] = pre(paste(curtxt[cursor:nlines], collapse="\n"))
  markedtxt
}


bcchk_to_df = function(chktxt, pkgname=NULL) {
 x = readLines(chktxt)
 if (is.null(pkgname)) pkgname = strsplit(chktxt, "_")[[1]][1]
 data.frame(package=pkgname, bcchk=x)
}
 
