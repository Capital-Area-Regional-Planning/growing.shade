#' Contact UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_contact_ui <- function(id) {
  ns <- NS(id)
  tagList(
    # br(class="d-none d-lg-block"), br(),
    br(), br(),
    shiny::div(
      id = "contact",
      includeMarkdown(system.file("app/www/contact.md", package = "planting.shade"))
    ),
    br()
  )
}

#' faq Server Functions
#'
#' @noRd
mod_contact_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
  })
}

## To be copied in the UI
# mod_contact_ui("contact_ui_1")

## To be copied in the server
# mod_contact_server("contact_ui_1")
