#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  
  navbar_js <- "@media (max-width: 991px) {
    .navbar-header {
        float: none;
    }
    .navbar-left,.navbar-right {
        float: none !important;
    }
    .navbar-toggle {
        display: block;
    }
    .navbar-collapse {
        border-top: 1px solid transparent;
        box-shadow: inset 0 1px 0 rgba(255,255,255,0.1);
    }
    .navbar-fixed-top {
        top: 0;
        border-width: 0 0 1px;
    }
    .navbar-collapse.collapse {
        display: none!important;
    }
    .navbar-nav {
        float: none!important;
        margin-top: 7.5px;
    }
    .navbar-nav>li {
        float: none;
    }
    .navbar-nav>li>a {
/*        padding-top: 10px;*/
  /*      padding-bottom: 10px;*/
    }
    .collapse.in{
        display:block !important;
    }


.navbar-brand{
padding:0 0!important
}
.navbar-default{
font-size: 12pt!important;
height: 65px !important
}
.nav>li>a{
padding: 1px 1px
}
.navbar-fixed-bottom .navbar-collapse, .navbar-fixed-top .navbar-collapse {
max-height: 500px;
}
.body{
padding-top:0px
}

.nav>li>a {
    position: relative;
    display: inline!important;
    padding: 0px 15px;
}
navbar-default .navbar-nav>li>a {
    color: var(--council-blue);
    height: 10px!important;
    padding-top: 5px!important;
    padding-bottom: 5px!important;
}

.navbar-default .navbar-nav>.active>a, .navbar-default .navbar-nav>.active>a:focus, .navbar-default .navbar-nav>.active>a:hover {
    color: var(--council-blue);
    background-color: #d6d6d6;
  /*  height: 45px;*/
    padding: 5px !important;
}

.navbar-default .navbar-nav>li>a:focus, .navbar-default .navbar-nav>li>a:hover {
    color: var(--council-blue);
     background-color: #d6d6d6; 
    padding: 5px;
}
a {
    padding: 0px!important;
}



@media (max-width: 454px) {
.navbar-brand{
display:none!important
}
}"


tagList(
  tags$html(lang = "en"),
  tags$head(tags$style(HTML(navbar_js))),
  # shiny::includeHTML("inst/app/www/google-analytics.html"),
  # Leave this function for adding external resources
  golem_add_external_resources(),
  shinydisconnect::disconnectMessage(
    text = HTML("Your session timed out. Please refresh the application."),
    refresh = "Refresh now",
    top = "center"
  ),
  
  
  # List the first level UI elements here
  # tags$head(img(src = "www/main-logo.png", height = "60px", alt = "MetCouncil logo")), #,'.navbar-brand{display:none;}')),
  navbarPage(
    title = div(style = "align:center",
                a(href = "https://daneclimateaction.org/Initiatives/Tree-Canopy", target = "_blank", 
                  img(src = "www/TreeCanopyCollaborativeLogo-crop.jpg", alt = "Tree Canopy Collaborative logo",
                      # style="margin-top: -30px; padding-left:0px",
                      height = 60))
    ),
    windowTitle = "Growing Shade Tool",
    id = "nav",
    collapsible = TRUE,
    position = "fixed-top",
    header = tags$style(
      ".navbar-right {
                       float: right !important;
                       }",
      "body {padding-top: 75px;}"
    ),
    tabPanel(
      "HOME",
      # id = "B",
      # br(), # br(),
      #fluidRow((mod_storymap_ui("storymap_ui_1")))
      mod_home_ui("home_ui_1")
    ),
    tabPanel(
      "Mapping tool",
      # tags$footer(
      #   class = 'd-none d-lg-block',#desktop
      #   HTML('Source: <a href = "https://daneclimateaction.org/Initiatives/Tree-Canopy" target = "_blank">Growing Shade Project</a>. Last updated on 2023-09-01. '),
      #   align = "right",
      #   style = "
      #         position:absolute;
      #         bottom:1em;
      #         right:0;
      #         width:50%;
      #         height:10px;   /* Height of the footer */
      #         color: black;
      #         padding: 0px;
      #         background-color: transparent;
      #         z-index: 1000;"
      # ),
      # id = "demo",
      div(
        style = "width:100% !important;
                    margin-left:0  !important; margin-top:30px  !important;
                    max-width: 4000px !important; min-width:100% !important",
        sidebarLayout(
          sidebarPanel(
            # waiter::useWaitress(),
            width = 6,
            style = "height: 90vh; overflow-y: auto;",
            
            # width = 2,
            HTML("<h1><section style='font-size: 22pt;'>Welcome to the Growing Shade mapping tool</h1></section><br>"),
            HTML('<p>Click below to toggle the tutorial text on and off.</p><br>'),
            HTML('<button id="tutorial">Tutorial</button><br><br>'),
            HTML('<div class="help">
            <p>
            You can use this mapping tool to prioritize where to preserve & expand canopy in Dane County,
            as well as creating data-driven reports. There are five steps to using the Growing Shade mapping tool: 
            <br>
            <br>
            1. Choose your <b>geographical area</b> of interest
            <br>
            <br>
            2. Choose your prioritization <b>theme</b>
            <br>
            <br>
            3. Explore priority areas using an <b>interactive map</b> of Dane County
            <br>
            <br>
            4. Explore the <b>report</b> comparing your area of interest to the county as a whole
            <br>
            <br>
            5. <b>Download</b> the report
            </p>
            </div>'),
            tags$script(
              '$(document).ready(function(){
                $("div.help").hide();
              	var tutorial = false;
                  $("button#tutorial").click(function(){
  	                if (tutorial == false) {
  	                  $("div.help").toggle();
  	                  $("button#tutorial").css({"background-color": "#3e8e41",
                                                "box-shadow": "0 5px #666",
                                                "transform": "translateY(4px)"});
                      tutorial = true;
                  } else if (tutorial == true) {
   	                  $("div.help").toggle();
   	                  $("button#tutorial").css({"background-color": "#57b57d",
                                                "box-shadow": "0 9px #999",
                                                "transform": "translateY(-4px)"});
                      tutorial = false;
                 }
                });
              });'
              ),
            hr(style = "margin-top: 2px; margin-bottom: 2px "),
            mod_geo_selection_ui("geo_selection_ui_1"),
            # HTML('<hr style="border-top: black;border-top-style: solid;border-right-width: 5px;">'),
            hr(style = "margin-top: 2px; margin-bottom: 2px "),
            
            # br(),
            mod_map_selections_ui("map_selections_ui_1"),
            br(class="d-none d-lg-block"),
            HTML("<div class='help'>
                 <p>
                 <b>4. Explore the report comparing your area of interest to the county as a whole</b>
                 <br><br>
                 Scroll down to read a detailed report of your results. There are three parts to the report.
                 <br><br>
                 <b>Prioritization:</b>
                 This section will change depending on your selected geography.
                 <br>
                 -If you have selected a block group, it shows which themes that block group is a priority for.
                 It also includes the value and priority score for each variable included in the theme.
                 <br>
                 -If you have selected a city/town or neighborhood, it shows how many block groups are a priority
                 for your selected theme(s).
                 It also includes average values for each variable included in the theme,
                 both for your selected area and the county as a whole.
                 <br><br>
                 <b>Tree canopy</b>
                 This section describes how the % tree canopy in your selected area compares to the county as a whole.
                 This will change depending on your selected geography; 
                 a block group is compared to all county block groups, 
                 a city/town is compared to all other city/towns,
                 and a neighborhood is compared to all other neighborhoods.
                 <br><br>
                 <b>Race and income disparities</b>
                 This section describes how the % tree canopy in your selected area relates to race and income.
                 <br><br>
                 Within the report, each section can be collapsed by clicking on the “minus” or “plus” symbol. 
                 This may be useful if you wish to compare a specific report selection across different geographies.
                 </p>
                 </div>"),
            mod_report_new_ui("report_new_ui_1"),
          ),
          mainPanel(
            width = 6,
            # div(class="outer3",
            fluidRow(div(
              style = "top:25em !important;", # style = 'width:100% !important; top:25em !important; ',
              HTML("<div class='help'>
                 <p>
                <b>3. Explore priority areas using an interactive map of Dane County</b>
                <br><br>
                <b>Understanding Symbols</b>
                <br>
                -Colored block groups are priority areas determined by your selected theme(s).
                <br>
                -The blue border shows your selected geographical area.
                <br>
                -Dark grey lines show the borders of all block groups.
                <br>
                -Black lines show all borders of the geography you have selected (either cities & townships or neighborhoods) 
                <br><br>
                <b>Interacting with the Map</b>
                <br>
                 -Use the “plus” and “minus” buttons or scroll to zoom in and out.
                 <br>
                 -Toggle map layers “on” or “off” with the button at the bottom of the map.
                 <br>
                 -Click and drag to move the map around.
                 <br>
                 -Hover over a block group to see its <b>total score</b>: how many variables (in the chosen theme) it is a priority area for.
                 Click on a block group to see more detailed information.
                 Note that the information shown when you hover or click on an area is for the <b>block group</b> your cursor is in.
                 This does not change regardless of the geography level you have selected. To explore information about scores for a city, town, or neighborhood, see step 4.
                 <br>
                 -To take a picture of the map, push the 'full screen' button and taking a screenshot.
                </p>
                 </div>"),
              mod_map_overview_ui("map_overview_ui_1")
            ))
          )
        )
      )
    ),
    tabPanel(
      "Resources",
      mod_other_resources_ui("other_resources_ui_1")
    ),
    tabPanel(
      "FAQ",
      mod_faq_ui("faq_ui_1")
    ),
    tabPanel(
      "methods",
      mod_methods_ui("methods_ui_1")
    ),
    tabPanel(
      "About Us",
      # id = "B",
      #br(), br(),
      mod_about_ui("about_ui_1"),
      HTML('<h2><b>Our Work</b></h2>'),
      br(),
      fluidRow((mod_storymap_ui("storymap_ui_1")))
    ),
  )
)
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www", app_sys("app/www")
  )
  
  tags$head(
    shiny::includeHTML("inst/app/www/google-analytics.html"),
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "Growing Shade Tool"
    ),
    includeScript(path = "inst/app/www/checkbox.js")
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
