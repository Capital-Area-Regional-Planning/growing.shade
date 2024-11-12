#' About UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_about_ui <- function(id) {
  ns <- NS(id)
  tagList(
    br(), br(),
    shiny::div(
      id = "about",
      includeMarkdown(system.file("app/www/about.md", package = "planting.shade"))
    ),
    br()
  )
}

#' faq Server Functions
#'
#' @noRd
mod_about_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
  })
}

## To be copied in the UI
# mod_home_ui("about_ui_1")

## To be copied in the server
# mod_home_server("about_ui_1")
