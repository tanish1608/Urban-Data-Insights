# Visualization Module for Urban Data Insights
# This module contains all ggplot2 and plotly visualization functions

library(ggplot2)
library(plotly)
library(dplyr)
library(scales)
library(viridis)

# Custom theme for consistent plot styling
urban_theme <- function() {
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5, color = "gray60"),
    axis.title = element_text(size = 11, face = "bold"),
    axis.text = element_text(size = 10),
    legend.title = element_text(size = 11, face = "bold"),
    legend.text = element_text(size = 10),
    strip.text = element_text(size = 11, face = "bold"),
    panel.grid.minor = element_blank(),
    plot.margin = margin(t = 20, r = 20, b = 20, l = 20)
  )
}

# Color palette for neighborhoods
neighborhood_colors <- c(
  "#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd", "#8c564b",
  "#e377c2", "#7f7f7f", "#bcbd22", "#17becf", "#aec7e8", "#ffbb78"
)

# Function to create price trend plot over time
create_price_trend_plot <- function(data) {
  # Aggregate data by month
  monthly_data <- data %>%
    mutate(year_month = floor_date(date, "month")) %>%
    group_by(year_month) %>%
    summarise(
      avg_price = mean(price, na.rm = TRUE),
      median_price = median(price, na.rm = TRUE),
      count = n(),
      .groups = 'drop'
    ) %>%
    filter(count >= 5)  # Only include months with at least 5 sales
  
  p <- ggplot(monthly_data, aes(x = year_month)) +
    geom_line(aes(y = avg_price, color = "Average Price"), size = 1.2, alpha = 0.8) +
    geom_line(aes(y = median_price, color = "Median Price"), size = 1.2, alpha = 0.8) +
    geom_smooth(aes(y = avg_price), method = "loess", se = TRUE, alpha = 0.2, color = "blue") +
    scale_color_manual(values = c("Average Price" = "#1f77b4", "Median Price" = "#ff7f0e")) +
    scale_y_continuous(labels = dollar_format(scale = 1e-3, suffix = "K")) +
    scale_x_date(date_breaks = "3 months", date_labels = "%b %Y") +
    labs(
      title = "Housing Price Trends Over Time",
      subtitle = "Monthly average and median housing prices",
      x = "Date",
      y = "Price",
      color = "Price Type"
    ) +
    urban_theme() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  ggplotly(p, tooltip = c("x", "y", "colour")) %>%
    layout(hovermode = "x unified")
}

# Function to create property type distribution plot
create_property_type_plot <- function(data) {
  type_data <- data %>%
    count(property_type, sort = TRUE) %>%
    mutate(
      percentage = n / sum(n) * 100,
      property_type = factor(property_type, levels = property_type)
    )
  
  p <- ggplot(type_data, aes(x = "", y = percentage, fill = property_type)) +
    geom_bar(stat = "identity", width = 1) +
    coord_polar("y", start = 0) +
    scale_fill_viridis_d(name = "Property Type") +
    labs(
      title = "Property Type Distribution",
      subtitle = "Percentage of properties by type"
    ) +
    theme_void() +
    theme(
      plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
      plot.subtitle = element_text(size = 12, hjust = 0.5, color = "gray60"),
      legend.title = element_text(size = 11, face = "bold"),
      legend.text = element_text(size = 10)
    )
  
  ggplotly(p, tooltip = c("fill", "y")) %>%
    layout(showlegend = TRUE)
}

# Function to create neighborhood price distribution plot
create_neighborhood_price_plot <- function(data) {
  neighborhood_data <- data %>%
    group_by(neighborhood) %>%
    summarise(
      avg_price = mean(price, na.rm = TRUE),
      median_price = median(price, na.rm = TRUE),
      count = n(),
      .groups = 'drop'
    ) %>%
    arrange(desc(avg_price)) %>%
    head(10)  # Top 10 neighborhoods by average price
  
  p <- ggplot(neighborhood_data, aes(x = reorder(neighborhood, avg_price))) +
    geom_col(aes(y = avg_price, fill = "Average"), alpha = 0.7, width = 0.6) +
    geom_point(aes(y = median_price, color = "Median"), size = 3) +
    scale_fill_manual(values = c("Average" = "#1f77b4")) +
    scale_color_manual(values = c("Median" = "#ff7f0e")) +
    scale_y_continuous(labels = dollar_format(scale = 1e-3, suffix = "K")) +
    coord_flip() +
    labs(
      title = "Average Housing Prices by Neighborhood",
      subtitle = "Top 10 neighborhoods by average price",
      x = "Neighborhood",
      y = "Price",
      fill = "Price Type",
      color = "Price Type"
    ) +
    urban_theme()
  
  ggplotly(p, tooltip = c("x", "y")) %>%
    layout(hovermode = "y unified")
}

# Function to create time series plot with filters
create_timeseries_plot <- function(data) {
  # Group data by month and property type
  ts_data <- data %>%
    mutate(year_month = floor_date(date, "month")) %>%
    group_by(year_month, property_type) %>%
    summarise(
      avg_price = mean(price, na.rm = TRUE),
      count = n(),
      .groups = 'drop'
    ) %>%
    filter(count >= 3)  # Only include months with at least 3 sales
  
  p <- ggplot(ts_data, aes(x = year_month, y = avg_price, color = property_type)) +
    geom_line(size = 1, alpha = 0.8) +
    geom_point(size = 2, alpha = 0.6) +
    scale_color_viridis_d(name = "Property Type") +
    scale_y_continuous(labels = dollar_format(scale = 1e-3, suffix = "K")) +
    scale_x_date(date_breaks = "3 months", date_labels = "%b %Y") +
    labs(
      title = "Housing Price Trends by Property Type",
      subtitle = "Monthly average prices for different property types",
      x = "Date",
      y = "Average Price"
    ) +
    urban_theme() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  ggplotly(p, tooltip = c("x", "y", "colour")) %>%
    layout(hovermode = "x unified")
}

# Function to create price vs size scatter plot
create_price_size_plot <- function(data) {
  # Sample data if too many points for performance
  if(nrow(data) > 1000) {
    plot_data <- data %>% slice_sample(n = 1000)
  } else {
    plot_data <- data
  }
  
  p <- ggplot(plot_data, aes(x = sqft, y = price, color = property_type)) +
    geom_point(alpha = 0.6, size = 2) +
    geom_smooth(method = "lm", se = TRUE, alpha = 0.2) +
    scale_color_viridis_d(name = "Property Type") +
    scale_y_continuous(labels = dollar_format(scale = 1e-3, suffix = "K")) +
    scale_x_continuous(labels = comma_format()) +
    labs(
      title = "Price vs. Square Footage",
      subtitle = "Relationship between property size and price",
      x = "Square Footage",
      y = "Price"
    ) +
    urban_theme()
  
  ggplotly(p, tooltip = c("x", "y", "colour")) %>%
    layout(hovermode = "closest")
}

# Function to create seasonal trends plot
create_seasonal_plot <- function(data) {
  seasonal_data <- data %>%
    group_by(season, year) %>%
    summarise(
      avg_price = mean(price, na.rm = TRUE),
      count = n(),
      .groups = 'drop'
    ) %>%
    group_by(season) %>%
    summarise(
      avg_price = mean(avg_price, na.rm = TRUE),
      total_sales = sum(count),
      .groups = 'drop'
    ) %>%
    mutate(season = factor(season, levels = c("Spring", "Summer", "Fall", "Winter")))
  
  p1 <- ggplot(seasonal_data, aes(x = season, y = avg_price, fill = season)) +
    geom_col(alpha = 0.8, width = 0.7) +
    scale_fill_viridis_d(name = "Season") +
    scale_y_continuous(labels = dollar_format(scale = 1e-3, suffix = "K")) +
    labs(
      title = "Seasonal Price Trends",
      subtitle = "Average prices by season",
      x = "Season",
      y = "Average Price"
    ) +
    urban_theme() +
    theme(legend.position = "none")
  
  ggplotly(p1, tooltip = c("x", "y")) %>%
    layout(showlegend = FALSE)
}

# Function to create neighborhood analysis plot
create_neighborhood_analysis_plot <- function(data, selected_neighborhoods, analysis_type) {
  if(is.null(selected_neighborhoods) || length(selected_neighborhoods) == 0) {
    return(plotly_empty())
  }
  
  filtered_data <- data %>%
    filter(neighborhood %in% selected_neighborhoods)
  
  if(analysis_type == "price") {
    plot_data <- filtered_data %>%
      group_by(neighborhood) %>%
      summarise(
        avg_price = mean(price, na.rm = TRUE),
        median_price = median(price, na.rm = TRUE),
        min_price = min(price, na.rm = TRUE),
        max_price = max(price, na.rm = TRUE),
        .groups = 'drop'
      )
    
    p <- ggplot(plot_data, aes(x = reorder(neighborhood, avg_price))) +
      geom_col(aes(y = avg_price), fill = "#1f77b4", alpha = 0.7, width = 0.6) +
      geom_errorbar(aes(ymin = min_price, ymax = max_price), width = 0.2, alpha = 0.5) +
      scale_y_continuous(labels = dollar_format(scale = 1e-3, suffix = "K")) +
      coord_flip() +
      labs(
        title = "Price Comparison Across Neighborhoods",
        subtitle = "Average price with min/max range",
        x = "Neighborhood",
        y = "Price"
      ) +
      urban_theme()
    
  } else if(analysis_type == "size") {
    plot_data <- filtered_data %>%
      group_by(neighborhood) %>%
      summarise(
        avg_sqft = mean(sqft, na.rm = TRUE),
        median_sqft = median(sqft, na.rm = TRUE),
        .groups = 'drop'
      )
    
    p <- ggplot(plot_data, aes(x = reorder(neighborhood, avg_sqft))) +
      geom_col(aes(y = avg_sqft, fill = "Average"), alpha = 0.7, width = 0.6) +
      geom_point(aes(y = median_sqft, color = "Median"), size = 3) +
      scale_fill_manual(values = c("Average" = "#2ca02c")) +
      scale_color_manual(values = c("Median" = "#ff7f0e")) +
      scale_y_continuous(labels = comma_format()) +
      coord_flip() +
      labs(
        title = "Size Comparison Across Neighborhoods",
        subtitle = "Average and median square footage",
        x = "Neighborhood",
        y = "Square Footage",
        fill = "Metric",
        color = "Metric"
      ) +
      urban_theme()
    
  } else {  # activity
    plot_data <- filtered_data %>%
      mutate(year_month = floor_date(date, "month")) %>%
      group_by(neighborhood, year_month) %>%
      summarise(sales_count = n(), .groups = 'drop') %>%
      group_by(neighborhood) %>%
      summarise(
        avg_monthly_sales = mean(sales_count),
        total_sales = sum(sales_count),
        .groups = 'drop'
      )
    
    p <- ggplot(plot_data, aes(x = reorder(neighborhood, avg_monthly_sales), y = avg_monthly_sales)) +
      geom_col(fill = "#d62728", alpha = 0.7, width = 0.6) +
      coord_flip() +
      labs(
        title = "Market Activity by Neighborhood",
        subtitle = "Average monthly sales volume",
        x = "Neighborhood",
        y = "Average Monthly Sales"
      ) +
      urban_theme()
  }
  
  ggplotly(p, tooltip = c("x", "y")) %>%
    layout(hovermode = "y unified")
}
