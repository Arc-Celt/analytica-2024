library(shiny)
library(bslib)
library(fontawesome)

# UI definition
ui <- page_fluid(
  theme = bs_theme(),
  tags$head(
    tags$title("Analytica 2024"),
    tags$link(rel = "icon", type = "image/x-icon", href = "favicon.ico"),
    tags$link(rel = "stylesheet", href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css")
  ),
  div(
    class = "container-fluid",
    style = "background-color: RoyalBlue; color: white; padding: 15px 0; margin-bottom: 15px;",
    fluidRow(
      column(
        width = 8,
        h1(
          HTML('<i class="fas fa-chart-bar" style="margin-right: 10px;"></i> Analytica 2024: Insights into the Canadian Data Analyst Job Market'),
          style = "font-size: 30px; font-weight: bold;
          margin-bottom: 5px; margin-left: 25px; padding-top: 10px"
        ),
        p(
          "🚀 We'll all land a satisfying job eventually. Keep calm and carry on!",
          style = "color: white; margin-left: 25px"
        )
      ),
      column(
        width = 4,
        div(
          style = "text-align: right; height: 100%; display: flex; 
                 align-items: center; justify-content: flex-end; 
                 margin-right: 40px",
          a(
            class = "btn btn-outline-light btn-sm",
            href = "https://www.kaggle.com/datasets/amanbhattarai695/data-analyst-job-roles-in-canada/data",
            target = "_blank",
            style = "margin-right: 20px;",
            tags$i(class = "fas fa-database", style = "margin-right: 5px;"),
            "Source"
          ),
          a(
            class = "btn btn-outline-light btn-sm",
            href = "https://github.ubc.ca/mds-2024-25/DSCI_532_individual-assignment_celt313",
            target = "_blank",
            style = "margin-right: 5px;",
            tags$i(class = "fab fa-github", style = "margin-right: 5px;"),
            "Code"
          )
        )
      )
    )
  ),
  hr(style = "margin-top: 0; margin-bottom: 15px;  margin-left: 8px"),
  # Sidebar and main panel
  fluidRow(
    column(
      3,
      div(
        class = "well",
        style = "padding: 12px; border-radius: 5px;",
        h4(
          "🔎 Filter Options",
          style = "font-weight: bold; font-size: 20px; margin-top: 0; margin-bottom: 15px;"
        ),
        div(style = "margin-bottom: 10px;",
          selectizeInput("position", "Position",
            choices = c("All", unique(job_data$Position)),
            selected = "All",
            multiple = TRUE,
            options = list(plugins = list("remove_button"))
          )
        ),
        div(style = "margin-bottom: 10px;",
          selectizeInput("province", "Province",
            choices = c("All", sort(unique(job_data$Province))),
            selected = "All",
            multiple = TRUE,
            options = list(plugins = list("remove_button"))
          )
        ),
        div(style = "margin-bottom: 10px;",
          selectizeInput("work_type", "Work Type",
            choices = unique(job_data$Work_Type),
            selected = unique(job_data$Work_Type),
            multiple = TRUE,
            options = list(plugins = list("remove_button"))
          )
        ),
        div(style = "margin-bottom: 10px;",
          selectInput("seniority", "Seniority Level",
            choices = c("Any", "Junior", "Mid", "Senior"),
            selected = "Any"
          )
        ),
        div(style = "margin-bottom: 10px;",
          selectizeInput("industry", "Industry Type",
            choices = c("All", unique(job_data$Industry_Type)),
            selected = "All",
            multiple = TRUE,
            options = list(plugins = list("remove_button"))
          )
        ),
        div(
          style = "margin-bottom: 5px;",
          sliderInput("salary", "Average Salary Range",
            min = round(min(job_data$Avg_Salary, na.rm = TRUE), -4),
            max = round(max(job_data$Avg_Salary, na.rm = TRUE) + 5000, -4),
            value = c(
              round(min(job_data$Avg_Salary, na.rm = TRUE), -4),
              round(max(job_data$Avg_Salary, na.rm = TRUE) + 5000, -4)
            ),
            step = 1000,
            pre = "$",
            sep = ",",
            animate = FALSE
          )
        )
      )
    ),
    column(
      9,
      div(
        style = "display: flex; justify-content: center;
                width: 100%; margin-bottom: 15px;",
        div(
          style = "width: 95%;",
          plotlyOutput("position_plot", height = "420px")
        )
      ),
      div(
        style = "display: flex; justify-content: center; width: 100%;",
        div(
          style = "width: 95%; display: flex; justify-content: space-between;",
          div(
            style = "width: 49%;",
            plotlyOutput("skill_plot", height = "210px")
          ),
          div(
            style = "width: 49%;",
            plotlyOutput("salary_plot", height = "210px")
          )
        )
      )
    )
  ),

  # Second row with data table
  div(
    style = "margin-top: 25px; margin-bottom: 20px; margin-left: 15px;
            margin-right: 15px; justify-content: center; display: flex",
    fluidRow(
      column(
        width = 12,
        div(
          style = "margin-top: 20px;",
          h3(
            "🎯 Job Listings Based on Your Filters",
            style = "font-weight: bold; font-size: 20px;"
          ),
          dataTableOutput("filtered_table")
        )
      )
    )
  ),
  # Footer section
  div(
    style = "padding: 20px; text-align: center;
            margin-top: 30px;",
    p(
      "This dashboard analyzes Canada's 2024 data analyst job market",
      "to help job seekers make strategic career decisions.",
      style = "margin-bottom: 5px;"
    ),
    p(
      HTML('Developed by Archer Liu | 
      <a href="https://www.kaggle.com/datasets/amanbhattarai695/data-analyst-job-roles-in-canada/data" target="_blank">Data source</a> 
      | <a href="https://www.flaticon.com/free-icons/data" title="data icons">Icon created by Flaticon</a> | Last updated: March 11, 2025'),
    )
  )
)
