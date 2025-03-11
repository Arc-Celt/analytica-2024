library(shiny)
library(ggplot2)
library(tidyverse)

source("src/utils.R")

server <- function(input, output, session) {
  # Handle "All" logic for position selection
  observeEvent(input$position,
    {
      handle_all_selection(session, "position", input$position)
    },
    ignoreNULL = FALSE
  )

  # Handle "All" logic for province selection
  observeEvent(input$province,
    {
      handle_all_selection(session, "province", input$province)
    },
    ignoreNULL = FALSE
  )

  # Handle "All" logic for industry selection
  observeEvent(input$industry,
    {
      handle_all_selection(session, "industry", input$industry)
    },
    ignoreNULL = FALSE
  )

  # Make sure work_type is never empty
  observeEvent(input$work_type,
    {
      ensure_non_empty(
        session, "work_type", 
        input$work_type, unique(job_data$Work_Type)[1]
      )
    },
    ignoreNULL = FALSE
  )

  filtered_data <- reactive({
    job_data |>
      filter(
        (input$position == "All" | Position %in% input$position),
        (input$province == "All" | Province %in% input$province),
        Work_Type %in% input$work_type,
        (input$seniority == "Any" | Seniority == input$seniority),
        (input$industry == "All" | Industry_Type %in% input$industry),
        Avg_Salary >= input$salary[1],
        Avg_Salary <= input$salary[2]
      )
  })

  output$filtered_table <- renderDataTable({
    if (nrow(filtered_data()) == 0) {
      return(datatable(
        data.frame(Message = "No jobs found for the selected criteria."),
        options = list(
          dom = "t",
          ordering = FALSE
        )
      ))
    }

    display_data <- filtered_data() |>
      select(
        Job_Title, Position, Employer, Location, 
        Skill, Seniority, Work_Type, Industry_Type, Avg_Salary
      )

    colnames(display_data) <- c(
      "Job Title", "Position", "Employer", "Location",
      "Skill", "Seniority", "Work Type", "Industry Type", "Average Salary(CAD)"
    )

    datatable(
      display_data,
      options = list(
        pageLength = 5,
        autoWidth = TRUE
      ),
      class = "cell-border stripe"
    )
  })

  output$position_plot <- renderPlotly({
    if (nrow(filtered_data()) == 0) {
      return(create_no_data_plot("Count of Job Positions"))
    }

    position_data <- filtered_data() |>
      count(Position) |>
      arrange(desc(n))

    # Hover text data
    position_data <- position_data |>
      mutate(hover_text = paste(
        "Position:", Position,
        "<br>Count:", n,
        "<br>Percentage:", round(n / sum(n) * 100, 1), "%"
      ))

    # Sort positions by count
    p <- position_data |>
      ggplot(aes(x = n, y = reorder(Position, n), text = hover_text)) +
      geom_bar(stat = "identity") +
      labs(title = "Count of Job Positions", x = "Count", y = "Positions") +
      theme_minimal() +
      theme(
        plot.title = element_text(face = "bold")
      ) +
      scale_x_continuous(expand = c(0.01, 0))

    ggplotly(p, tooltip = "text") |>
      layout(hoverlabel = list(bgcolor = "white"))
  })

  output$skill_plot <- renderPlotly({
    if (nrow(filtered_data()) == 0) {
      return(create_no_data_plot("Top 10 Skills Required by Job Listings"))
    }

    skill_data <- filtered_data() |>
      separate_rows(Skill, sep = ", ") |>
      filter(!is.na(Skill), Skill != "", Skill != "No Specification")

    if (nrow(skill_data) == 0) {
      return(create_no_data_plot("Top 10 Skills Required by Job Listings"))
    }

    skill_data <- skill_data |>
      count(Skill) |>
      arrange(desc(n)) |>
      head(10)

    # Hover text data
    skill_data <- skill_data |>
      mutate(hover_text = paste(
        "Skill:", Skill,
        "<br>Count:", n,
        "<br>Percentage:", round(n / sum(n) * 100, 1), "%"
      ))

    # Sort skills by count
    p <- skill_data |>
      ggplot(aes(x = n, y = reorder(Skill, n), text = hover_text)) +
      geom_bar(stat = "identity") +
      labs(
        title = "Top 10 Skills Required by Job Listings",
        x = "Count", y = "Skills"
      ) +
      theme_minimal() +
      theme(
        plot.title = element_text(face = "bold")
      ) +
      scale_x_continuous(expand = c(0.01, 0))

    ggplotly(p, tooltip = "text") |>
      layout(hoverlabel = list(bgcolor = "white"))
  })

  output$salary_plot <- renderPlotly({
    if (nrow(filtered_data()) == 0) {
      return(create_no_data_plot("Distribution of Average Salaries"))
    }

    # Group by Avg_Salary ranges
    salary_counts <- filtered_data() |>
      mutate(salary_group = round(Avg_Salary / 5000) * 5000) |>
      group_by(salary_group) |>
      summarise(
        n = n(),
        .groups = "drop"
      )

    if (nrow(salary_counts) == 0) {
      return(create_no_data_plot("Distribution of Average Salaries"))
    }

    salary_counts <- salary_counts |>
      arrange(salary_group) |>
      mutate(
        salary_range = paste0(format(salary_group, big.mark = ","), " CAD"),
        hover_text = paste(
          "Average Salary:", format(salary_group, big.mark = ","), "CAD",
          "<br>Count:", n,
          "<br>Percentage:", round(n / sum(n) * 100, 1), "%"
        )
      )

    p <- salary_counts|>
      ggplot(aes(x = salary_group, y = n, text = hover_text)) +
      geom_col() +
      labs(
        title = "Distribution of Average Salaries",
        x = "Average Salary (CAD)",
        y = "Count"
      ) +
      theme_minimal() +
      theme(
        plot.title = element_text(face = "bold")
      ) +
      scale_x_continuous(
        labels = scales::comma_format(), expand = c(0.03, 0.05)
      )

    ggplotly(p, tooltip = "text") |>
      layout(hoverlabel = list(bgcolor = "white"))
  })
}
