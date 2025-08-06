# Urban Data Insights - Configuration File
# Global configuration settings for the application

# Application metadata
APP_NAME <- "Urban Data Insights"
APP_VERSION <- "1.0.0"
APP_DESCRIPTION <- "R-Based Analysis Tool for Urban Housing Data"

# Data settings
DEFAULT_SAMPLE_SIZE <- 5000
MAX_MAP_POINTS <- 500
MIN_NEIGHBORHOOD_SALES <- 5

# Plot settings
PLOT_HEIGHT <- 400
MAP_HEIGHT <- 550
DEFAULT_COLORS <- c("#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd")

# Map settings
DEFAULT_MAP_CENTER <- list(lat = 37.75, lng = -122.4)
DEFAULT_MAP_ZOOM <- 12

# Date ranges
MIN_DATE <- as.Date("2020-01-01")
MAX_DATE <- as.Date("2024-12-31")

# Price ranges (in USD)
MIN_PRICE <- 50000
MAX_PRICE <- 2000000

# Performance settings
MAX_SCATTER_POINTS <- 1000  # Maximum points to show in scatter plots
CACHE_TIMEOUT <- 3600       # Cache timeout in seconds

# UI settings
SIDEBAR_WIDTH <- 300
BOX_HEIGHT <- 400

# Export settings
EXPORT_FORMATS <- c("CSV", "Excel", "PDF")
MAX_EXPORT_ROWS <- 10000

# Logging settings
LOG_LEVEL <- "INFO"  # Options: DEBUG, INFO, WARN, ERROR
LOG_FILE <- "app.log"

# Feature flags
ENABLE_CACHING <- TRUE
ENABLE_CLUSTERING <- TRUE
ENABLE_EXPORT <- TRUE
ENABLE_ADVANCED_FILTERS <- TRUE

# API settings (for future integration)
API_TIMEOUT <- 30
API_RETRY_ATTEMPTS <- 3

# Neighborhood groupings for analysis
NEIGHBORHOOD_GROUPS <- list(
  "Downtown Core" = c("Downtown", "Tech Quarter", "Historic District"),
  "Waterfront" = c("Riverside", "Marina Bay", "Lakeside"),
  "Residential" = c("Hillcrest", "Oakwood", "Pine Valley", "Sunset District"),
  "Mixed Use" = c("University Area", "Industrial Zone")
)

# Property type categories
PROPERTY_TYPE_CATEGORIES <- list(
  "Single Family Homes" = c("Single Family"),
  "Multi-Family" = c("Duplex", "Townhouse"),
  "Condominiums" = c("Condo"),
  "Rentals" = c("Apartment")
)

# Price categories
PRICE_CATEGORIES <- list(
  "Budget" = c(0, 300000),
  "Mid-Market" = c(300000, 500000),
  "Premium" = c(500000, 800000),
  "Luxury" = c(800000, Inf)
)

# Size categories (square feet)
SIZE_CATEGORIES <- list(
  "Compact" = c(0, 1000),
  "Standard" = c(1000, 1500),
  "Large" = c(1500, 2500),
  "Extra Large" = c(2500, Inf)
)

# Analysis periods
ANALYSIS_PERIODS <- c("Daily", "Weekly", "Monthly", "Quarterly", "Yearly")

# Statistical confidence levels
CONFIDENCE_LEVELS <- c(0.90, 0.95, 0.99)

# Dashboard refresh intervals (in milliseconds)
REFRESH_INTERVALS <- list(
  "Real-time" = 5000,
  "Every minute" = 60000,
  "Every 5 minutes" = 300000,
  "Every hour" = 3600000
)
