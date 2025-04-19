# Use the official R base image
FROM r-base:latest

# Install system dependencies for R packages
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy your R script into the container
COPY Bailey_wishlist_script_19Apr2025.R /app/Bailey_wishlist_script_19Apr2025.R

# Install required R packages
RUN R -e "install.packages(c('data.table', 'jsonlite', 'httr', 'curl', 'gargle', 'googledrive', 'googlesheets4'), repos='https://cloud.r-project.org/', dependencies=TRUE)"

# The script will need authentication for Google Sheets
# Environment variable or mounted volume with credentials will be needed at runtime

# Define the command to run your script
CMD ["Rscript", "/app/Bailey_wishlist_script_19Apr2025.R"]
