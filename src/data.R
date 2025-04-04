library(tidyverse)
library(lubridate)
library(stringr)

# Load the data
job_data <- read_csv("data/raw/Cleaned_Dataset.csv")

# Clean column names by replacing spaces with underscores
colnames(job_data) <- str_replace_all(colnames(job_data), " ", "_")

# Function to clean city names
clean_city <- function(city) {
  # Mapping of known city name inconsistencies
  city_mapping <- list(
    "MontrÃƒÂ©al" = "Montreal",
    "Mont-royal" = "Montreal",
    "Baie-d'UrfÃƒÆ’Ã‚Â©" = "Baie-d'Urfé",
    "Greater Toronto Area" = "Toronto",
    "Metro Vancouver Regional District" = "Vancouver",
    "Portage La Prairie" = "Portage la Prairie",
    "Rocky View" = "Rocky View County"
  )
  return(city_mapping[[city]] %||% city)
}

# Function to clean province names
clean_province <- function(province) {
  # Mapping of province abbreviations
  province_mapping <- c(
    "Undef" = "Remote",
    "ON" = "Ontario",
    "BC" = "British Columbia",
    "AB" = "Alberta",
    "SK" = "Saskatchewan",
    "QC" = "Quebec",
    "PE" = "Prince Edward Island",
    "NB" = "New Brunswick",
    "NS" = "Nova Scotia",
    "MB" = "Manitoba",
    "NL" = "Newfoundland and Labrador",
    "YT" = "Yukon",
    "NT" = "Northwest Territories",
    "NFL" = "Newfoundland and Labrador"
  )
  return(province_mapping[[province]] %||% province)
}

# Apply the cleaning functions
job_data$City <- sapply(job_data$City, clean_city)
job_data$Province <- sapply(job_data$Province, clean_province)

# Combine City and Province into a single Location column
job_data <- job_data |>
  mutate(
    Location = case_when(
      str_detect(City, "^Remote") & Province != "Remote"
      ~ paste(City, Province, sep = ", "),
      str_detect(City, "^Remote") ~ City,
      City == "Remote" & Province == "Remote" ~ "Remote",
      TRUE ~ paste(City, Province, sep = ", ")
    )
  )

# Clean and transform the 'Skill' column
job_data <- job_data |>
  mutate(
    Skill = str_to_upper(Skill),
    Skill = ifelse(Skill == "UNDEF", "No Specification", Skill)
  ) |>
  select(
    Job_Title, Position, Employer, Province, Location, Skill,
    Seniority, Work_Type, Industry_Type, Avg_Salary
  )

# Save the cleaned data
write_csv(job_data, "data/processed/processed_data.csv")
