#!/usr/bin/env Rscript

# Urban Data Insights - Launch Script
# This script checks dependencies and launches the Shiny application

cat("=== Urban Data Insights - R-Based Analysis Tool ===\n")
cat("Initializing application...\n\n")

# Check if running interactively
if(interactive()) {
  cat("Running in interactive mode\n")
} else {
  cat("Running in script mode\n")
}

# Function to check if package is installed
is_package_installed <- function(package_name) {
  return(package_name %in% installed.packages()[,"Package"])
}

# List of required packages
required_packages <- c(
  "shiny", "shinydashboard", "dplyr", "readr", "lubridate",
  "ggplot2", "plotly", "leaflet", "viridis", "DT", "scales"
)

# Check for missing packages
missing_packages <- required_packages[!sapply(required_packages, is_package_installed)]

if(length(missing_packages) > 0) {
  cat("Missing packages detected:", paste(missing_packages, collapse = ", "), "\n")
  cat("Installing missing packages...\n")
  
  tryCatch({
    install.packages(missing_packages, dependencies = TRUE, repos = "https://cran.rstudio.com/")
    cat("Package installation completed successfully!\n")
  }, error = function(e) {
    cat("Error installing packages:", e$message, "\n")
    cat("Please install packages manually using:\n")
    cat("install.packages(c(", paste0('"', missing_packages, '"', collapse = ", "), "))\n")
    quit(status = 1)
  })
} else {
  cat("All required packages are installed ✓\n")
}

# Load configuration
cat("Loading configuration...\n")
tryCatch({
  source("config.R")
  cat("Configuration loaded ✓\n")
}, error = function(e) {
  cat("Warning: Could not load config.R -", e$message, "\n")
})

# Check for required files
required_files <- c(
  "app.R",
  "modules/data_processing.R",
  "modules/visualization.R", 
  "modules/analysis.R"
)

missing_files <- required_files[!file.exists(required_files)]
if(length(missing_files) > 0) {
  cat("Error: Missing required files:\n")
  cat(paste("-", missing_files, collapse = "\n"), "\n")
  quit(status = 1)
}

cat("All required files found ✓\n")

# Set up environment
cat("Setting up environment...\n")

# Create logs directory if it doesn't exist
if(!dir.exists("logs")) {
  dir.create("logs")
  cat("Created logs directory\n")
}

# Load the application
cat("Loading Shiny application...\n")

tryCatch({
  # Source the main application
  source("app.R")
  cat("Application loaded successfully ✓\n")
}, error = function(e) {
  cat("Error loading application:", e$message, "\n")
  quit(status = 1)
})

# Launch the application
cat("\n=== Starting Urban Data Insights ===\n")
cat("Dashboard will open in your default browser...\n")
cat("Press Ctrl+C to stop the application\n")
cat("=====================================\n\n")

# Set launch options
options(shiny.launch.browser = TRUE)

# Start the app
tryCatch({
  shiny::runApp(
    host = "0.0.0.0",
    port = 3838,
    launch.browser = TRUE
  )
}, error = function(e) {
  cat("Error starting application:", e$message, "\n")
  
  # Try alternative port if 3838 is in use
  cat("Trying alternative port...\n")
  tryCatch({
    shiny::runApp(
      host = "0.0.0.0", 
      port = 8080,
      launch.browser = TRUE
    )
  }, error = function(e2) {
    cat("Error starting on alternative port:", e2$message, "\n")
    cat("Please try running manually with: shiny::runApp()\n")
    quit(status = 1)
  })
})
