#' report UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList

#original code
# mod_report_new_ui <- function(id) {
#   ns <- NS(id)
#   tagList(
#     shinybrowser::detect(),
#     
#     shinyWidgets::useShinydashboard(),
#     (uiOutput(ns("geoarea"))),
#     br(),
#     fluidRow(uiOutput(ns("priority_box"))),
#     fluidRow(uiOutput(ns("treecanopy_box"))),
#     fluidRow(uiOutput(ns("disparity_box"))),
#     HTML("<div class='help'>
#                  <p>
#                   <b>5. Download the report</b>
#                  </p>
#                  </div>"),
#     fluidRow(uiOutput(ns("download_box")))
#   )
# }

#Testing
mod_report_new_ui <- function(id) {
  ns <- NS(id)
  tagList(
    shinybrowser::detect(),
    
    #shinyWidgets::useShinydashboard(),
    (uiOutput(ns("geoarea"))),
    br(),
    navset_tab(
      nav_panel(title = "Priority",
                br(),
    fluidRow(uiOutput(ns("priority_box")))),
    nav_panel(title = "Canopy",
              br(),
    fluidRow(uiOutput(ns("treecanopy_box")))),
    nav_panel(title = "Equity & Income",
              br(),
    fluidRow(uiOutput(ns("disparity_box")))),
    nav_panel(title = "Download",
    HTML("<div class='help'>
                 <p>
                  <b>5. Download the report</b>
                 </p>
                 </div>"),
    br(),
    fluidRow(uiOutput(ns("download_box"))))
  ))
}

#' report Server Functions
#'
#' @noRd
#' @import ggplot2
#' @import tidyr
#' @import tibble
#' @import stringr
#' @import ggbeeswarm
#' @import ggtext
#' @import councilR
#' @import patchwork
#' @import png
#' @import grid
mod_report_server <- function(id,
                              geo_selections,
                              map_selections,
                              blockgroup_selections,
                              map_util) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    library(councilR)
    
    ####### things to export
    TEST <- reactive({
      TEST <- if (geo_selections$selected_geo == "ctus") {
        geo_selections$selected_area
      } else if (geo_selections$selected_geo == "nhood") {
        geo_selections$selected_area
      } else if (geo_selections$selected_geo == "blockgroups") {
        blockgroup_selections$selected_blockgroup
      }
      return(TEST)
    })
    
    param_area <- reactive({
      req(TEST() != "")
      output <- TEST()
      return(output)
    })
    
    
    # the min, max, n_blockgroups, eab, treeacres, landacres, canopypercent, avgcanopy for the selected geography
    param_areasummary <- reactive({
      req(TEST() != "")
      output <- if (geo_selections$selected_geo == "ctus") {
        sf::st_drop_geometry(ctu_list[ctu_list$GEO_NAME == param_area(), ])
      } else if (geo_selections$selected_geo == "nhood") {
        sf::st_drop_geometry(nhood_list[nhood_list$GEO_NAME == param_area(), ])
      } else if (geo_selections$selected_geo == "blockgroups") {
        sf::st_drop_geometry(mn_bgs[mn_bgs$GEOID == param_area(), ])
      }
      return(output)
    })
    
    # the min/max/other data for all blockgroups within a given ctu/nhood/blockgroup (n = 1 for blockgroups, n > 1 for most ctus/nhoods)
    param_selectedblockgroupvalues <- reactive({
      req(TEST() != "")
      output <- filter(
        (map_util$map_data),
        bg_string %in%
          if (geo_selections$selected_geo == "ctus") {
            c(ctu_crosswalk[ctu_crosswalk$GEO_NAME == param_area(), ]$bg_id)
          } else if (geo_selections$selected_geo == "nhood") {
            c(nhood_crosswalk[nhood_crosswalk$GEO_NAME == param_area(), ]$bg_id)
          } else {
            c(param_area())
          }
      )
      return(output)
    })
    
    selected_length <- reactive({
      req(TEST() != "")
      nrow(param_selectedblockgroupvalues())
    })
    
    # all data with flag for selected areas
    param_dl_data <- reactive({
      req(TEST() != "")
      
      output <- bg_growingshade_main %>%
        mutate(flag = if_else(bg_string %in%
                                if (geo_selections$selected_geo == "ctus") {
                                  c(ctu_crosswalk[ctu_crosswalk$GEO_NAME == param_area(), ]$bg_id)
                                } else if (geo_selections$selected_geo == "nhood") {
                                  c(nhood_crosswalk[nhood_crosswalk$GEO_NAME == param_area(), ]$bg_id)
                                } else if (geo_selections$selected_geo == "blockgroups") {
                                  c(param_area())
                                },
                              "selected", NA_character_
        ))
      return(output)
    })
    
    param_equity <- reactive({
      equityplot <- param_dl_data() %>%
        filter(variable %in% c("pbipoc", "canopy_percent", "hhincome", "avg_temp")) %>%
        select(bg_string, variable, raw_value, flag) %>%
        pivot_wider(names_from = variable, values_from = raw_value)
      return(equityplot)
    })
    
    
    output$geoarea <- renderUI({
      ns <- session$ns
      tagList(
        HTML(paste0(
          "<h2><section style='font-size:20pt'>Growing Shade report for ",
          if (geo_selections$selected_geo == "blockgroups") {
            param_areasummary()$fancyname
          } else {
            param_area()
          }, "</h2></section>"
        ))
      )
    })
    
    tree_text <- reactive({
      req(TEST() != "")
      tagList(HTML(
        paste0(
          if (geo_selections$selected_geo == "blockgroups") {
            paste0(
              param_areasummary()$fancyname, " has an existing tree canopy coverage of ", round(param_areasummary()$canopy_percent, 2),
              "%. Compared to other block groups across Dane County, the tree canopy in the selected block group is ",
              if (param_areasummary()$canopy_percent > (param_areasummary()$avgcanopy + 2)) {
                "above"
              } else if (param_areasummary()$canopy_percent < (param_areasummary()$avgcanopy - 2)) {
                "below"
              } else {
                "about equal to"
              },
              " average (", round(param_areasummary()$avgcanopy, 1), "%).<br><br> ",
              "The plot below shows how tree canopy cover in the selected block group (shown in green) compares to other block groups across Dane County." 
              #"In most areas, a goal of 45% tree canopy coverage (as detected by our methods) is suitable."
            )
          } else {
            paste0(
              param_area(),
              " has an existing tree canopy coverage of ", round(param_areasummary()$canopy_percent, 1),
              "%. Compared to other ", if (geo_selections$selected_geo == "ctus") {
                "cities and townships"
              } else {
                "neighborhoods"
              },
              " across ", if (geo_selections$selected_geo == "ctus") {
                "Dane County"
              } else {
                (param_areasummary()$city)
              },
              ", the tree canopy in ", param_area(), " is ",
              if (param_areasummary()$canopy_percent > (param_areasummary()$avgcanopy + 2)) {
                "above"
              } else if (param_areasummary()$canopy_percent < (param_areasummary()$avgcanopy - 2)) {
                "below"
              } else {
                "about equal to"
              },
              " average (", round(param_areasummary()$avgcanopy, 1), "%). ",
              "Within ", param_area(), ", there are ",
              param_areasummary()$n_blockgroups,
              " Census block groups with tree canopy cover ranging from ",
              param_areasummary()$min,
              "% to ",
              param_areasummary()$max,
              "%. <br><br>The plot below shows how tree canopy cover in the selected area (shown in green) compares to other areas across Dane County. Within the selected area, tree canopy cover varies across census block groups."
            )
          }
        )
      ))
    })
    
    report_tree_plot <- reactive({
      req(TEST() != "")
      set.seed(12345)
      if (geo_selections$selected_geo != "blockgroups") {
        canopyplot <-
          (as_tibble(if (geo_selections$selected_geo == "ctus") {
            ctu_list
          } else {
            nhood_list
          }) %>%
            mutate(flag = if_else(GEO_NAME == param_area(), "selected", NA_character_)) %>%
            rename(bg_string = GEO_NAME) %>%
            select(bg_string, canopy_percent, flag) %>%
            mutate(type = if (geo_selections$selected_geo == "ctus") {
              "Cities across\nthe county"
            } else {
              paste0("Neighborhoods across\n", param_areasummary()$city)
            })) %>%
          bind_rows(filter(param_equity(), flag == "selected") %>%
                      mutate(
                        t2 = "block groups",
                        type = paste0(" Block groups\nwithin ", param_area())
                      )) %>%
          rename(raw_value = canopy_percent)
        } else {
        canopyplot <- param_equity() %>%
          rename(raw_value = canopy_percent)
      }
      
      if (geo_selections$selected_geo != "blockgroups") {
        plot <- ggplot() +
          councilR::theme_council() +
          theme(
            plot.title = element_text(size = 16),
            panel.grid.minor = element_blank(),
            panel.grid.major.y = element_blank(),
            axis.text.y = element_text(size = 12),
            plot.caption = element_text(
              size = rel(1),
              colour = "grey30"
            )
          ) +
          ggbeeswarm::geom_beeswarm(
            size = 2.5,
            alpha = .3,
            cex = 3,
            method = "compactswarm",
            col = "grey40",
            aes(x = raw_value, y = type),
            data = filter(canopyplot, is.na(flag)),
            na.rm = T
          ) +
          labs(
            y = "", x = "Tree canopy cover (%)",
            caption = "\nSource: Analysis of Sentinel-2 satellite imagery"
          ) +
          scale_x_continuous(labels = scales::label_percent(accuracy = 1, scale = 1)) +
          geom_point(aes(x = raw_value, y = type),
                     fill = councilR::colors$cdGreen,
                     size = 4, col = "black", pch = 21, stroke = 1, 
                     data = filter(canopyplot, flag == "selected", is.na(t2))
          ) +
          
          ggbeeswarm::geom_beeswarm(aes(x = raw_value, y = type),
                                    cex = if (selected_length() > 100) {2} else {3}, 
                                    stroke = if(selected_length() > 100) {0} else {1},
                                    size = if (selected_length() > 100) {2} else {3},
                                    corral = "wrap", corral.width = 0.7,
                                    fill = councilR::colors$cdGreen, 
                                    col = "black", pch = 21, alpha = .8,
                                    data = filter(canopyplot, flag == "selected", t2 == "block groups"),
                                    method = "compactswarm",
                                    na.rm = T
          ) 
        
      } else {
        plot <- ggplot() +
          councilR::theme_council() +
          theme(
            panel.grid.minor = element_blank(),
            panel.grid.major.y = element_blank(),
            plot.title = element_text(size = 16),
            axis.text.y = element_blank(),
            plot.caption = element_text(
              size = rel(1),
              colour = "grey30"
            )
          ) +
          ggbeeswarm::geom_quasirandom(
            groupOnX = F, varwidth = T,
            cex = 1,
            alpha = .3,
            col = "grey40",
            aes(x = raw_value, y = 1),
            data = filter(canopyplot, is.na(flag)),
            na.rm = T
          ) +
          
          labs(
            y = "", x = "Tree canopy cover (%)",
            caption = "\nSource: Analysis of Sentinel-2 satellite imagery"
          ) +
          scale_x_continuous(labels = scales::label_percent(accuracy = 1, scale = 1)) +
          geom_point(aes(x = raw_value, y = 1),
                     fill = councilR::colors$cdGreen,
                     size = 5, col = "black", pch = 21, stroke = 1, 
                     data = filter(canopyplot, flag == "selected"),
                     na.rm = T
          )
      }
      return(plot)
    })
    
    
    output$tree_plot <- renderImage(
      {
        req(TEST() != "")
        
        # A temp file to save the output.
        # This file will be removed later by renderImage
        outfile <- tempfile(fileext = ".png")
        
        # Generate the PNG
        png(outfile,
            width = 500 * 2,
            height = 300 * 2,
            res = 72 * 2
        )
        print(report_tree_plot())
        dev.off()
        
        # Return a list containing the filename
        list(
          src = outfile,
          contentType = "image/png",
          width = 500,
          height = 300,
          alt = "Figure showing the distribution of tree canopy across Dane County and within the selected geography."
        )
      },
      deleteFile = TRUE
    )
    
    # ranking section ------------
    
    rank_text <- reactive({
      req(TEST() != "")
      
      #are we using 1 or 2 themes?
      if (is.na(map_selections$theme2[1]) | is.na(map_selections$theme2[2])) {
        both_themes <- FALSE
      } else {
        both_themes <- TRUE
      }
      
      theme_data <- map_util$map_data2 %>% 
        distinct()
      
      rank_stats <- param_dl_data() %>%
        #only block groups for selected area
        filter(flag == "selected") %>% 
        ungroup() %>% 
        select(bg_string) %>% 
        distinct() %>%
        left_join(theme_data, by = join_by(bg_string == GEO_NAME)) %>%
        select(bg_string, SUM) %>% 
        group_by(SUM) %>% 
        summarise(n())
      
      
      #text for 1 theme
      if(!both_themes) {
      tagList(HTML(
        paste0(
          if (geo_selections$selected_geo == "blockgroups") {
            paste0(
              param_areasummary()$fancyname,
              if(rank_stats[1,1] %>% paste() == "NA") {
                paste0(
                " is <b>not</b> a priority area using your selected theme.
                 The graph below shows how this block group scores for each theme. 
                  The red lines show the highest possible score for each theme."
                )
              } else {
                paste0(
                  " is a priority area using ",
                  strong(tolower(rank_stats[1,1] %>% paste())),
                  ". The graph below shows how this block group scores for each theme. 
                  The red lines show the highest possible score for each theme."
                )
              })
            } else {
              paste0(
                "In ",
                param_area(),
                ", ",
                rank_stats %>% 
                  filter(SUM == map_selections$theme2[1]) %>% 
                  summarise(sum(`n()`)) %>% 
                  paste(),
                " block groups are a priority area using ",
                strong(tolower(map_selections$theme2[1])),
                " and ",
                rank_stats %>% 
                  filter(is.na(SUM)) %>% 
                  summarise(sum(`n()`)) %>% 
                  paste(),
                " block groups are not a priority area.",
                " There are ",
                param_areasummary()$n_blockgroups,
                " total block groups. Each block group is compared to Dane County when determining prioritization. <br><br> The graph below shows the block group scores for each included theme.
                For the Socioeconomic Indicators theme, a block group must score 2 or higher to be a priority area.
                For all other themes, a block group must score 1 or higher to be a priority area."
              )
          }
        )
      ))
        # text for 2 themes
      } else {
         tagList(HTML(
        paste0(
          if (geo_selections$selected_geo == "blockgroups") {
            paste0(
              param_areasummary()$fancyname,
              if(rank_stats[1,1] %>% paste() == "NA") {
                paste0(
                  " is <b>not</b> a priority area using your selected themes.
                  The graph below shows how this block group scores for each theme. 
                  The red lines show the total possible score for each theme."
                )
              } else {
                paste0(
                  " is a priority area using ",
                  strong(tolower(rank_stats[1,1] %>% paste())),
                  ". The graph below shows how this block group scores for each theme. 
                  The red lines show the total possible score for each theme."
                  )
              })
            } else {
            paste0(
             "In ",
             param_area(),
             ", ",
             rank_stats %>% 
               filter(SUM == map_selections$theme2[1] | SUM == "Both Themes") %>% 
               summarise(sum(`n()`)) %>% 
               paste(),
             " block groups are a priority area using ",
              strong(tolower(map_selections$theme2[1])),
             ", ",
             rank_stats %>% 
               filter(SUM == map_selections$theme2[2] | SUM == "Both Themes") %>% 
               summarise(sum(`n()`)) %>% 
               paste(),
             " block groups are a priority area using ",
             strong(tolower(map_selections$theme2[2])),
             ", ",
             rank_stats %>% 
               filter(SUM == "Both Themes") %>% 
               summarise(sum(`n()`)) %>% 
               paste(),
             " block groups are a priority area using",
             strong(" both themes"),
             ", and ",
             rank_stats %>% 
               filter(is.na(SUM)) %>% 
               summarise(sum(`n()`)) %>% 
               paste(),
             " block groups are not a priority area.",
             " There are ",
              param_areasummary()$n_blockgroups,
             " total block groups. Each block group is compared to Dane County when determining prioritization. <br><br> The graph below shows the block group scores for each included theme.
                For the Socioeconomic Indicators theme, a block group must score 2 or higher to be a priority area.
                For all other themes, a block group must score 1 or higher to be a priority area."
            )
          }
        )
      ))
      }
    })
    
    report_rank_plot <- reactive({
      req(TEST() != "")
      set.seed(12345)
     
      #are we using 1 or 2 themes?
      if (is.na(map_selections$theme2[1]) | is.na(map_selections$theme2[2])) {
        both_themes <- FALSE
      } else {
        both_themes <- TRUE
      }
      
        if(map_selections$theme2[1] == "Custom" | (!is.na(map_selections$theme2[2]) & map_selections$theme2[2] == "Custom")) {
      metadata <- metadata %>% 
        mutate(custom = case_when(name %in% map_selections$allInputs$value ~ 1,
                                  TRUE ~ 0)
        )
      }
      
      theme_data <- map_util$map_data2 %>% 
        distinct()
      
      
      plot_data <- param_dl_data() %>%
        #only block groups for selected area
        filter(flag == "selected") %>% 
        ungroup() %>% 
        select(bg_string) %>% 
        distinct() %>%
        left_join(theme_data, by = join_by(bg_string == GEO_NAME))
      
      #for ctu and neighborhoods
      if (geo_selections$selected_geo != "blockgroups") {
        #create a graph for both themes
        if (both_themes) {
          plot_data <- plot_data %>% select(bg_string, map_selections$theme2[1], map_selections$theme2[2])
          #get distribution of all combinations of scores
          plot_data <- xyTable((select(plot_data, as.name(map_selections$theme2[1]))[[1]]), (select(plot_data, as.name(map_selections$theme2[2]))[[1]])) %>% 
            as.data.frame()
          
          #match color to scheme for map
          plot_data <- plot_data %>% 
                  mutate(color_key = case_when(x == 0 & y == 0 ~ "none",
                                           x > 0 & y == 0 ~ "one",
                                           x == 0 & y > 0 ~ "two",
                                           x > 0 & y > 0 ~ "both",
                                           TRUE ~ "error"))
          
          group.colors <- c(none = "#ffffff", one = "#d95f02", two ="#1b9e77", both = "#7570b3")
          
          x_breaks <- metadata %>% 
            select(as.name(tolower(map_selections$theme2[1]) %>% 
                             gsub(" ", "_", .))) %>% 
            sum()
          
          y_breaks <- metadata %>% 
            select(as.name(tolower(map_selections$theme2[2]) %>% 
                             gsub(" ", "_", .))) %>% 
            sum()
          
          plot <- ggplot(plot_data, aes(x=x, y=y, size=number, fill = color_key)) + 
            #geom_point(alpha=0.5, shape=21, color="#77a12e", fill="#77a12e") +
            geom_point(alpha=0.5, shape=21, color="#77a12e") +
            #Not doing anything...
            scale_fill_manual(values=group.colors) +
            scale_size(range = c(5, 15)) +
            scale_y_continuous(breaks = seq(0, y_breaks, by=1), limits = c(-.1, y_breaks+.1)) +
            scale_x_continuous(breaks = seq(0, x_breaks, by=1), limits = c(0, x_breaks)) +
            geom_text(aes(x, y, label = number, size = .1)) +
            labs(x = paste(map_selections$theme2[1], "Score"), y = paste(map_selections$theme2[2], "Score")) +
            theme_light() +
            theme(legend.position = "none")
        
          #only graph for one theme
        } else {
          plot_data <- plot_data %>% 
            select(bg_string, map_selections$theme2[1]) %>% 
            group_by(!!as.name(map_selections$theme2[1])) %>% 
            summarise(number = n()) %>%
            rename(x = map_selections$theme2[1])
          
          x_breaks <- metadata %>% 
            select(as.name(tolower(map_selections$theme2[1]) %>% 
                             gsub(" ", "_", .))) %>% 
            sum()
          
          plot <- ggplot(plot_data, aes(x=x, y=number)) +
            geom_segment( aes(x=x, xend=x, y=0, yend=number), color="#77a12e") +
            geom_point( color="#77a12e", size=4, alpha=0.6) +
            scale_x_continuous(breaks = seq(0, x_breaks, by=1), limits = c(0, x_breaks)) +
            scale_y_continuous() +
            labs(x = paste(map_selections$theme2[1], "Score"), y = "Block Groups") +
            coord_flip() +
            theme_light()+
            theme(
              panel.grid.major.y = element_blank(),
              panel.border = element_blank(),
              axis.ticks.y = element_blank()
            )
          
        }
      
      #for block groups  
      } else {
        
        test2 <- tibble()

        test <- param_selectedblockgroupvalues() %>%
          st_drop_geometry() %>%
          dplyr::select(`Health Disparities`, Temperature, `Socioeconomic Indicators`, `Canopy Cover`, GEO_NAME) %>%
          pivot_longer(names_to = "priority", values_to = "score", -GEO_NAME) %>%
          bind_rows(test2) %>% 
          distinct()

        plot <- ggplot(test, aes(x=score, y=priority)) + 
          geom_point(alpha=0.5, shape=21, size = 5, color="#77a12e", fill="#77a12e") +
          scale_x_continuous(limits=c(0,6)) +
          theme_light() +
          #add lines showing the highest score for each theme
          geom_segment(aes(x = 1, y = .7, xend = 1, yend = 1.3), color="red") +
          geom_segment(aes(x = 5, y = 1.7, xend = 5, yend = 2.3), color="red") +
          geom_segment(aes(x = 6, y = 2.7, xend = 6, yend = 3.3), color="red") +
          geom_segment(aes(x = 1, y = 3.7, xend = 1, yend = 4.3), color="red")
      }
      
    
     return(plot)
      
    })
    
    
    output$rank_plot <- renderImage(
      {
        req(TEST() != "")
        
        # A temp file to save the output.
        # This file will be removed later by renderImage
        outfile <- tempfile(fileext = ".png")
        
        # Generate the PNG
        png(outfile,
            width = 500 * 2,
            height = 300 * 2,
            res = 72 * 2
        )
        print(report_rank_plot())
        dev.off()
        
        # Return a list containing the filename
        list(
          src = outfile,
          contentType = "image/png",
          width = 500,
          height = 300,
          alt = "Figure showing the priority ranking (climate change, conservation, environmental justice, public health) for all block groups within the selected geography."
        )
      },
      deleteFile = TRUE
    )
    
    # priority section -----------
    
    report_priority_table <- reactive({
      req(TEST() != "")
      
        #are we using 1 or 2 themes?
        if (is.na(map_selections$theme2[1]) | is.na(map_selections$theme2[2])) {
          both_themes <- FALSE
        } else {
          both_themes <- TRUE
        }
      
      if(map_selections$theme2[1] == "Custom" | (!is.na(map_selections$theme2[2]) & map_selections$theme2[2] == "Custom")) {
      metadata <- metadata %>% 
        mutate(custom = case_when(name %in% map_selections$allInputs$value ~ 1,
                                  TRUE ~ 0)
        )
      }
      
      var_theme_1 <- param_dl_data() %>%
          filter(name %in%
                   if (map_selections$theme2[1] == "Socioeconomic Indicators") {
                     metadata[metadata$socioeconomic_indicators == 1, ]$name
                   } else if (map_selections$theme2[1] == "Temperature") {
                     metadata[metadata$temperature == 1, ]$name
                   } else if (map_selections$theme2[1] == "Health Disparities") {
                     metadata[metadata$health_disparities == 1, ]$name
                   } else if (map_selections$theme2[1] == "Canopy Cover") {
                     metadata[metadata$canopy_cover == 1, ]$name
                   } else if (map_selections$theme2[1] == "Custom") {
                     metadata[metadata$custom == 1, ]$name
                   }) %>%
          filter(flag == "selected") %>%
          add_column(order = 2) %>%
          add_column(grouping = "Selected area") %>% 
          group_by(grouping, name, order) %>%
          summarise(
            RAW = mean(raw_value, na.rm = T),
            SE = sd(raw_value, na.rm = T) / sqrt(n()),
            score = sum(significance)
          )

        if (both_themes) {
        var_theme_2 <- param_dl_data() %>%
          filter(name %in%
                   if (map_selections$theme2[2] == "Socioeconomic Indicators") {
                     metadata[metadata$socioeconomic_indicators == 1, ]$name
                   } else if (map_selections$theme2[2] == "Temperature") {
                     metadata[metadata$temperature == 1, ]$name
                   } else if (map_selections$theme2[2] == "Health Disparities") {
                     metadata[metadata$health_disparities == 1, ]$name
                   } else if (map_selections$theme2[2] == "Canopy Cover") {
                     metadata[metadata$canopy_cover == 1, ]$name
                   } else if (map_selections$theme2[2] == "Custom") {
                     c(map_selections$allInputs$value)
                   }) %>%
          filter(flag == "selected") %>%
          add_column(order = 2) %>%
          add_column(grouping = "Selected area") %>%
          group_by(grouping, name, order) %>%
          summarise(
            RAW = mean(raw_value, na.rm = T),
            SE = sd(raw_value, na.rm = T) / sqrt(n()),
            score = sum(significance)
          )

        combined <- bind_rows(var_theme_1, var_theme_2)
        }
      
      if(geo_selections$selected_geo != "blockgroups") {
      #create the table for 1 theme
      if (!both_themes) {
        
      x <- var_theme_1 %>%
        full_join(metadata %>%
                    filter(!!rlang::sym(gsub(" ", "_", tolower(map_selections$theme2[1]))) == 1) %>% 
                    add_column(
                      grouping = "County average",
                      order = 2
                    ) %>%
                    rename(RAW = MEANRAW),
                  by = c("grouping", "name", "order", "RAW")
        ) %>%
        ungroup() %>% 
        select(grouping, name, RAW) %>% 
        filter(!is.na(name)) %>%
        pivot_wider(names_from = grouping, values_from = RAW) %>%
        rename(Variable = name) %>%
        mutate(`County average` = case_when(
          str_detect(`Variable`, "%") ~ paste0(round(`County average`, 2), "%"),
          TRUE ~ as.character(round(`County average`, 2))
        )) %>%
        mutate(`Selected area` = case_when(
          str_detect(`Variable`, "%") ~ paste0(round(`Selected area`, 2), "%"),
          TRUE ~ as.character(round(`Selected area`, 2))
        ))
      #create the table for 2 themes
      } else {
        x <- combined %>%
          full_join(metadata %>%
                      filter(!!rlang::sym(gsub(" ", "_", tolower(map_selections$theme2[1]))) == 1 | !!rlang::sym(gsub(" ", "_", tolower(map_selections$theme2[2]))) == 1) %>%
                      add_column(
                        grouping = "Region average",
                        order = 2
                      ) %>%
                      rename(RAW = MEANRAW),
                    by = c("grouping", "name", "order", "RAW")
          ) %>%
          ungroup() %>%
          select(grouping, name, RAW) %>%
          filter(!is.na(name)) %>%
          pivot_wider(names_from = grouping, values_from = RAW) %>%
          rename(Variable = name) %>%
          mutate(`Region average` = case_when(
            str_detect(`Variable`, "%") ~ paste0(round(`Region average`, 2), "%"),
            TRUE ~ as.character(round(`Region average`, 2))
          )) %>%
          mutate(`Selected area` = case_when(
            str_detect(`Variable`, "%") ~ paste0(round(`Selected area`, 2), "%"),
            TRUE ~ as.character(round(`Selected area`, 2))
          ))
      }
        
      #for block groups include variable scores
      } else {
        #create the table for 1 theme
        if (!both_themes) {
          x_s1 <- var_theme_1 %>%
            full_join(metadata %>%
                        filter(!!rlang::sym(gsub(" ", "_", tolower(map_selections$theme2[1]))) == 1) %>% 
                        add_column(
                          grouping = "Region average",
                          order = 2
                        ) %>%
                        rename(RAW = MEANRAW),
                      by = c("grouping", "name", "order", "RAW")
            ) %>%
            ungroup() %>% 
            select(grouping, name, RAW, score) %>% 
            filter(!is.na(name)) %>% 
            pivot_wider(names_from = grouping, values_from = RAW) %>% 
            rename(Variable = name)

          x2 <- x_s1 %>%
            select(Variable, score, `Selected area`) %>% 
            na.omit() %>% 
            mutate(`Selected area` = case_when(
              str_detect(`Variable`, "%") ~ paste0(round(`Selected area`, 2), "%"),
              TRUE ~ as.character(round(`Selected area`, 2))
            ))
          
          x3 <- x_s1 %>% 
              select(Variable, `Region average`) %>% 
              na.omit() %>%  
            mutate(`Region average` = case_when(
            str_detect(`Variable`, "%") ~ paste0(round(`Region average`, 2), "%"),
            TRUE ~ as.character(round(`Region average`, 2))
          ))
          
          x <- left_join(x2, x3, by = c("Variable" = "Variable")) %>% 
            relocate(score, .after = `Region average`) %>% 
            rename(Score = score) %>% 
            mutate(Score = as.integer(Score))
            
        #create the table for 2 themes
        } else {
          x_s1 <- combined %>%
            full_join(metadata %>%
                        filter(!!rlang::sym(gsub(" ", "_", tolower(map_selections$theme2[1]))) == 1 | !!rlang::sym(gsub(" ", "_", tolower(map_selections$theme2[2]))) == 1) %>%
                        add_column(
                          grouping = "Region average",
                          order = 2
                        ) %>%
                        rename(RAW = MEANRAW),
                      by = c("grouping", "name", "order", "RAW")
            ) %>%
            ungroup() %>%
            select(grouping, name, RAW, score) %>%
            filter(!is.na(name)) %>%
            pivot_wider(names_from = grouping, values_from = RAW) %>%
            rename(Variable = name)
          
          
          x2 <- x_s1 %>%
            select(Variable, score, `Selected area`) %>% 
            na.omit() %>% 
            mutate(`Selected area` = case_when(
              str_detect(`Variable`, "%") ~ paste0(round(`Selected area`, 2), "%"),
              TRUE ~ as.character(round(`Selected area`, 2))
            ))
          
          x3 <- x_s1 %>% 
            select(Variable, `Region average`) %>% 
            na.omit() %>%  
            mutate(`Region average` = case_when(
              str_detect(`Variable`, "%") ~ paste0(round(`Region average`, 2), "%"),
              TRUE ~ as.character(round(`Region average`, 2))
            ))
          
          x <- left_join(x2, x3, by = c("Variable" = "Variable")) %>% 
            relocate(score, .after = `Region average`) %>% 
            rename(Score = score) %>% 
            mutate(Score = as.integer(Score))
          
          
        }
      }
      
      return(x)
    })
    
    
    output$priority_table <- renderTable(striped = TRUE, {
      req(TEST() != "")
      report_priority_table()
    })
    
    equity_text <- reactive({
      ns <- session$ns
      req(TEST() != "")
      para <- HTML(paste0(
        "Research shows that trees are not distributed equitably across communities. Lower-income areas (<a href='https://doi.org/10.1371/journal.pone.0249715' target = '_blank'>McDonald et al. 2021</a>) and areas with more people identifying as persons of color (<a href = 'https://doi.org/10.1016/j.jenvman.2017.12.021' target='_blank'>Watkins and Gerris 2018</a>) have less tree canopy. Trends in Dane County are shown below; ",
        if (geo_selections$selected_geo == "blockgroups") {
          paste0(param_areasummary()$fancyname, " is ")
        } else {
          paste0(
            "block groups within ",
            param_area(),
            " are "
          )
        },
        "in green and the county-wide trend is in blue.<br><br>"
      ))
      return(para)
    })
    
    heat_text <- reactive({
      ns <- session$ns
      req(TEST() != "")
      para <- HTML(paste0(
        "Trees and other green space help cool temperatures. Temperature differences between moderate and high amounts of green space can be up to 10 degrees. Adding green space can reduce heat-related deaths (<a href='https://www.sciencedirect.com/science/article/abs/pii/S030438002100123X' target = '_blank'>Sinha et al. 2021</a>). The impact of green space on temperature is shown below. ",
        if (geo_selections$selected_geo == "blockgroups") {
          paste0(param_areasummary()$fancyname, " is ")
        } else {
          paste0(
            "Block groups within ",
            param_area(),
            " are "
          )
        },
        "in green and the county-wide trend is in blue.<br><br>"
      ))
      return(para)
    })
    
    report_equity_plot <- reactive({
      req(TEST() != "")
      df <- param_equity() %>%
        select(flag, canopy_percent, hhincome, pbipoc) %>%
        pivot_longer(names_to = "names", values_to = "raw_value", -c(flag, canopy_percent)) %>%
        mutate(raw_value = if_else(names == "pbipoc", raw_value, raw_value))
      
      fig_equity <-
        ggplot(aes(x = raw_value, y = canopy_percent), data = df) +
        geom_point(col = "grey40", alpha = .2, data = filter(df, is.na(flag)), na.rm = T) +
        geom_smooth(method = "gam", formula = y ~ s(x, bs = "cs"),
          fill = NA, col = councilR::colors$councilBlue, na.rm = T,
          data = filter(df, names != "pbipoc")
        ) +
        geom_smooth( method = "lm",
                     formula = "y ~ x",
                     fill = NA, col = councilR::colors$councilBlue, na.rm = T,
                     data = filter(df, names == "pbipoc")
        ) +
        geom_point(fill = councilR::colors$cdGreen, 
                   stroke = if(selected_length() > 100) {.5} else {1},
                   size = if (selected_length() > 100) {2} else {4},
                   col = "black", 
                   pch = 21, 
                   data = filter(df, flag == "selected"), 
                   na.rm = T) +
        councilR::theme_council() +
        theme(
          panel.grid.minor = element_blank(),
          panel.grid.major = element_blank(),
          strip.placement = "outside",
          axis.title.y = element_text(
            angle = 0,
            vjust = .5
          ),
          plot.margin = margin(7, 7, 7, 7),
          axis.line = element_line(),
          axis.ticks = element_line(),
          axis.text.y = element_text(vjust = .5, hjust = 1),
          plot.caption = element_text(
            size = rel(1),
            colour = "grey30"
          )
        ) +
        scale_y_continuous(
          labels = scales::label_percent(accuracy = 1, scale = 1)
        ) +
        scale_x_continuous(
          labels = scales::comma,
          expand = expansion(mult = c(0, .1))
        ) +
        labs(
          x = "", y = "Tree\ncanopy\n (%)",
          caption =
            "Source: Analysis of Sentinel-2 satellite imagery, ACS 5-year \nestimates (2016-2020), and decennial census (2020)" # ))
        ) +
        facet_wrap(~names,
                   scales = "free_x", nrow = 2, strip.position = "bottom",
                   labeller = as_labeller(c(pbipoc = "Population identifying as\nperson of color (%)", hhincome = "Median household\nincome ($)"))
        )
      
      
      return(fig_equity)
    })
    
    output$equity_plot <- renderImage(
      {
        req(TEST() != "")
        
        # A temp file to save the output.
        # This file will be removed later by renderImage
        outfile <- tempfile(fileext = ".png")
        
        # Generate the PNG
        png(outfile,
            width = 400 * 4,
            height = 450 * 4,
            res = 72 * 4
        )
        print(report_equity_plot())
        dev.off()
        
        # Return a list containing the filename
        list(
          src = outfile,
          contentType = "image/png",
          width = 400,
          height = 450,
          alt = "Figure showing the trends between tree canopy and median household income and the percent of population identifying as a person of color."
        )
      },
      deleteFile = TRUE
    )
    
    param_reportname <- reactive({
      req(TEST() != "")
      paste0("GrowingShade_", param_area(), "_", Sys.Date(), ".html")
    })
    
    
    output$dl_report <- downloadHandler(
      filename = param_reportname,
      content = function(file) {
        tempReport <- file.path(tempdir(), "downloadable_report.Rmd")
        tempCss <- file.path(tempdir(), "style.css")
        tempbdcn <- file.path(tempdir(), "helveticaneueltstd-bdcn-webfont.woff")
        tempcn <- file.path(tempdir(), "helveticaneueltstd-cn-webfont.woff")
        templt <- file.path(tempdir(), "helveticaneueltstd-lt-webfont.woff")
        tempmd <- file.path(tempdir(), "helveticaneueltstd-md-webfont.woff")
        tempmdcn <- file.path(tempdir(), "helveticaneueltstd-mdcn-webfont.woff")
        temproman <- file.path(tempdir(), "helveticaneueltstd-roman-webfont.woff")
        file.copy("downloadable_report.Rmd", tempReport, overwrite = TRUE)
        file.copy("inst/app/www/style.css", tempCss, overwrite = TRUE)
        file.copy("inst/app/www/helveticaneueltstd-bdcn-webfont.woff", tempbdcn, overwrite = TRUE)
        file.copy("inst/app/www/helveticaneueltstd-cn-webfont.woff", tempcn, overwrite = TRUE)
        file.copy("inst/app/www/helveticaneueltstd-lt-webfont.woff", templt, overwrite = TRUE)
        file.copy("inst/app/www/helveticaneueltstd-md-webfont.woff", tempmd, overwrite = TRUE)
        file.copy("inst/app/www/helveticaneueltstd-mdcn-webfont.woff", tempmdcn, overwrite = TRUE)
        file.copy("inst/app/www/helveticaneueltstd-roman-webfont.woff", temproman, overwrite = TRUE)
        
        imgOne <- file.path(tempdir(), "test.png")

        # Set up parameters to pass to Rmd document
        params <- list(
          param_geo = geo_selections$selected_geo,
          param_area = if (geo_selections$selected_geo == "blockgroups") {param_areasummary()$fancyname} else {param_area()},
          param_equitypara = tree_text(),
          param_treeplot = report_tree_plot(),
          param_ranktext = rank_text(),
          param_rankplot = report_rank_plot(),
          param_prioritytable = report_priority_table(),
          param_equitytext = equity_text(),
          param_equityplot = report_equity_plot()
        )
        # Knit the document, passing in the `params` list, and eval it in a
        # child of the global environment (this isolates the code in the document
        # from the code in this app).
        # testcss <- file.path("style.css")
        rmarkdown::render(tempReport,
                          output_file = file,
                          params = params,
                          envir = new.env(parent = globalenv()),
                          output_format = "html_document",
                          output_options = list(
                            html_preview = FALSE,
                            toc = TRUE,
                            toc_depth = 2,
                            fig_caption = TRUE,
                            css = tempCss
                          )
        )
      }
    )
    
    
    
    output$dl_data <- downloadHandler(
      filename = function() {
        paste0("GrowingShade_", param_area(), "_", Sys.Date(), ".xlsx")
      },
      content = function(file) {
        writexl::write_xlsx(
          list(
            "Metadata" = metadata %>%
              filter(!is.na(name)) %>%
              mutate(nicer_interp = case_when(
                nicer_interp != "" ~ nicer_interp,
                niceinterp == "Lower" ~ "Lower values = higher priority",
                niceinterp == "Higher" ~ "Higher values = higher priority"
              )) %>%
              select(variable, name, nicer_interp, MEANRAW, temperature, socioeconomic_indicators, health_disparities, canopy_cover, n) %>%
              rename(
                `Variable` = variable,
                `Variable description` = name,
                `Value interpretation` = nicer_interp,
                `Region average` = MEANRAW,
                `Temperature variable` = temperature,
                `Socioeconomic Indicators variable` = socioeconomic_indicators,
                `Health Disparities variable` = health_disparities,
                `Canopy Cover variable` = canopy_cover,
                `Number of block groups with data` = n
              ),
            "Selected Area" =
              (param_selectedblockgroupvalues() %>%
                 select(
                   GEO_NAME, jurisdiction, canopy_percent, SUM,
                   "Health Disparities", "Canopy Cover", "Socioeconomic Indicators", "Temperature"
                 ) %>%
                 rename(
                   GEO_ID = GEO_NAME,
                   `Selected priority score` = SUM,
                   `Temperature priority score` = `Temperature`,
                   `Canopy cover priority score` = `Canopy Cover`,
                   `Socioeconomic indicators priority score` = `Socioeconomic Indicators`,
                   `Health Disparities priority score` = `Health Disparities`,
                   `Percent tree cover` = canopy_percent
                 ) %>%
                 left_join(bg_growingshade_main %>%
                             select(bg_string, variable, raw_value) %>%
                             pivot_wider(names_from = variable, values_from = raw_value) %>%
                             rename(GEO_ID = bg_string), by = c("GEO_ID")))
            ,
            "Entire Region" = bg_growingshade_main %>%
              select(bg_string, variable, raw_value) %>%
              pivot_wider(names_from = variable, values_from = raw_value) %>%
              rename(GEO_ID = bg_string)
          ),
          path = file
        )
      }
    )
    
    
    output$shapefile_dl <- downloadHandler(
      
      filename <- function() {
        paste0("GrowingShade_", param_area(), "_", Sys.Date(), ".zip")
      },
      content = function(file) {
        withProgress(message = "Exporting Data", {
          
          incProgress(0.5)
          tmp.path <- dirname(file)
          
          name.base <- file.path(tmp.path, "GrowingShade")
          name.glob <- paste0(name.base, ".*")
          name.shp  <- paste0(name.base, ".shp")
          name.zip  <- paste0(name.base, ".zip")
          
          if (length(Sys.glob(name.glob)) > 0) file.remove(Sys.glob(name.glob))
          sf::st_write((param_selectedblockgroupvalues() %>%
                          select(
                            GEO_NAME, jurisdiction, canopy_percent, SUM,
                            "Health Disparities", "Canopy Cover", "Socioeconomic Indicators", "Temperature"
                          ) %>%
                          rename(
                            GEO_ID = GEO_NAME,
                            `Selected priority score` = SUM,
                            `Temperature priority score` = `Temperature`,
                            `Canopy cover priority score` = `Canopy Cover`,
                            `Socioeconomic indicators priority score` = `Socioeconomic Indicators`,
                            `Health Disparities priority score` = `Health Disparities`,
                            `Percent tree cover` = canopy_percent
                          ) %>%
                          left_join(bg_growingshade_main %>%
                                      select(bg_string, variable, raw_value) %>%
                                      pivot_wider(names_from = variable, values_from = raw_value) %>%
                                      
                                      rename(GEO_ID = bg_string), by = c("GEO_ID"))),
                       dsn = name.shp,
                       driver = "ESRI Shapefile", quiet = TRUE)
          
          zip::zipr(zipfile = name.zip, files = Sys.glob(name.glob))
          req(file.copy(name.zip, file))
          
          if (length(Sys.glob(name.glob)) > 0) file.remove(Sys.glob(name.glob))
          
          incProgress(0.5)
        })
      }  
    )
    
    ####### put things into reactive uis ----------
    
    output$treecanopy_box <- renderUI({
      req(TEST() != "")
      
      # shinydashboard::box(
      #   title = ("Tree canopy"),
      #   width = 12, collapsed = shinybrowser::get_device() == "Mobile",
      #   status = "danger", solidHeader = F, collapsible = TRUE,
        tagList(
        (tree_text()),
        fluidRow(
          align = "center",
          if(shinybrowser::get_device() == "Mobile") {
            renderPlot(report_tree_plot())
          } else {imageOutput(ns("tree_plot"), height = "100%", width = "100%")}
        ))
    })
    
    output$priority_box <- renderUI({
      req(TEST() != "")
      
      # shinydashboard::box(
      #   title = "Prioritization",
      #   width = 12, collapsed = shinybrowser::get_device() == "Mobile",
      #   status = "danger", solidHeader = F, collapsible = TRUE,
      tagList(
        rank_text(),
        if((map_selections$theme2[1] == "Custom" | (!is.na(map_selections$theme2[2]) & map_selections$theme2[2] == "Custom")) & nrow(map_selections$allInputs) == 0) {
          HTML("<p style='color:red;'> Error: please select at least one custom variable from the dropdown menus.</p>")
        }else{
          fluidRow(
            align = "center",
            if(shinybrowser::get_device() == "Mobile") {
              renderPlot(report_rank_plot())
            } else {
              imageOutput(ns("rank_plot"), height = "100%", width = "100%") }
          )
        },
        br(),
        #prevent error if user hasn't chosen at least 1 custom variable
        if(map_selections$theme2[1] == "Custom" & nrow(map_selections$allInputs) == 0) {
          HTML("<p style='color:red;'> Error: please select at least one custom variable from the dropdown menus.</p>")
        }else{
          tableOutput(ns("priority_table"))
        }
        )
    })
    
    output$disparity_box <- renderUI({
      req(TEST() != "")
      
      # shinydashboard::box(
      #   title = "Race & income disparities",
      #   width = 12, collapsed = shinybrowser::get_device() == "Mobile",
      #   status = "danger", solidHeader = F, collapsible = TRUE,
      tagList(
        equity_text(),
        fluidRow(
          align = "center",
          if(shinybrowser::get_device() == "Mobile") {
            renderPlot(report_equity_plot())
          } else {
            imageOutput(ns("equity_plot"), height = "100%", width = "100%")}
        )
      )
    })
    
    output$temp_box <- renderUI({
      req(TEST() != "")
      
      # shinydashboard::box(
      tagList(
        title = "Temperature",
        width = 12, collapsed = shinybrowser::get_device() == "Mobile",
        status = "danger", solidHeader = F, collapsible = TRUE,
        heat_text(),
        fluidRow(
          align = "center",
          imageOutput(ns("temp_plot"), height = "100%", width = "100%")
        )
      )
    })
    
    
    output$download_box <- renderUI({
      req(TEST() != "")
      
      # shinydashboard::box(
        # title = "Download data",
        # width = 12, collapsed = shinybrowser::get_device() == "Mobile",
        # status = "danger", solidHeader = F, collapsible = TRUE,
      tagList(
        HTML("<section class='d-none d-lg-block'>
             Use the buttons below to download a version of this report which can be printed or shared. 
             The raw data may also be downloaded as an excel or shapefile. Please be patient, as your file may take a minute to begin downloading.<br></section>"),# uiOutput(ns("download_para")),
        HTML("<section class='d-block d-lg-none'>
             Download a complete version of this report. Please be patient, as your file may take a minute to begin downloading.
             Use a desktop computer to download raw data or shapefiles.<br></section>"),# uiOutput(ns("download_para")),
        br(),
        fluidRow(
          column(width = 4, downloadButton(ns("dl_report"), label = "Text report")), #uiOutput(ns("get_the_report"))),
          column(class='d-none d-lg-block', width = 4, downloadButton(ns("dl_data"), label = "Raw data")), #uiOutput(ns("get_the_data"))),
          column(class='d-none d-lg-block', width = 4, downloadButton(ns("shapefile_dl"), label = "Shapefile")) #uiOutput(ns("get_shape_data")))
        )
      )
    })
  })
}

## To be copied in the UI
# mod_report_ui("report_ui_1")

## To be copied in the server
# mod_report_server("report_ui_1")
