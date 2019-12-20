
#> names(gwascat_chk)
# [1] "package"      "version"      "notes"        "warnings"     "errors"      
# [6] "platform"     "checkdir"     "install_out"  "description"  "session_info"
#[11] "cran"         "bioc"        

#' simple interface to details about check
#' @import shiny
#' @param lis output of rcmdcheck for one package
#' @note in development
chk_shiny = function(lis) {
  ui = fluidPage(
   sidebarLayout(
    sidebarPanel(
     helpText(lis$package),
     helpText(lis$version),
     helpText(lis$platform), width=2),
   mainPanel(
    tabsetPanel(
     tabPanel("notes", 
      verbatimTextOutput("note1"),
      verbatimTextOutput("note2")
      )
     )
    )
   )
  )
 server = function(input, output) {
  output$note1 = renderPrint(
   cat(lis$notes[[1]], sep="\n")
  )
  output$note2 = renderPrint(
   cat(lis$notes[[3]], sep="\n")
  )
 }
runApp(list(ui=ui, server=server))
}


#' use rcmdcheck on a package
#' @param folder source folder for R package
#' @param error_on character(1) see rcmdcheck::rcmdcheck; default is to proceed when error occurs in a check stage
#' @export
ibc = function(folder, error_on="never") {
 td = tempdir()
 curd = getwd()
 on.exit(setwd(curd))
 c1 = rcmdcheck::rcmdcheck(path=folder, error_on=error_on)
 rcmdcheck::check_details(c1)
}
