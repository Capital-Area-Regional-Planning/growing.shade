#' storymap UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_storymap_ui <- function(id) {
  ns <- NS(id)
  tagList(
      br(class="d-none d-lg-block"),
      htmlOutput(ns("storymap"))
  )
}

#' storymap Server Functions
#'
#' @noRd
mod_storymap_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    output$storymap <- renderUI({
      my_test <- HTML("<div style='max-width:3000px;'><body><iframe title='StoryMap about the Tree Canopy Collaborative' src='https://storymaps.arcgis.com/stories/fd8290f5dc7e453ab7b80aeb0ede9c74' style='width:100%; height:calc(93vh); padding:0px; padding-top:0px; border:0; object-position: center bottom;'</iframe></body></div>")
      my_test
    })
  })
}

## To be copied in the UI
# mod_storymap_ui("storymap_ui_1")

## To be copied in the server
# mod_storymap_server("storymap_ui_1")
