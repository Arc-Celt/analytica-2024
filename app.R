library(shiny)
library(bslib)
library(ggplot2)
library(tidyverse)
library(plotly)
library(sf)
library(DT)

data <- read_csv("data/processed/processed_data.csv")
source("src/ui.R")
source("src/server.R")

# Run the dashboard
shinyApp(ui, server)
