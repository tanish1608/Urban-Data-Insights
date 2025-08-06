# Data Processing Module for Urban Data Insights
# This module handles data loading, cleaning, and preprocessing

library(dplyr)
library(readr)
library(lubridate)

# Function to generate sample housing data
load_sample_data <- function() {
  set.seed(42)  # For reproducible data
  
  # Define neighborhoods
  neighborhoods <- c("Downtown", "Riverside", "Hillcrest", "Oakwood", "Pine Valley", 
                    "Sunset District", "Marina Bay", "Tech Quarter", "Historic District", 
                    "University Area", "Lakeside", "Industrial Zone")
  
  # Define property types
  property_types <- c("Single Family", "Condo", "Townhouse", "Apartment", "Duplex")
  
  # Generate sample data
  n_properties <- 5000
  
  housing_data <- data.frame(
    id = 1:n_properties,
    neighborhood = sample(neighborhoods, n_properties, replace = TRUE, 
                         prob = c(0.15, 0.12, 0.10, 0.08, 0.08, 0.08, 0.07, 0.07, 0.06, 0.06, 0.06, 0.07)),
    property_type = sample(property_types, n_properties, replace = TRUE,
                          prob = c(0.35, 0.25, 0.20, 0.12, 0.08)),
    date = sample(seq(as.Date("2020-01-01"), as.Date("2024-12-31"), by = "day"), 
                  n_properties, replace = TRUE),
    price = round(rnorm(n_properties, mean = 450000, sd = 150000)),
    sqft = round(rnorm(n_properties, mean = 1800, sd = 600)),
    bedrooms = sample(1:6, n_properties, replace = TRUE, prob = c(0.05, 0.20, 0.35, 0.25, 0.10, 0.05)),
    bathrooms = sample(c(1, 1.5, 2, 2.5, 3, 3.5, 4), n_properties, replace = TRUE,
                      prob = c(0.05, 0.10, 0.30, 0.20, 0.20, 0.10, 0.05)),
    age = sample(1:100, n_properties, replace = TRUE),
    parking = sample(0:3, n_properties, replace = TRUE, prob = c(0.10, 0.30, 0.45, 0.15)),
    latitude = runif(n_properties, min = 37.7, max = 37.8),
    longitude = runif(n_properties, min = -122.5, max = -122.3)
  )
  
  # Adjust prices based on neighborhood (some neighborhoods are more expensive)
  neighborhood_multipliers <- c(
    "Downtown" = 1.3,
    "Tech Quarter" = 1.5,
    "Marina Bay" = 1.4,
    "Hillcrest" = 1.2,
    "Riverside" = 1.1,
    "Sunset District" = 1.0,
    "University Area" = 0.9,
    "Oakwood" = 0.95,
    "Pine Valley" = 0.85,
    "Historic District" = 1.1,
    "Lakeside" = 0.9,
    "Industrial Zone" = 0.7
  )
  
  # Apply neighborhood multipliers
  housing_data <- housing_data %>%
    mutate(
      price = round(price * neighborhood_multipliers[neighborhood]),
      price = pmax(price, 100000),  # Minimum price
      price_per_sqft = round(price / sqft, 2),
      year = year(date),
      month = month(date),
      quarter = quarter(date),
      season = case_when(
        month %in% c(12, 1, 2) ~ "Winter",
        month %in% c(3, 4, 5) ~ "Spring",
        month %in% c(6, 7, 8) ~ "Summer",
        month %in% c(9, 10, 11) ~ "Fall"
      )
    )
  
  # Add some correlation between size and price
  housing_data <- housing_data %>%
    mutate(
      price = price + (sqft - mean(sqft)) * 50 + rnorm(n(), 0, 10000),
      price = round(pmax(price, 100000))  # Ensure minimum price
    )
  
  return(housing_data)
}

# Function to clean and validate housing data
clean_housing_data <- function(data) {
  cleaned_data <- data %>%
    # Remove rows with missing critical data
    filter(!is.na(price), !is.na(sqft), !is.na(neighborhood)) %>%
    # Remove outliers (prices beyond reasonable ranges)
    filter(price >= 50000 & price <= 2000000) %>%
    filter(sqft >= 200 & sqft <= 10000) %>%
    # Ensure data types are correct
    mutate(
      date = as.Date(date),
      price = as.numeric(price),
      sqft = as.numeric(sqft),
      bedrooms = as.integer(bedrooms),
      bathrooms = as.numeric(bathrooms),
      neighborhood = as.factor(neighborhood),
      property_type = as.factor(property_type)
    ) %>%
    # Calculate additional metrics
    mutate(
      price_per_sqft = round(price / sqft, 2),
      year = year(date),
      month = month(date),
      quarter = quarter(date),
      age_category = case_when(
        age <= 5 ~ "New (0-5 years)",
        age <= 15 ~ "Modern (6-15 years)",
        age <= 30 ~ "Established (16-30 years)",
        age <= 50 ~ "Mature (31-50 years)",
        TRUE ~ "Historic (50+ years)"
      )
    )
  
  return(cleaned_data)
}

# Function to aggregate data by neighborhood
aggregate_by_neighborhood <- function(data) {
  neighborhood_summary <- data %>%
    group_by(neighborhood) %>%
    summarise(
      total_properties = n(),
      avg_price = mean(price, na.rm = TRUE),
      median_price = median(price, na.rm = TRUE),
      min_price = min(price, na.rm = TRUE),
      max_price = max(price, na.rm = TRUE),
      avg_sqft = mean(sqft, na.rm = TRUE),
      avg_price_per_sqft = mean(price_per_sqft, na.rm = TRUE),
      avg_bedrooms = mean(bedrooms, na.rm = TRUE),
      avg_bathrooms = mean(bathrooms, na.rm = TRUE),
      avg_age = mean(age, na.rm = TRUE),
      .groups = 'drop'
    ) %>%
    arrange(desc(avg_price))
  
  return(neighborhood_summary)
}

# Function to aggregate data by time period
aggregate_by_time <- function(data, period = "month") {
  if(period == "month") {
    time_summary <- data %>%
      mutate(time_period = floor_date(date, "month")) %>%
      group_by(time_period) %>%
      summarise(
        total_sales = n(),
        avg_price = mean(price, na.rm = TRUE),
        median_price = median(price, na.rm = TRUE),
        total_volume = sum(price, na.rm = TRUE),
        avg_sqft = mean(sqft, na.rm = TRUE),
        .groups = 'drop'
      )
  } else if(period == "quarter") {
    time_summary <- data %>%
      mutate(time_period = paste0(year(date), "-Q", quarter(date))) %>%
      group_by(time_period) %>%
      summarise(
        total_sales = n(),
        avg_price = mean(price, na.rm = TRUE),
        median_price = median(price, na.rm = TRUE),
        total_volume = sum(price, na.rm = TRUE),
        avg_sqft = mean(sqft, na.rm = TRUE),
        .groups = 'drop'
      )
  } else {  # year
    time_summary <- data %>%
      group_by(year = year(date)) %>%
      summarise(
        total_sales = n(),
        avg_price = mean(price, na.rm = TRUE),
        median_price = median(price, na.rm = TRUE),
        total_volume = sum(price, na.rm = TRUE),
        avg_sqft = mean(sqft, na.rm = TRUE),
        .groups = 'drop'
      )
  }
  
  return(time_summary)
}

# Function to calculate market statistics
calculate_market_stats <- function(data) {
  current_year <- max(data$year)
  previous_year <- current_year - 1
  
  current_data <- data %>% filter(year == current_year)
  previous_data <- data %>% filter(year == previous_year)
  
  stats <- list(
    current_year = current_year,
    total_properties_current = nrow(current_data),
    total_properties_previous = nrow(previous_data),
    avg_price_current = mean(current_data$price, na.rm = TRUE),
    avg_price_previous = mean(previous_data$price, na.rm = TRUE),
    median_price_current = median(current_data$price, na.rm = TRUE),
    median_price_previous = median(previous_data$price, na.rm = TRUE)
  )
  
  # Calculate year-over-year changes
  stats$yoy_volume_change <- ifelse(stats$total_properties_previous > 0,
                                   (stats$total_properties_current - stats$total_properties_previous) / stats$total_properties_previous * 100,
                                   0)
  
  stats$yoy_price_change <- ifelse(stats$avg_price_previous > 0,
                                  (stats$avg_price_current - stats$avg_price_previous) / stats$avg_price_previous * 100,
                                  0)
  
  return(stats)
}

# Function to filter data based on multiple criteria
filter_housing_data <- function(data, filters = list()) {
  filtered_data <- data
  
  if("neighborhoods" %in% names(filters) && !is.null(filters$neighborhoods)) {
    filtered_data <- filtered_data %>%
      filter(neighborhood %in% filters$neighborhoods)
  }
  
  if("property_types" %in% names(filters) && !is.null(filters$property_types)) {
    filtered_data <- filtered_data %>%
      filter(property_type %in% filters$property_types)
  }
  
  if("price_range" %in% names(filters) && !is.null(filters$price_range)) {
    filtered_data <- filtered_data %>%
      filter(price >= filters$price_range[1] & price <= filters$price_range[2])
  }
  
  if("date_range" %in% names(filters) && !is.null(filters$date_range)) {
    filtered_data <- filtered_data %>%
      filter(date >= filters$date_range[1] & date <= filters$date_range[2])
  }
  
  if("bedrooms" %in% names(filters) && !is.null(filters$bedrooms)) {
    filtered_data <- filtered_data %>%
      filter(bedrooms %in% filters$bedrooms)
  }
  
  if("sqft_range" %in% names(filters) && !is.null(filters$sqft_range)) {
    filtered_data <- filtered_data %>%
      filter(sqft >= filters$sqft_range[1] & sqft <= filters$sqft_range[2])
  }
  
  return(filtered_data)
}
