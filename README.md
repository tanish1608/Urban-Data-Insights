# Urban Data Insights - R-Based Analysis Tool

## Overview

Urban Data Insights is a comprehensive R-based Shiny application designed for analyzing urban housing data and visualizing housing trends across different neighborhoods. The application provides interactive dashboards, statistical analysis, and mapping capabilities to help users understand real estate market dynamics.

## Features

### 🏠 **Housing Trends Analysis**
- Interactive time series visualization of housing prices
- Seasonal trend analysis
- Price vs. property size correlation analysis
- Property type distribution analysis

### 🗺️ **Interactive Mapping**
- Leaflet-powered interactive maps
- Neighborhood clustering and heat maps
- Property location visualization
- Customizable map metrics (price, count, price per sq ft)

### 📊 **Neighborhood Comparison**
- Multi-neighborhood statistical comparison
- Market activity analysis
- Comparative pricing analysis
- Comprehensive neighborhood statistics tables

### 📈 **Data Visualization**
- ggplot2-powered static visualizations
- Plotly interactive charts
- Real-time filtering and updates
- Multiple chart types (line, bar, scatter, pie)

### 🔍 **Data Explorer**
- Interactive data tables with DT
- Advanced filtering and search capabilities
- Data export functionality
- Sample size controls for performance

## Technology Stack

- **R** - Core programming language
- **Shiny** - Web application framework
- **shinydashboard** - Dashboard layout and components
- **ggplot2** - Data visualization
- **plotly** - Interactive plotting
- **dplyr** - Data manipulation and analysis
- **leaflet** - Interactive mapping
- **DT** - Interactive data tables
- **lubridate** - Date/time manipulation

## Installation

### Prerequisites

Ensure you have R (version 4.0 or higher) installed on your system.

### Install Required Packages

```r
# Run this in your R console
install.packages(c(
  "shiny", "shinydashboard", "dplyr", "readr", "lubridate",
  "ggplot2", "plotly", "leaflet", "viridis", "DT", "scales"
))
```

Or use the provided package installer:

```r
source("packages.R")
check_and_install_packages()
```

## Usage

### Running the Application

1. Clone or download this repository
2. Open R or RStudio
3. Set your working directory to the project folder:
   ```r
   setwd("path/to/urban-data-insights")
   ```
4. Run the application:
   ```r
   shiny::runApp()
   ```

The application will launch in your default web browser.

### Alternative Launch Methods

```r
# Run directly from app.R
source("app.R")

# Or using specific port
shiny::runApp(port = 3838)

# Run in background
shiny::runApp(launch.browser = FALSE)
```

## Project Structure

```
urban-data-insights/
├── app.R                    # Main Shiny application
├── config.R                 # Configuration settings
├── packages.R               # Package management
├── README.md               # This file
├── modules/                # Modular components
│   ├── data_processing.R   # Data loading and processing
│   ├── visualization.R     # ggplot2 and plotly functions
│   └── analysis.R          # Statistical analysis functions
└── www/                    # Static web assets
    └── custom.css          # Custom styling
```

## Data

The application currently uses synthetic housing data generated programmatically for demonstration purposes. The sample dataset includes:

- **5,000 properties** across 12 neighborhoods
- **Property attributes**: price, size, bedrooms, bathrooms, age, parking
- **Location data**: latitude, longitude coordinates
- **Time series**: sales dates from 2020-2024
- **Property types**: Single Family, Condo, Townhouse, Apartment, Duplex

### Real Data Integration

To use real housing data, modify the `load_sample_data()` function in `modules/data_processing.R` to load your data source:

```r
# Example: Load from CSV
load_real_data <- function() {
  housing_data <- read_csv("path/to/your/housing_data.csv")
  return(clean_housing_data(housing_data))
}
```

## Key Functionality

### Dashboard Features

1. **Overview Dashboard**
   - Key performance indicators (KPIs)
   - Price trend visualization
   - Property type distribution
   - Neighborhood price comparison

2. **Housing Trends**
   - Time series analysis with filters
   - Property type comparisons
   - Seasonal trend analysis
   - Price vs. size correlation

3. **Neighborhood Analysis**
   - Multi-neighborhood comparison
   - Statistical summary tables
   - Market activity analysis

4. **Interactive Map**
   - Leaflet-powered mapping
   - Customizable metrics display
   - Property clustering
   - Popup information windows

5. **Data Explorer**
   - Interactive data tables
   - Advanced search and filtering
   - Data export capabilities

### Analytical Capabilities

- **Statistical Analysis**: Correlation analysis, trend calculation, market segmentation
- **Time Series Analysis**: Monthly/quarterly/yearly aggregations, seasonal decomposition
- **Spatial Analysis**: Geographic clustering, neighborhood comparisons
- **Market Intelligence**: Price trends, inventory analysis, market activity metrics

## Customization

### Styling

Modify `www/custom.css` to customize the application's appearance:

```css
/* Example: Change primary color */
.btn-primary {
    background-color: your-color;
    border-color: your-border-color;
}
```

### Configuration

Update `config.R` to modify application settings:

```r
# Example: Change default map center
DEFAULT_MAP_CENTER <- list(lat = your-lat, lng = your-lng)
```

### Adding New Visualizations

1. Add visualization functions to `modules/visualization.R`
2. Update the UI in `app.R` to include new plot outputs
3. Add corresponding server logic for reactive updates

## Performance Considerations

- **Data Sampling**: Large datasets are automatically sampled for scatter plots
- **Map Clustering**: Marker clustering is used for map performance
- **Reactive Updates**: Efficient reactive programming patterns
- **Memory Management**: Data is processed in chunks when possible

## Browser Compatibility

- Chrome (recommended)
- Firefox
- Safari
- Edge

## Troubleshooting

### Common Issues

1. **Package Installation Errors**
   ```r
   # Try installing from source
   install.packages("package-name", type = "source")
   ```

2. **Port Already in Use**
   ```r
   # Use a different port
   shiny::runApp(port = 8080)
   ```

3. **Memory Issues with Large Datasets**
   - Increase R memory limit
   - Reduce sample sizes in config.R
   - Enable data filtering before visualization

## Development

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Code Style

- Follow R style guidelines
- Use meaningful variable names
- Comment complex functions
- Maintain modular structure

## License

This project is open source and available under the MIT License.

## Contact

For questions, suggestions, or support, please create an issue in the repository.

---

**Urban Data Insights** - Empowering data-driven urban analysis with R and Shiny.
