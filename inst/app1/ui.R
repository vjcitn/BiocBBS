    con = RSQLite::dbConnect(RSQLite::SQLite(),
           system.file("sqlite/demo2.sqlite", package="BiocBBSpack"), flags=RSQLite::SQLITE_RO)
    basic = RSQLite::dbReadTable(con, "basic")

    ui = fluidPage(
      sidebarLayout(
       sidebarPanel( 
        helpText("BiocBBSpack browse_checks"),
        selectInput("pkchoice", "Select a package", choices=sort(basic$package), selected=sort(basic$package)[1]),
        actionButton("stopBtn", "Stop app."),
        width=3
         ),
        mainPanel(tabsetPanel(
         tabPanel("bcchk", verbatimTextOutput("vers"), uiOutput("bcchk")),
         tabPanel("notes", verbatimTextOutput("notes")),
         tabPanel("errors", verbatimTextOutput("errors")),
         tabPanel("inst", verbatimTextOutput("inst")),
         tabPanel("desc", verbatimTextOutput("desc")),
         tabPanel("about", uiOutput("about"))
         )
        )
       )
      )
