#' map_selections UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @import dplyr
#'
mod_map_selections_ui <- function(id) {
  ns <- NS(id)
  
  
  # radioTooltip <- function(id, choice, title, placement = "bottom", trigger = "hover", options = NULL){
  # 
  #   options = shinyBS:::buildTooltipOrPopoverOptionsList(title, placement, trigger, options)
  #   options = paste0("{'", paste(names(options), options, sep = "': '", collapse = "', '"), "'}")
  #   bsTag <- shiny::tags$script(shiny::HTML(paste0("
  #   $(document).ready(function() {
  #     setTimeout(function() {
  #       $('input', $('#", id, "')).each(function(){
  #         if(this.getAttribute('value') == '", choice, "') {
  #           opts = $.extend(", options, ", {html: true});
  #           $(this.parentElement).tooltip('destroy');
  #           $(this.parentElement).tooltip(opts);
  #         }
  #       })
  #     }, 500)
  #   });
  # ")))
  #   htmltools::attachDependencies(bsTag, shinyBS:::shinyBSDep)
  # }
  

  tagList(
    tags$head(tags$style(HTML(
    ".tooltip-main {
  width: 20px;
  height: 15px;
  border-radius: 50%;
  font-weight: 700;
  background: #EDEDED;
  border: 1px solid #0054a4;
  margin: 4px 121px 0 5px;
  float: right;
  text-align: left;
  opacity: 1!important;
}

.tooltip-inner {
  max-width: 250px !important;
  font-size: 16px;
  padding: 5px 5px 5px 5px;
  background: #FFFFFF;
  color: #000000;
  border: 1px solid #0054a4;
  text-align: center;
  opacity: 1!important;
}

.tooltip.in{opacity:1!important;}
"
))),
HTML("<div class='help'>
     <p>
     <b>2. Choose your prioritization theme</b>
     <br>
     <br>
      How can we choose where to preserve & plant canopy? The answer depends on your goals! 
      Do you simply want to plant trees in areas that lack canopy? Or do you want to focus on creating a positive impact to human health?
      <br>
     <br>
      Growing Shade includes four premade 'themes' that align with common goals for canopy projects.
      Each theme includes one or more related variables -- hover over a theme to see which variables it includes.
      You can select either one or two themes. Choosing two themes allows you to explore how different themes intersect.
     <br>
     <br>
     <b>Temperature:</b> 
     	Trees can signficantly reduce hot summer temperatures.
     	Use this theme if your goals are related to heat reduction or climate change.
     <br>
     <br>
     <b>Socioeconomic Indicators:</b> 
     	Trees are not always distributed equitably in U.S. cities, unjustly depriving some residents of the myriad benefits canopy provides.
     	Use this theme if your goals are related to environmental justice.
     <br>
     <br>
     <b>Health Disparities:</b> 
     Trees provide shade, improve local air quality, reduce air pollution, and can even boost mental health.
     Use this theme if your goals are related to improving health outcomes.
     <br>
     <br>
     <b>Canopy Cover:</b> 
     The amount of canopy cover across the county varies widely, depending on land use and other factors.
     Use this theme if your goals are related to planting trees in canopy deficient areas.
     <br>
     <br>
     <b>Custom:</b> 
     Create your own theme using any combination of 20+ variables.
     Use this theme if your goals relate to other variables not included in the premade themes.
     Click on a variable to turn it “on” or “off” – a check mark indicates that the variable is being used. 
     You can also “select all” or “deselect all” variables within each categorical drop down menu.
     </p>
     </div>"),
    # fluidRow(
    HTML("<h2><section style='font-size:20pt'>Priority layer</h2></section><p><section style='font-weight: normal;' class='d-none d-lg-block'>Trees intersect with regional issues and priorities. Use a preset or create a custom layer to understand the overlap. <b>Choose up to two themes.</b> </section></p>"),
    #checkboxGroupInput(ns("theme2"), "", c("Temperature", "Socioeconomic Indicators", "Health Disparities", "Canopy Cover", "Custom"), selected = "Socioeconomic Indicators"),
    checkboxGroupInput(ns("theme2"), "",
                       choiceNames = list(
                         #Temperature
                         HTML("<a data-toggle='tooltip' trigger='click' data-html='true' data-placement='bottom'
             title='<strong>Variables include:</strong><br>
             - Temperature on a hot summer day'>Temperature</a>"),
                         #Socioeconomic Indicators
                         HTML("<a data-toggle='tooltip' trigger='click' data-html='true' data-placement='bottom'
             title='<strong>Variables include:</strong><br>
             - Income, % households above the poverty level<br>
             - Income, % households making less than 50k<br>
             - Income, median household income<br>
             - Race, % residents identifying as Black or African American<br>
             - Race, % residents identifying as Asian<br>
             - Race, % residents identifying as Hispanic or Latino'>Socioeconomic Indicators</a>"),
                         #Health Disparities
                         HTML("<a data-toggle='tooltip' trigger='click' data-html='true' data-placement='bottom'
             title='<strong>Variables include:</strong><br>
             - % asthma among adults <br>
             - % chronic obstructive pulmonary disease among adults<br>
             - % mental health not good for >=14 days among adults (%)<br>
             - % physical health not good for >=14 days among adults (%)'>Health Disparities</a>"),
                         #Canopy Cover
                         HTML("<a data-toggle='tooltip' trigger='click' data-html='true' data-placement='bottom'
             title='<strong>Variables include:</strong><br>
             - % Tree canopy'>Canopy Cover</a>"),
                         #Custom
                         HTML("<a data-toggle='tooltip' trigger='click' data-html='true' data-placement='bottom'
             title='Select custom variables below'>
             Custom</a>")
                       ),
                       choiceValues = c(
                         "Temperature",
                         "Socioeconomic Indicators",
                         "Health Disparities",
                         "Canopy Cover",
                         "Custom"
                       ), inline = F,
                       selected = "Socioeconomic Indicators"),
  conditionalPanel(
      ns = ns,
      condition = "input.theme2[0] == 'Custom' || input.theme2[1] == 'Custom'",  # && input.onoff == 'On'",

      shinyWidgets::pickerInput(ns("peopleInput"),
        label = shiny::HTML(paste0("<h4><span style='font-size:14pt'>Demographics</span></h4>")),
        choices = dplyr::filter(metadata, type == "people") %>% .$name,
        # choicesOpt = list(
        #   subtext = paste0(filter(metadata, type == "people") %>% .$niceinterp,
        #                    " values have higher priority scores")),
        options = list(
          `actions-box` = TRUE,
          size = 20,
          `selected-text-format` = "count > 1"
        ),
        multiple = T,
        selected = NULL # filter(metadata, type == "people")[1, 2]
      )
    ),
    conditionalPanel(
      ns = ns,
      condition = "input.theme2[0] == 'Custom' || input.theme2[1] == 'Custom'",  # && input.onoff == 'On'",
      
      shinyWidgets::pickerInput(ns("placeInput"),
        label = shiny::HTML(paste0("<h4><span style='font-size:14pt'>Environment & Climate</span></h4>")),
        choices = dplyr::filter(metadata, type == "environment") %>% .$name,
        choicesOpt = list(
          subtext = paste0(dplyr::filter(metadata, type == "environment") %>% .$nicer_interp)
        ),
        # choicesOpt = list(
        #   subtext = paste0(filter(metadata, type == "environment") %>% .$niceinterp,
        #                    " values have higher priority scores")),
        options = list(
          `actions-box` = TRUE,
          size = 20,
          `selected-text-format` = "count > 1"
        ),
        multiple = T,
        selected = dplyr::filter(metadata, type == "environment")[9, 2]
      )
    ),
    conditionalPanel(
      ns = ns,
      condition = "input.theme2[0] == 'Custom' || input.theme2[1] == 'Custom'",  # && input.onoff == 'On'",
      
      shinyWidgets::pickerInput(ns("healthInput"),
        label = shiny::HTML(paste0("<h4><span style='font-size:14pt'>Health</span></h4>")),
        choices = dplyr::filter(metadata, type == "health") %>% .$name,
        # choicesOpt = list(
        #   subtext = paste0(filter(metadata, type == "health") %>% .$niceinterp,
        #                     " values have higher priority scores")),
        options = list(
          `actions-box` = TRUE,
          size = 20,
          `selected-text-format` = "count > 1"
        ),
        multiple = T,
        selected = NULL
      )
    ),
    conditionalPanel(
      ns = ns,
      condition = "input.theme2[0] == 'Custom' || input.theme2[1] == 'Custom'",  # && input.onoff == 'On'",
      
      shinyWidgets::pickerInput(ns("economicsInput"),
        label = shiny::HTML(paste0("<h4><span style='font-size:14pt'>Socioeconomics</span></h4>")),
        choices = dplyr::filter(metadata, type == "economics") %>% .$name,
        # choicesOpt = list(
        #   subtext = paste0(filter(metadata, type == "economics") %>% .$niceinterp,
        #                    " values have higher priority scores")),
        options = list(
          `actions-box` = TRUE,
          size = 20,
          `selected-text-format` = "count > 1"
        ),
        multiple = T,
        selected = NULL
      )
    )
  )
}

#' map_selections Server Function
#'
#' @noRd
mod_map_selections_server <- function(input, output, session # ,
                                      # preset_selections,
                                      # current_tab
) {
  ns <- session$ns

  input_values <- reactiveValues() # start with an empty reactiveValues object.

  observe({
    input_values$allInputs <- as_tibble(input$peopleInput) %>%
      rbind(as_tibble(input$placeInput)) %>%
      rbind(as_tibble(input$healthInput)) %>%
      rbind(as_tibble(input$economicsInput))

    if(is.null(input$theme2[0])) {
      input_values$theme2 <- "Socioeconomic Indicators"
    } else {
      input_values$theme2 <- input$theme2
    }
   
  })
  return(input_values)
}



## To be copied in the UI
# mod_map_selections_ui("map_selections_ui_1")

## To be copied in the server
# callModule(mod_map_selections_server, "map_selections_ui_1")
