# Sample Data Generator and Exporter for Urban Data Insights
# This script can be used to generate and export sample data for testing

library(dplyr)
library(readr)
library(lubridate)

# Source the data processing module
source("modules/data_processing.R")

# Generate sample data
cat("Generating sample housing data...\n")
housing_data <- load_sample_data()

# Display summary
cat("\nData Summary:\n")
cat("- Total properties:", nrow(housing_data), "\n")
cat("- Date range:", as.character(range(housing_data$date)), "\n")
cat("- Price range: $", format(min(housing_data$price), big.mark = ","), 
    " - $", format(max(housing_data$price), big.mark = ","), "\n")
cat("- Neighborhoods:", length(unique(housing_data$neighborhood)), "\n")
cat("- Property types:", length(unique(housing_data$property_type)), "\n")

# Show first few rows
cat("\nFirst 5 records:\n")
print(housing_data %>% head(5) %>% select(neighborhood, property_type, price, sqft, date))

# Export to CSV (optional)
export_data <- function(data, filename = "sample_housing_data.csv") {
  write_csv(data, filename)
  cat("\nData exported to:", filename, "\n")
  cat("File size:", file.size(filename), "bytes\n")
}

# Uncomment to export data
# export_data(housing_data)

# Generate summary statistics by neighborhood
neighborhood_summary <- housing_data %>%
  group_by(neighborhood) %>%
  summarise(
    properties = n(),
    avg_price = round(mean(price)),
    median_price = round(median(price)),
    avg_sqft = round(mean(sqft)),
    price_per_sqft = round(mean(price_per_sqft), 2),
    .groups = 'drop'
  ) %>%
  arrange(desc(avg_price))

cat("\nNeighborhood Summary:\n")
print(neighborhood_summary)

# Generate summary statistics by property type
property_summary <- housing_data %>%
  group_by(property_type) %>%
  summarise(
    properties = n(),
    avg_price = round(mean(price)),
    median_price = round(median(price)),
    avg_sqft = round(mean(sqft)),
    price_per_sqft = round(mean(price_per_sqft), 2),
    .groups = 'drop'
  ) %>%
  arrange(desc(avg_price))

cat("\nProperty Type Summary:\n")
print(property_summary)

# Generate time series summary
yearly_summary <- housing_data %>%
  group_by(year) %>%
  summarise(
    sales = n(),
    avg_price = round(mean(price)),
    total_volume = round(sum(price) / 1000000, 1),  # in millions
    .groups = 'drop'
  ) %>%
  arrange(year)

cat("\nYearly Sales Summary:\n")
print(yearly_summary)

cat("\nSample data generation complete!\n")
cat("You can now run the Shiny application with: source('app.R') or shiny::runApp()\n")
