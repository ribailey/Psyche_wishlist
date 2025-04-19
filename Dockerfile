# Use the official R base image from Docker Hub
FROM r-base:latest

# Set the working directory in the container
WORKDIR /app

# Copy your R script into the container
COPY your-script.R /app/Bailey_wishlist_script_19Apr2025.R

# Install any required R packages (replace with your actual package dependencies)
RUN R -e "install.packages(c('data.table', 'jsonlite', 'httr', 'googlesheets4'), repos='http://cran.rstudio.com/')"

# Define the command to run your script
CMD ["Rscript", "/app/Bailey_wishlist_script_19Apr2025.R"]
