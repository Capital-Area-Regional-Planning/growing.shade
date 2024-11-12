#' map_overview UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @import waiter
mod_map_overview_ui <- function(id) {
  ns <- NS(id)
  
  js_map <- "@media (max-width: 765px) {
   /* #map {width: 50% !important;} */
   div#map_overview_ui_1-map {
    width: 95% !important;
    height: 55vh !important;
    visibility: inherit;
    position: relative;
    right: 5em;
    left: 0em;
    bottom:2em;
   }
   .navbar-right{
   float: right !important;
   }
   body{padding-top:15px;}
   }
  }

  "
  
  tagList(
    tags$style(type = "text/css", "#map {width; 100%;}"), #works
    tags$style(HTML(js_map)),
    useWaiter(),
    leafletOutput(ns("map"),
      height = "88vh"
    ) 
  )
}

#' map_overview Server Function
#'
#' @noRd
#' @import leaflet
mod_map_overview_server <- function(input, output, session,
                                    map_selections,
                                    geo_selections,
                                    map_util,
                                    current_tab) {
  ns <- session$ns


  waitertest <- Waiter$new(ns("map"),
    html = waiter::spin_loader(), # spin_fading_circles(),
    color = "rgba(255,255,255,.5)"
  )

 
  #### main map ---------
  output$map <- renderLeaflet({ #  map --------
    leaflet(options = leafletOptions(
      minZoom = 8, maxZoom = 17,
      attributionControl = FALSE
    )) %>%
      setView(
        lat = ui_params$number[ui_params$param == "center_latitude"],
        lng = ui_params$number[ui_params$param == "center_longitude"],
        zoom = ui_params$number[ui_params$param == "center_zoom"]
      ) %>%
      # add attribution
      leaflet.extras::addFullscreenControl(position = "topleft", pseudoFullscreen = TRUE) %>%
      addMapPane(name = "Stamen Toner", zIndex = 100) %>%
      addMapPane(name = "Map", zIndex = 100) %>%
      addMapPane(name = "Aerial Imagery", zIndex = 100) %>%
      addMapPane(name = "Satellite", zIndex = 100) %>%
      addMapPane("redline2", zIndex = 110) %>%
      addMapPane("Priority score", zIndex = 120) %>%
      addMapPane(name = "geooutline2", zIndex = 152) %>%
      addMapPane("redline", zIndex = 160) %>%
      addMapPane("outline", zIndex = 250) %>%
      addMapPane("labels", zIndex = 251) %>%
      addProviderTiles("CartoDB.PositronOnlyLabels",
        options = c(
          providerTileOptions(maxZoom = 18),
          pathOptions(pane = "labels")
        ), # pathOptions(pane = "Stamen Toner"),
        group = "Satellite"
      ) %>%
      addProviderTiles("CartoDB.PositronOnlyLabels",
        options = providerTileOptions(maxZoom = 18), # pathOptions(pane = "Stamen Toner"),
        group = "Map"
      ) %>%
      addProviderTiles(
        provider = providers$Esri.WorldImagery,
        group = "Satellite",
        options = pathOptions(pane = "Aerial Imagery")
      ) %>%
      addProviderTiles("CartoDB.PositronNoLabels",
        group = "Map",
        options = pathOptions(pane = "Map")
      ) %>%
      addPolygons(
        data = redline,
        group = "Historically redlined areas",
        stroke = T,
        smoothFactor = 1,
        color = "black",
        fill = FALSE,
        fillColor = "#ED1B2E",
        fillOpacity = 1,
        options = pathOptions(pane = "redline")
      ) %>%
      addPolygons(
        data = redline,
        group = "Historically redlined areas",
        stroke = F,
        smoothFactor = 1,
        color = "black",
        fill = T,
        fillColor = "black", # "#ED1B2E",
        fillOpacity = 1,
        options = pathOptions(pane = "redline2")
      ) %>%
      # maybe not the best, but need city outlines to show up first
      addPolygons(
        data = ctu_list,
        group = "Jurisdiction outlines",
        stroke = T,
        smoothFactor = 1,
        color = "black",
        weight = 2,
        fill = F,
        opacity = 1,
        options = pathOptions(pane = "geooutline2"),
        layerId = ~GEO_NAME
      ) %>%
      addPolygons(
        data = filter(ctu_list, GEO_NAME == ui_params$set[ui_params$param == "cityselected"]),
        stroke = TRUE,
        weight = 3,
        color = "#0073e0", # "blue",
        fill = NA,
        opacity = 1,
        group = "outline",
        smoothFactor = 0.2,
        options = pathOptions(pane = "outline")
      ) %>%
      ### add layer control
      addLayersControl(
        position = "bottomright",
        baseGroups = c(
          "Map",
          "Satellite"
        ),
        overlayGroups = c(
          "Priority score",
          "Historically redlined areas",
          "Jurisdiction outlines"
        ),
        options = layersControlOptions(collapsed = T)
      ) %>%
      hideGroup(c(
        "Historically redlined areas"
      ))
  })


  #### changing priority score --------------
  toListen_mainleaflet <- reactive({
    list(
      current_tab,
      map_util$map_data2
    )
  })

  observeEvent(
    ignoreInit = TRUE, # TRUE,
    toListen_mainleaflet(),
    {
      if (is.null(map_util$map_data2)) {
        print("nodata")
      } else {
        print("rendering polygons")
        waitertest$show()
        leafletProxy("map") %>%
          clearGroup("Priority score") %>%
          addPolygons(
            data = map_util$map_data2,
            group = "Priority score",
            stroke = TRUE,
            color = "#666666",
            opacity = 0.9,
            weight = 0.5, # 0.25,
            fillOpacity = 0.5,
            smoothFactor = 0.2,
            label = ~ (paste0("Total score: ", map_util$map_data2$total_score)),
            highlightOptions = highlightOptions(
              stroke = TRUE,
              color = "white",
              weight = 6,
              bringToFront = T,
              opacity = 1
            ),
            fillColor = ~ colorFactor(
              # n = 5,
              palette = c("#7570b3", "#1b9e77", "#d95f02"), #YlOrBr", # "YlOrRd", #"Oranges",
              domain = map_util$map_data2 %>% select("SUM") %>% .[[1]], na.color = "#fff"
            )(map_util$map_data2 %>% select("SUM") %>% .[[1]]),
            popup = ~ paste0(
              "Geographic ID: ", map_util$map_data2$bg_string,
              "<br>City: ", map_util$map_data2$jurisdiction,
              "<br>Priority: ",  ifelse(!is.na(map_util$map_data2$SUM), map_util$map_data2$SUM, "None"),
              "<br>Total score: ", map_util$map_data2$total_score,
              "<br>Current tree canopy cover: ", round(map_util$map_data2$canopy_percent, 1), "%"
            ),
            options = pathOptions(pane = "Priority score"),
            layerId = ~bg_string
          ) %>%
          addLegend(
            title = "Priority<br>", # (higher scores show<br>where trees may have<br>larger benefits)",
            position = "bottomleft",
            group = "Priority score",
            layerId = "score",
            colors = {if (!is.na(map_selections$theme2[2]) & !is.na(map_selections$theme2[1])) {
              factor(c("#7570b3", "#1b9e77", "#d95f02")) 
              }else{
                factor(c("#1b9e77"))}
              },
            labels = {if (!is.na(map_selections$theme2[2]) & !is.na(map_selections$theme2[1])) {
              factor(c("Both Themes", map_selections$theme2[2], map_selections$theme2[1]))
            }else{
              factor(c(map_selections$theme2[1]))}
            }
              ) %>%
          addScaleBar(
            position = "bottomleft",
            options = c( # maxWidth = 200,
              imperial = T, metric = F
            )
          )
        waitertest$hide()
      }
    }
  )

  # map click doesn't work so well with multiple geo options; ctu/blockgroups/neighborhoods
  ## jurisdiction outlines -----------
  observeEvent(
    ignoreInit = FALSE, # true
    geo_selections$selected_geo,
    {
      if (geo_selections$selected_geo == "blockgroups") {
        leafletProxy("map") %>%
          clearGroup("Jurisdiction outlines") %>%
          clearGroup("outline")
      } else {
        leafletProxy("map") %>%
          clearGroup("Jurisdiction outlines") %>%
          clearGroup("outline") %>%
          addPolygons(
            data = if (geo_selections$selected_geo == "ctus") {
              ctu_list
            } else if (geo_selections$selected_geo == "nhood") {
              nhood_list
            } else if (geo_selections$selected_geo == "blockgroups") {
              mn_bgs
            },
            group = "Jurisdiction outlines",
            stroke = T,
            smoothFactor = 1,
            color = "black",
            weight = 2,
            fill = F,
            opacity = 1,
            options = pathOptions(pane = "geooutline2"),
            layerId = if (geo_selections$selected_geo == "blockgroups") {
              NULL
            } else {
              ~GEO_NAME
            }
          )
      }
    }
  )

  # trees for city/nhood ------

  observeEvent(
    ignoreInit = FALSE, # TRUE,
    req(geo_selections$selected_area != "blockgroups"),
    {
      if (geo_selections$selected_area == "") {
        leafletProxy("map") %>%
          clearGroup("outline") # %>%
      } else if (geo_selections$selected_geo == "ctus") {
        leafletProxy("map") %>%
          clearGroup("outline") %>%
          addPolygons(
            data = filter(ctu_list, GEO_NAME == geo_selections$selected_area),
            stroke = TRUE,
            weight = 3,
            color = "#0073e0", # "blue",
            fill = NA,
            opacity = 1,
            group = "outline",
            smoothFactor = 0.2,
            options = pathOptions(pane = "outline")
          )
      } else if (geo_selections$selected_geo == "nhood") {
        leafletProxy("map") %>%
          clearGroup("outline") %>%
          addPolygons(
            data = filter(nhood_list, GEO_NAME == geo_selections$selected_area),
            stroke = TRUE,
            weight = 3,
            color = "#0073e0", # "blue",
            fill = NA,
            opacity = 1,
            group = "outline",
            smoothFactor = 0.2,
            options = pathOptions(pane = "outline")
          )
      }
    }
  )

  # # trees for blockgroups  --------------
  toListen_clickyblockgroups <- reactive({
    list(
      req(geo_selections$selected_geo == "blockgroups"),
      req(input$map_shape_click$id)
    )
  })
  observeEvent(
    ignoreInit = FALSE,
    toListen_clickyblockgroups(),
    {
      if (input$map_shape_click$id == "") {
        leafletProxy("map") %>%
          clearGroup("outline")
      } else {
        leafletProxy("map") %>%
          clearGroup("outline") %>%
          addPolygons(
            data = mn_bgs %>% filter(GEO_NAME == input$map_shape_click$id),
            stroke = TRUE,
            weight = 3,
            color = "#0073e0", #"blue",
            fill = NA,
            opacity = 1,
            group = "outline",
            smoothFactor = 0.2,
            options = pathOptions(pane = "outline")
          )
      }
    }
  )


  # ### save map clicks -----------
  vals <- reactiveValues()
  observe({
    req(geo_selections$selected_geo == "blockgroups")
    event <- input$map_shape_click
    vals$TEST <- event$id
    vals$selected_blockgroup <- (map_util$map_data2$bg_string[map_util$map_data2$bg_string == event$id])
  })
  return(vals)
}

## To be copied in the UI
# mod_map_overview_ui("map_overview_ui_1")

## To be copied in the server
# callModule(mod_map_overview_server, "map_overview_ui_1")
