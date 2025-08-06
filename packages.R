# Urban Data Insights - R Package Dependencies
# This file lists all required packages for the application

# Core Shiny packages
library(shiny)          # Web application framework
library(shinydashboard) # Dashboard layout and components

# Data manipulation and analysis
library(dplyr)          # Data manipulation
library(readr)          # Reading CSV and other data files
library(lubridate)      # Date/time manipulation

# Visualization packages
library(ggplot2)        # Grammar of graphics plotting
library(plotly)         # Interactive plots
library(leaflet)        # Interactive maps
library(viridis)        # Color palettes

# Table and UI components
library(DT)             # Interactive data tables
library(scales)         # Scale functions for visualization

# Additional utility packages (install if needed)
# install.packages(c("shiny", "shinydashboard", "dplyr", "readr", 
#                   "lubridate", "ggplot2", "plotly", "leaflet", 
#                   "viridis", "DT", "scales"))

# Function to check and install missing packages
check_and_install_packages <- function() {
  required_packages <- c(
    "shiny", "shinydashboard", "dplyr", "readr", "lubridate",
    "ggplot2", "plotly", "leaflet", "viridis", "DT", "scales"
  )
  
  missing_packages <- required_packages[!required_packages %in% installed.packages()[,"Package"]]
  
  if(length(missing_packages) > 0) {
    cat("Installing missing packages:", paste(missing_packages, collapse = ", "), "\n")
    install.packages(missing_packages, dependencies = TRUE)
  } else {
    cat("All required packages are already installed.\n")
  }
}

# Uncomment the line below to check and install packages
# check_and_install_packages()
