#!/bin/bash

# Urban Data Insights - Shell Launch Script
# For macOS and Linux users

echo "=== Urban Data Insights - Launch Script ==="
echo "Starting R-based analysis tool..."

# Check if R is installed
if ! command -v R &> /dev/null; then
    echo "Error: R is not installed or not in PATH"
    echo "Please install R from https://cran.r-project.org/"
    exit 1
fi

echo "R found ✓"

# Check if we're in the right directory
if [ ! -f "app.R" ]; then
    echo "Error: app.R not found in current directory"
    echo "Please navigate to the urban-data-insights directory"
    exit 1
fi

echo "Application files found ✓"

# Launch the R script
echo "Launching application..."
R --no-restore --no-save -e "source('run_app.R')"
