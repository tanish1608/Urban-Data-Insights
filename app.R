# Urban Data Insights - R-Based Analysis Tool
# Main Shiny Application

# Load required libraries
library(shiny)
library(shinydashboard)
library(DT)
library(ggplot2)
library(dplyr)
library(leaflet)
library(plotly)
library(readr)
library(lubridate)

# Source additional modules
source("modules/data_processing.R")
source("modules/visualization.R")
source("modules/analysis.R")

# Load sample data
housing_data <- load_sample_data()

# Define UI
ui <- dashboardPage(
  dashboardHeader(title = "Urban Data Insights"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Housing Trends", tabName = "housing", icon = icon("home")),
      menuItem("Neighborhood Analysis", tabName = "neighborhoods", icon = icon("map")),
      menuItem("Interactive Map", tabName = "map", icon = icon("globe")),
      menuItem("Data Explorer", tabName = "data", icon = icon("table")),
      menuItem("About", tabName = "about", icon = icon("info"))
    )
  ),
  
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
    ),
    
    tabItems(
      # Dashboard Tab
      tabItem(tabName = "dashboard",
        fluidRow(
          valueBoxOutput("avg_price"),
          valueBoxOutput("total_properties"),
          valueBoxOutput("avg_sqft")
        ),
        fluidRow(
          box(
            title = "Housing Price Trends", status = "primary", solidHeader = TRUE,
            width = 8, height = 400,
            plotlyOutput("price_trend_plot")
          ),
          box(
            title = "Property Type Distribution", status = "info", solidHeader = TRUE,
            width = 4, height = 400,
            plotlyOutput("property_type_plot")
          )
        ),
        fluidRow(
          box(
            title = "Neighborhood Price Distribution", status = "success", solidHeader = TRUE,
            width = 12, height = 400,
            plotlyOutput("neighborhood_price_plot")
          )
        )
      ),
      
      # Housing Trends Tab
      tabItem(tabName = "housing",
        fluidRow(
          box(
            title = "Filter Options", status = "warning", solidHeader = TRUE,
            width = 3,
            selectInput("property_type", "Property Type:",
                       choices = c("All", unique(housing_data$property_type)),
                       selected = "All"),
            sliderInput("price_range", "Price Range:",
                       min = min(housing_data$price, na.rm = TRUE),
                       max = max(housing_data$price, na.rm = TRUE),
                       value = c(min(housing_data$price, na.rm = TRUE),
                               max(housing_data$price, na.rm = TRUE)),
                       step = 10000),
            dateRangeInput("date_range", "Date Range:",
                          start = min(housing_data$date, na.rm = TRUE),
                          end = max(housing_data$date, na.rm = TRUE))
          ),
          box(
            title = "Housing Price Analysis", status = "primary", solidHeader = TRUE,
            width = 9,
            tabsetPanel(
              tabPanel("Time Series", plotlyOutput("housing_timeseries", height = "350px")),
              tabPanel("Price vs. Size", plotlyOutput("price_size_plot", height = "350px")),
              tabPanel("Seasonal Trends", plotlyOutput("seasonal_plot", height = "350px"))
            )
          )
        )
      ),
      
      # Neighborhood Analysis Tab
      tabItem(tabName = "neighborhoods",
        fluidRow(
          box(
            title = "Neighborhood Selector", status = "warning", solidHeader = TRUE,
            width = 3,
            selectizeInput("selected_neighborhoods", "Select Neighborhoods:",
                          choices = unique(housing_data$neighborhood),
                          multiple = TRUE,
                          selected = unique(housing_data$neighborhood)[1:3]),
            radioButtons("analysis_type", "Analysis Type:",
                        choices = list("Price Comparison" = "price",
                                     "Size Analysis" = "size",
                                     "Market Activity" = "activity"),
                        selected = "price")
          ),
          box(
            title = "Neighborhood Comparison", status = "primary", solidHeader = TRUE,
            width = 9,
            plotlyOutput("neighborhood_analysis", height = "400px")
          )
        ),
        fluidRow(
          box(
            title = "Neighborhood Statistics", status = "info", solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("neighborhood_stats")
          )
        )
      ),
      
      # Interactive Map Tab
      tabItem(tabName = "map",
        fluidRow(
          box(
            title = "Map Controls", status = "warning", solidHeader = TRUE,
            width = 3,
            selectInput("map_metric", "Display Metric:",
                       choices = list("Average Price" = "avg_price",
                                    "Number of Properties" = "count",
                                    "Price per Sq Ft" = "price_per_sqft"),
                       selected = "avg_price"),
            checkboxInput("show_clusters", "Show Clusters", value = TRUE),
            sliderInput("map_price_filter", "Price Filter:",
                       min = min(housing_data$price, na.rm = TRUE),
                       max = max(housing_data$price, na.rm = TRUE),
                       value = c(min(housing_data$price, na.rm = TRUE),
                               max(housing_data$price, na.rm = TRUE)),
                       step = 10000)
          ),
          box(
            title = "Interactive Housing Map", status = "primary", solidHeader = TRUE,
            width = 9, height = 600,
            leafletOutput("housing_map", height = "550px")
          )
        )
      ),
      
      # Data Explorer Tab
      tabItem(tabName = "data",
        fluidRow(
          box(
            title = "Data Table Controls", status = "warning", solidHeader = TRUE,
            width = 12,
            fluidRow(
              column(3, downloadButton("download_data", "Download Data", class = "btn-primary")),
              column(3, numericInput("sample_size", "Sample Size:", value = 1000, min = 100, max = nrow(housing_data))),
              column(6, searchInput("search_box", "Search Data:", placeholder = "Enter search term..."))
            )
          )
        ),
        fluidRow(
          box(
            title = "Housing Data Explorer", status = "primary", solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("data_table")
          )
        )
      ),
      
      # About Tab
      tabItem(tabName = "about",
        fluidRow(
          box(
            title = "About Urban Data Insights", status = "info", solidHeader = TRUE,
            width = 12,
            h3("Urban Data Insights - R-Based Analysis Tool"),
            p("This application provides comprehensive analysis and visualization of urban housing data, 
              enabling users to explore housing trends across different neighborhoods."),
            
            h4("Key Features:"),
            tags$ul(
              tags$li("Interactive data visualization using ggplot2 and plotly"),
              tags$li("Data manipulation and analysis with dplyr"),
              tags$li("Interactive maps with leaflet"),
              tags$li("Responsive Shiny dashboard interface"),
              tags$li("Real-time filtering and analysis capabilities")
            ),
            
            h4("Technologies Used:"),
            tags$ul(
              tags$li("R - Core programming language"),
              tags$li("Shiny - Web application framework"),
              tags$li("ggplot2 - Data visualization"),
              tags$li("dplyr - Data manipulation"),
              tags$li("leaflet - Interactive mapping"),
              tags$li("plotly - Interactive plots"),
              tags$li("DT - Interactive data tables")
            ),
            
            h4("Data Sources:"),
            p("The application uses synthetic housing data for demonstration purposes. 
              In a production environment, this would connect to real estate APIs or databases."),
            
            hr(),
            p(em("Developed as part of Urban Data Analysis project"), align = "center")
          )
        )
      )
    )
  )
)

# Define Server
server <- function(input, output, session) {
  
  # Reactive data filtering
  filtered_data <- reactive({
    data <- housing_data
    
    # Filter by property type
    if(exists("input") && !is.null(input$property_type) && input$property_type != "All") {
      data <- data %>% filter(property_type == input$property_type)
    }
    
    # Filter by price range
    if(exists("input") && !is.null(input$price_range)) {
      data <- data %>% filter(price >= input$price_range[1] & price <= input$price_range[2])
    }
    
    # Filter by date range
    if(exists("input") && !is.null(input$date_range)) {
      data <- data %>% filter(date >= input$date_range[1] & date <= input$date_range[2])
    }
    
    return(data)
  })
  
  # Dashboard Value Boxes
  output$avg_price <- renderValueBox({
    avg_price <- filtered_data() %>%
      summarise(avg = mean(price, na.rm = TRUE)) %>%
      pull(avg)
    
    valueBox(
      value = paste0("$", format(round(avg_price), big.mark = ",")),
      subtitle = "Average Price",
      icon = icon("dollar-sign"),
      color = "green"
    )
  })
  
  output$total_properties <- renderValueBox({
    count <- nrow(filtered_data())
    
    valueBox(
      value = format(count, big.mark = ","),
      subtitle = "Total Properties",
      icon = icon("home"),
      color = "blue"
    )
  })
  
  output$avg_sqft <- renderValueBox({
    avg_sqft <- filtered_data() %>%
      summarise(avg = mean(sqft, na.rm = TRUE)) %>%
      pull(avg)
    
    valueBox(
      value = format(round(avg_sqft), big.mark = ","),
      subtitle = "Average Sq Ft",
      icon = icon("ruler"),
      color = "yellow"
    )
  })
  
  # Dashboard Plots
  output$price_trend_plot <- renderPlotly({
    create_price_trend_plot(filtered_data())
  })
  
  output$property_type_plot <- renderPlotly({
    create_property_type_plot(filtered_data())
  })
  
  output$neighborhood_price_plot <- renderPlotly({
    create_neighborhood_price_plot(filtered_data())
  })
  
  # Housing Trends Plots
  output$housing_timeseries <- renderPlotly({
    create_timeseries_plot(filtered_data())
  })
  
  output$price_size_plot <- renderPlotly({
    create_price_size_plot(filtered_data())
  })
  
  output$seasonal_plot <- renderPlotly({
    create_seasonal_plot(filtered_data())
  })
  
  # Neighborhood Analysis
  output$neighborhood_analysis <- renderPlotly({
    if(exists("input") && !is.null(input$selected_neighborhoods) && !is.null(input$analysis_type)) {
      create_neighborhood_analysis_plot(housing_data, input$selected_neighborhoods, input$analysis_type)
    }
  })
  
  output$neighborhood_stats <- DT::renderDataTable({
    if(exists("input") && !is.null(input$selected_neighborhoods)) {
      create_neighborhood_stats_table(housing_data, input$selected_neighborhoods)
    }
  }, options = list(scrollX = TRUE, pageLength = 10))
  
  # Interactive Map
  output$housing_map <- renderLeaflet({
    if(exists("input") && !is.null(input$map_metric)) {
      map_data <- housing_data %>%
        filter(price >= input$map_price_filter[1] & price <= input$map_price_filter[2])
      
      create_housing_map(map_data, input$map_metric, input$show_clusters)
    } else {
      create_housing_map(housing_data, "avg_price", TRUE)
    }
  })
  
  # Data Explorer
  output$data_table <- DT::renderDataTable({
    sample_data <- housing_data
    
    if(exists("input") && !is.null(input$sample_size)) {
      if(input$sample_size < nrow(housing_data)) {
        sample_data <- housing_data %>% slice_sample(n = input$sample_size)
      }
    }
    
    sample_data
  }, options = list(scrollX = TRUE, pageLength = 25, searching = TRUE))
  
  # Download handler
  output$download_data <- downloadHandler(
    filename = function() {
      paste0("housing_data_", Sys.Date(), ".csv")
    },
    content = function(file) {
      write_csv(filtered_data(), file)
    }
  )
}

# Run the application
shinyApp(ui = ui, server = server)
