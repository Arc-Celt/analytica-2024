library(tidyverse)
library(plotly)
library(shiny)

# Function to create a "No data available" plot
create_no_data_plot <- function(title) {
  plot_ly() |>
    add_annotations(
      text = "No data available for the current filter criteria",
      showarrow = FALSE,
      font = list(size = 16, color = "darkgray")
    ) |>
    layout(
      title = title,
      xaxis = list(
        showgrid = FALSE,
        zeroline = FALSE,
        showticklabels = FALSE
      ),
      yaxis = list(
        showgrid = FALSE,
        zeroline = FALSE,
        showticklabels = FALSE
      )
    )
}

# Handle "All" logic for selection filters
handle_all_selection <- function(session, input_id, input_value) {
  # If the selection is empty, select "All"
  if (length(input_value) == 0) {
    updateSelectizeInput(session, input_id, selected = "All")
  } else if ("All" %in% input_value && length(input_value) > 1) {
    # If user just selected "All", remove other selections
    if (tail(input_value, 1) == "All") {
      updateSelectizeInput(session, input_id, selected = "All")
    } else {  # Remove "All" if other selections are made
      updateSelectizeInput(
        session, input_id,
        selected = setdiff(input_value, "All")
      )
    }
  }
}

# Ensure work_type is never empty
ensure_non_empty <- function(session, input_id, input_value, default_value) {
  if (length(input_value) == 0) {
    updateSelectizeInput(session, input_id, selected = default_value)
  }
}
