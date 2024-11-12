#' map_utils UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_map_utils_ui <- function(id) {
  ns <- NS(id)
  tagList()
}

#' map_utils Server Function
#'
#' @noRd
#' @import sf
mod_map_utils_server <- function(input, output, session,
                                 map_selections,
                                 geo_selections) {
  ns <- session$ns

  
  make_map_data <- reactive({
    
    #the one or two selected themes
    theme_1 <- map_selections$theme2[1]
    theme_2 <- map_selections$theme2[2]

    #if custom theme, the variable(s) selected
    custom_selections <- map_selections$allInputs
    
    #if no variables are selected, set custom scores to 0
    if(nrow(custom_selections) == 0) {
      mn_bgs <- mn_bgs %>% 
        mutate(Custom = 0)
      
      metadata <- metadata %>% 
        mutate(custom = 0)
      
    #calculate scores based on the variables selected
    } else {
      
      #function to insert escape characters in strings grepl doesn't like
      quotemeta <- function(string) {
        str_replace_all(string, "(\\W)", "\\\\\\1")
      }
      
      
      mn_bgs <- mn_bgs %>%
        #get rid of zeroed out custom column
        select(-Custom) %>% 
        #sum scores of selected variables and join
        left_join(bg_growingshade_main %>% 
                    filter(grepl(paste(custom_selections$value %>% quotemeta(), collapse="|"), name)) %>% 
                    group_by(bg_string) %>% 
                    summarise(Custom = sum(significance)), 
                  by = join_by(GEO_NAME == bg_string))
      
      #update metadata
      metadata <- metadata %>% 
        mutate(custom = case_when(grepl(paste(custom_selections$value %>% quotemeta(), collapse="|"), name) ~ 1,
                                            TRUE ~ 0)
                         )
     
      }
    
    faststep <- if (!is.na(theme_1) & !is.na(theme_2)) { #mapping for two themes
      if(theme_1 == "Socioeconomic Indicators") {
        mn_bgs %>% 
          mutate(
            bg_string = GEOID,
            SUM = case_when(!!as.name(theme_1) >= 2 & !!as.name(theme_2) >= 1 ~ "Both Themes", #both themes are priorities
                            !!as.name(theme_1) >= 2 & !!as.name(theme_2) < 1 ~ theme_1, #only theme 1 is priority
                            !!as.name(theme_1) < 2 & !!as.name(theme_2) >= 1 ~ theme_2, #only theme 2 is priority
                            TRUE ~ NA_character_
            ),
            total_score = !!as.name(theme_1) + !!as.name(theme_2)
          )
      } else if (theme_2 == "Socioeconomic Indicators") {
        mn_bgs %>% 
          mutate(
            bg_string = GEOID,
            SUM = case_when(!!as.name(theme_1) >= 1 & !!as.name(theme_2) >= 2 ~ "Both Themes", #both themes are priorities
                            !!as.name(theme_1) >= 1 & !!as.name(theme_2) < 2 ~ theme_1, #only theme 1 is priority
                            !!as.name(theme_1) < 1 & !!as.name(theme_2) >= 2 ~ theme_2, #only theme 2 is priority
                            TRUE ~ NA_character_
            ),
            total_score = !!as.name(theme_1) + !!as.name(theme_2)
          )
      } else {
      mn_bgs %>% 
      mutate(
        bg_string = GEOID,
        SUM = case_when(!!as.name(theme_1) >= 1 & !!as.name(theme_2) >= 1 ~ "Both Themes", #both themes are priorities
                        !!as.name(theme_1) >= 1 & !!as.name(theme_2) < 1 ~ theme_1, #only theme 1 is priority
                        !!as.name(theme_1) < 1 & !!as.name(theme_2) >= 1 ~ theme_2, #only theme 2 is priority
                        TRUE ~ NA_character_
                        ),
        total_score = !!as.name(theme_1) + !!as.name(theme_2)
          )
      }
    #mapping for one theme
    } else if (!is.na(theme_1) & is.na(theme_2)) {
      mn_bgs %>% 
        mutate(
          bg_string = GEOID,
          SUM = case_when(theme_1 != "Socioeconomic Indicators" & !!as.name(theme_1) >= 1 ~ theme_1,
                          theme_1 == "Socioeconomic Indicators" & !!as.name(theme_1) >= 2 ~ theme_1,
                          TRUE ~ NA_character_
                          ),
          total_score = !!as.name(theme_1)
            )
      } else if (is.na(theme_1) & !is.na(theme_2)) {
        mn_bgs %>% 
          mutate(
            bg_string = GEOID,
            SUM = case_when(theme_2 != "Socioeconomic Indicators" & !!as.name(theme_2) >= 1 ~ theme_2,
                            theme_2 == "Socioeconomic Indicators" & !!as.name(theme_2) >= 2 ~ theme_2,
                            TRUE ~ NA_character_
            ),
            total_score = !!as.name(theme_2)
          )
    }
    
    return(faststep)
    
  })
  
  make_map_data_filter <- reactive({
    # keeping this in case I want to re-implement it
    # filterstep <- if(geo_selections$mapfilter == "above4") {
    #   make_map_data() %>%
    #     filter(SUM >= 4)
    # } else if (geo_selections$mapfilter == "above5") {
    #   make_map_data() %>%
    #     filter(SUM >= 5)
    # } else if (geo_selections$mapfilter == "above6") {
    #   make_map_data() %>%
    #     filter(SUM >= 6)
    # } else if (geo_selections$mapfilter == "above7") {
    #   make_map_data() %>%
    #     filter(SUM >= 7)
    # } else {make_map_data()}
    
    filterstep <- make_map_data()
    
    return(filterstep)
    
  })

  #------- reactive things

  vals <- reactiveValues()

  observe({
    vals$map_data <- make_map_data()
    vals$map_data2 <- make_map_data_filter()
  })

  return(vals)
}

## To be copied in the UI
# mod_map_utils_ui("map_utils_ui_1")

## To be copied in the server
# callModule(mod_map_utils_server, "map_utils_ui_1")
