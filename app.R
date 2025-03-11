library(shiny)
library(bslib)
library(ggplot2)
library(tidyverse)
library(plotly)
library(sf)
library(DT)
library(fontawesome)

job_data <- read_csv("data/processed/processed_data.csv")
source("src/ui.R", local = environment())
source("src/server.R", local = environment())

# Run the dashboard
shinyApp(ui, server)
