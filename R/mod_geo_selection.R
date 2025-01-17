#' geo_selection UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList

mod_geo_selection_ui <- function(id) {
  ns <- NS(id)
  tagList(

HTML("<div class='help'>
     <p>
     <b>1. Choose your geographical area of interest</b>
     <br>
     <br>
     <b>Cities and townships:</b> 
     All cities, villages, and towns contained within Dane County. Select a city/township by name in the dropdown menu.
     <br>
     <br>
     <b>Neighborhoods:</b> 
     Neighborhoods are only available in the City of Madison. The boundaries are determined by local residents; not all areas in Madison are included in a neighborhood. Select a neighborhood by name in the dropdown menu.
     <br>
     <br>
     <b>Census block group:</b> 
     Block groups are areas defined by the US census bureau that contain about 250-550 housing units. Click on an area on the map to select a block group.
     </p>
     </div>"),
#HTML("<h2><section style='font-size:20pt'>Geography</h2>"),
    radioButtons(
      ns("geo"),
      label = HTML("</section><p><section style='font-weight: normal;' class='d-none d-lg-block'>Choose a geographical area to create a custom report. <strong>Scoll down to read and download the report.</strong></section></p>"),
      choiceNames = list("Cities and townships", 
                         HTML("<section class='d-block d-lg-none'>Neighborhoods</section>
                              <section class='d-none d-lg-block'>Neighborhoods (Madison only)</section>"), # (Minneapolis and St.Paul only)</section>"), #desktop
                         "Census block group"),
      choiceValues = list("ctus", "nhood", "blockgroups"),
      selected = "ctus",
    ),

fluidRow(column(width = 6,
                conditionalPanel(
      ns = ns,
      condition = "input.geo == 'ctus'",
      shinyWidgets::pickerInput(ns("cityInput"),
        label = shiny::HTML(paste0("<h3><span style='font-size:14pt'>Pick a city or township</span></h3>")),
        choices = ctu_list$GEO_NAME,
        options = list(
          title = "Pick a city or township", size = 10,
          `live-search` = TRUE
        ),
        multiple = F,
        selected = ui_params$set[ui_params$param == "cityselected"]
      )
    ),
    conditionalPanel(
      ns = ns,
      condition = "input.geo == 'nhood'",
      shinyWidgets::pickerInput(ns("nhoodInput"),
        label = shiny::HTML(paste0("<h4><span style='font-size:14pt'>Pick a neighborhood</span></h4>")),
        choices = nhood_ui,
        options = list(
          title = NULL, size = 10,
          `live-search` = TRUE
        ),
        multiple = F,
        selected = ui_params$set[ui_params$param == "nhoodselected"]
      )
    ),
    conditionalPanel(
      ns = ns,
      condition = "input.geo == 'blockgroups'",
      HTML("Please click on an area within the map at right.")
    )
)
),
actionButton(ns("zoom_and_center"), label = "Zoom to Area"),
)
}

#' geo_selection Server Functions
#'
#' @noRd
mod_geo_selection_server <- function(id) {

  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    input_values <- reactiveValues()
    
    # isPressed <- eventReactive(input$zoom_and_center, {
    #   if(input$zoom_and_center){
    #     "The button was pressed"
    #   } else {
    #     "The button was NOT pressed"
    #   }
    # }, ignoreNULL = FALSE)
    
    #has the center/zoom button been pressed?
    isPressed <- eventReactive(input$zoom_and_center, {
        input$zoom_and_center
    }, ignoreNULL = FALSE)

    observe({
      input_values$zoom_and_center <- isPressed()
      input_values$selected_geo <- input$geo
      input_values$mapfilter <- input$mapfilter
      input_values$selected_area <- if (input$geo == "ctus") {
        input$cityInput
      } else if (input$geo == "nhood") {
        input$nhoodInput
      } else {
        ""
      }
    })
    
    return(input_values)
  })
  
}

## To be copied in the UI
# mod_geo_selection_ui("geo_selection_ui_1")

## To be copied in the server
# mod_geo_selection_server("geo_selection_ui_1")
