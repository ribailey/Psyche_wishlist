# Use the official R base image
FROM r-base:latest

# Install system dependencies for R packages
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy your R script into the container
COPY Bailey_wishlist_script_19Apr2025.R /app/Bailey_wishlist_script_19Apr2025.R

# Install required R packages
RUN R -e "install.packages(c('data.table', 'jsonlite', 'httr', 'googlesheets4', 'curl', 'gargle', 'googledrive'), repos='https://cloud.r-project.org/')"

# Define the command to run your script
CMD ["Rscript", "/app/Bailey_wishlist_script_19Apr2025.R"]
