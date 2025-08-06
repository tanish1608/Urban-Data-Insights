# Analysis Module for Urban Data Insights
# This module contains statistical analysis functions and table generation

library(dplyr)
library(leaflet)
library(DT)
library(scales)

# Function to create neighborhood statistics table
create_neighborhood_stats_table <- function(data, selected_neighborhoods) {
  if(is.null(selected_neighborhoods) || length(selected_neighborhoods) == 0) {
    return(data.frame())
  }
  
  stats_table <- data %>%
    filter(neighborhood %in% selected_neighborhoods) %>%
    group_by(neighborhood) %>%
    summarise(
      `Total Properties` = n(),
      `Avg Price` = dollar(round(mean(price, na.rm = TRUE))),
      `Median Price` = dollar(round(median(price, na.rm = TRUE))),
      `Min Price` = dollar(round(min(price, na.rm = TRUE))),
      `Max Price` = dollar(round(max(price, na.rm = TRUE))),
      `Avg Sq Ft` = comma(round(mean(sqft, na.rm = TRUE))),
      `Price per Sq Ft` = dollar(round(mean(price_per_sqft, na.rm = TRUE), 2)),
      `Avg Bedrooms` = round(mean(bedrooms, na.rm = TRUE), 1),
      `Avg Bathrooms` = round(mean(bathrooms, na.rm = TRUE), 1),
      `Avg Age` = round(mean(age, na.rm = TRUE), 1),
      .groups = 'drop'
    ) %>%
    arrange(desc(parse_number(`Avg Price`)))
  
  return(stats_table)
}

# Function to create interactive housing map with leaflet
create_housing_map <- function(data, metric = "avg_price", show_clusters = TRUE) {
  # Aggregate data by neighborhood and calculate coordinates
  map_data <- data %>%
    group_by(neighborhood) %>%
    summarise(
      avg_price = mean(price, na.rm = TRUE),
      count = n(),
      price_per_sqft = mean(price_per_sqft, na.rm = TRUE),
      avg_lat = mean(latitude, na.rm = TRUE),
      avg_lng = mean(longitude, na.rm = TRUE),
      .groups = 'drop'
    )
  
  # Create base map
  m <- leaflet(map_data) %>%
    addTiles() %>%
    setView(lng = -122.4, lat = 37.75, zoom = 12)
  
  # Determine color palette and values based on metric
  if(metric == "avg_price") {
    values <- map_data$avg_price
    color_palette <- colorNumeric("YlOrRd", values)
    legend_title <- "Avg Price"
    popup_text <- paste0(
      "<strong>", map_data$neighborhood, "</strong><br/>",
      "Average Price: ", dollar(round(map_data$avg_price)), "<br/>",
      "Properties: ", comma(map_data$count), "<br/>",
      "Price per Sq Ft: ", dollar(round(map_data$price_per_sqft, 2))
    )
  } else if(metric == "count") {
    values <- map_data$count
    color_palette <- colorNumeric("Blues", values)
    legend_title <- "Property Count"
    popup_text <- paste0(
      "<strong>", map_data$neighborhood, "</strong><br/>",
      "Properties: ", comma(map_data$count), "<br/>",
      "Average Price: ", dollar(round(map_data$avg_price))
    )
  } else {  # price_per_sqft
    values <- map_data$price_per_sqft
    color_palette <- colorNumeric("Greens", values)
    legend_title <- "Price per Sq Ft"
    popup_text <- paste0(
      "<strong>", map_data$neighborhood, "</strong><br/>",
      "Price per Sq Ft: ", dollar(round(map_data$price_per_sqft, 2)), "<br/>",
      "Properties: ", comma(map_data$count), "<br/>",
      "Average Price: ", dollar(round(map_data$avg_price))
    )
  }
  
  # Add circle markers
  m <- m %>%
    addCircleMarkers(
      lng = ~avg_lng,
      lat = ~avg_lat,
      radius = ~sqrt(count) * 2,  # Size based on property count
      fillColor = ~color_palette(values),
      color = "white",
      weight = 2,
      opacity = 0.8,
      fillOpacity = 0.6,
      popup = popup_text,
      label = ~neighborhood
    )
  
  # Add legend
  m <- m %>%
    addLegend(
      pal = color_palette,
      values = values,
      title = legend_title,
      position = "bottomright",
      opacity = 0.7
    )
  
  # Add clusters if requested
  if(show_clusters && nrow(data) > 100) {
    # Sample individual properties for cluster display
    sample_data <- data %>%
      slice_sample(n = min(500, nrow(data)))  # Limit for performance
    
    cluster_popup <- paste0(
      "<strong>Property Details</strong><br/>",
      "Price: ", dollar(sample_data$price), "<br/>",
      "Size: ", comma(sample_data$sqft), " sq ft<br/>",
      "Type: ", sample_data$property_type, "<br/>",
      "Neighborhood: ", sample_data$neighborhood, "<br/>",
      "Bedrooms: ", sample_data$bedrooms, "<br/>",
      "Bathrooms: ", sample_data$bathrooms
    )
    
    m <- m %>%
      addMarkers(
        data = sample_data,
        lng = ~longitude,
        lat = ~latitude,
        popup = cluster_popup,
        clusterOptions = markerClusterOptions(),
        group = "Properties"
      ) %>%
      addLayersControl(
        overlayGroups = c("Properties"),
        options = layersControlOptions(collapsed = FALSE)
      )
  }
  
  return(m)
}

# Function to perform correlation analysis
perform_correlation_analysis <- function(data) {
  # Select numeric variables for correlation
  numeric_vars <- data %>%
    select(price, sqft, bedrooms, bathrooms, age, parking) %>%
    cor(use = "complete.obs")
  
  return(numeric_vars)
}

# Function to calculate price trends and growth rates
calculate_price_trends <- function(data) {
  trends <- data %>%
    mutate(year_month = floor_date(date, "month")) %>%
    group_by(year_month) %>%
    summarise(
      avg_price = mean(price, na.rm = TRUE),
      count = n(),
      .groups = 'drop'
    ) %>%
    arrange(year_month) %>%
    mutate(
      price_change = avg_price - lag(avg_price),
      price_change_pct = (price_change / lag(avg_price)) * 100,
      rolling_avg_3m = slider::slide_dbl(avg_price, mean, .before = 2, .after = 0),
      rolling_avg_6m = slider::slide_dbl(avg_price, mean, .before = 5, .after = 0)
    ) %>%
    filter(!is.na(price_change))
  
  return(trends)
}

# Function to identify market segments
identify_market_segments <- function(data) {
  segments <- data %>%
    mutate(
      price_category = case_when(
        price < 300000 ~ "Budget",
        price < 500000 ~ "Mid-Market",
        price < 800000 ~ "Premium",
        TRUE ~ "Luxury"
      ),
      size_category = case_when(
        sqft < 1000 ~ "Compact",
        sqft < 1500 ~ "Standard",
        sqft < 2500 ~ "Large",
        TRUE ~ "Extra Large"
      )
    ) %>%
    group_by(price_category, size_category, neighborhood) %>%
    summarise(
      count = n(),
      avg_price = mean(price, na.rm = TRUE),
      avg_price_per_sqft = mean(price_per_sqft, na.rm = TRUE),
      .groups = 'drop'
    ) %>%
    filter(count >= 5) %>%  # Only segments with sufficient data
    arrange(desc(count))
  
  return(segments)
}

# Function to generate market insights
generate_market_insights <- function(data) {
  insights <- list()
  
  # Overall market statistics
  insights$total_properties <- nrow(data)
  insights$avg_price <- mean(data$price, na.rm = TRUE)
  insights$median_price <- median(data$price, na.rm = TRUE)
  insights$price_range <- range(data$price, na.rm = TRUE)
  
  # Most expensive neighborhood
  expensive_neighborhood <- data %>%
    group_by(neighborhood) %>%
    summarise(avg_price = mean(price, na.rm = TRUE), .groups = 'drop') %>%
    arrange(desc(avg_price)) %>%
    slice(1)
  
  insights$most_expensive_neighborhood <- expensive_neighborhood$neighborhood
  insights$most_expensive_avg_price <- expensive_neighborhood$avg_price
  
  # Most affordable neighborhood
  affordable_neighborhood <- data %>%
    group_by(neighborhood) %>%
    summarise(avg_price = mean(price, na.rm = TRUE), .groups = 'drop') %>%
    arrange(avg_price) %>%
    slice(1)
  
  insights$most_affordable_neighborhood <- affordable_neighborhood$neighborhood
  insights$most_affordable_avg_price <- affordable_neighborhood$avg_price
  
  # Most active neighborhood (by transaction volume)
  active_neighborhood <- data %>%
    count(neighborhood, sort = TRUE) %>%
    slice(1)
  
  insights$most_active_neighborhood <- active_neighborhood$neighborhood
  insights$most_active_count <- active_neighborhood$n
  
  # Property type preferences
  popular_property_type <- data %>%
    count(property_type, sort = TRUE) %>%
    slice(1)
  
  insights$most_popular_property_type <- popular_property_type$property_type
  insights$most_popular_count <- popular_property_type$n
  
  # Seasonal trends
  seasonal_stats <- data %>%
    group_by(season) %>%
    summarise(
      count = n(),
      avg_price = mean(price, na.rm = TRUE),
      .groups = 'drop'
    ) %>%
    arrange(desc(count))
  
  insights$busiest_season <- seasonal_stats$season[1]
  insights$busiest_season_count <- seasonal_stats$count[1]
  
  # Price per square foot insights
  insights$avg_price_per_sqft <- mean(data$price_per_sqft, na.rm = TRUE)
  
  # Best value neighborhoods (lowest price per sq ft)
  best_value <- data %>%
    group_by(neighborhood) %>%
    summarise(
      avg_price_per_sqft = mean(price_per_sqft, na.rm = TRUE),
      count = n(),
      .groups = 'drop'
    ) %>%
    filter(count >= 20) %>%  # Neighborhoods with sufficient data
    arrange(avg_price_per_sqft) %>%
    slice(1)
  
  insights$best_value_neighborhood <- best_value$neighborhood
  insights$best_value_price_per_sqft <- best_value$avg_price_per_sqft
  
  return(insights)
}

# Function to create comparative analysis
create_comparative_analysis <- function(data, compare_by = "neighborhood") {
  if(compare_by == "neighborhood") {
    comparison <- data %>%
      group_by(neighborhood) %>%
      summarise(
        properties = n(),
        avg_price = mean(price, na.rm = TRUE),
        median_price = median(price, na.rm = TRUE),
        std_price = sd(price, na.rm = TRUE),
        min_price = min(price, na.rm = TRUE),
        max_price = max(price, na.rm = TRUE),
        avg_sqft = mean(sqft, na.rm = TRUE),
        avg_price_per_sqft = mean(price_per_sqft, na.rm = TRUE),
        .groups = 'drop'
      ) %>%
      arrange(desc(avg_price))
      
  } else if(compare_by == "property_type") {
    comparison <- data %>%
      group_by(property_type) %>%
      summarise(
        properties = n(),
        avg_price = mean(price, na.rm = TRUE),
        median_price = median(price, na.rm = TRUE),
        std_price = sd(price, na.rm = TRUE),
        min_price = min(price, na.rm = TRUE),
        max_price = max(price, na.rm = TRUE),
        avg_sqft = mean(sqft, na.rm = TRUE),
        avg_price_per_sqft = mean(price_per_sqft, na.rm = TRUE),
        .groups = 'drop'
      ) %>%
      arrange(desc(avg_price))
      
  } else {  # by year
    comparison <- data %>%
      group_by(year) %>%
      summarise(
        properties = n(),
        avg_price = mean(price, na.rm = TRUE),
        median_price = median(price, na.rm = TRUE),
        std_price = sd(price, na.rm = TRUE),
        min_price = min(price, na.rm = TRUE),
        max_price = max(price, na.rm = TRUE),
        avg_sqft = mean(sqft, na.rm = TRUE),
        avg_price_per_sqft = mean(price_per_sqft, na.rm = TRUE),
        .groups = 'drop'
      ) %>%
      arrange(desc(year))
  }
  
  return(comparison)
}
