# Skills Test 1

library(tidyverse)
library(ggplot2)

# I

cleaned_covid_data <- read.csv(file = "https://raw.githubusercontent.com/gzahn/BIOL3100_Exams/master/Exam_1/cleaned_covid_data.csv")

  # Using repository url tp make relative
  # Saving it to cleaned_covid_data object so we can play with it


# II

A_states <- cleaned_covid_data[grepl(pattern = "A", 
                                     x = cleaned_covid_data$Province_State,
                                     ignore.case = FALSE),]

  # Using grepl to subset from cleaned_covid data using the pattern "A"
  # Targeting Province_State column
  # Not ignoring case so that it only uses first letters of state names

  # Could have used "^A" instead

# III

A_states %>% 
  ggplot(aes(x = as.Date(Last_Update), y = Deaths, color= Province_State)) +
  geom_point() +
  geom_smooth(method= "loess", se=FALSE) +
  theme_classic() +
  facet_grid(rows= vars(Province_State),
             scales = "free")

  # geom_smooth for the loess and se = FALSE to get rid of the error shading
  # as.Date because it was treating the dates as characters and not making line
  # Looked up facets to figure out. Row variables = the states.
  # Scales = free to make relative to data

  # Could have used facet_wrap
  # scales could also have been "free_x"
  # Would have been nice to do different color for line

# IV

Peak_Fatalities <- cleaned_covid_data %>% 
  group_by(Province_State) %>% 
  summarize(Maximum_Fatality_Ratio = max(Case_Fatality_Ratio, na.rm = TRUE)) %>% 
  arrange(desc(Maximum_Fatality_Ratio))

  # organizing new dataframe by group by state (rows), and summarizing fatality
  # max() to get maximum, na.rm to remove NAs because otherwise it's treating the whole set like NAs
  # arranging to get it into descending order using desc()

# V

Peak_Fatalities %>% 
  ggplot(aes(x = reorder(Province_State,-Maximum_Fatality_Ratio),
             y = Maximum_Fatality_Ratio,
             color = Province_State)) +
  geom_col() +
  theme_dark() +
  theme(axis.text.x = element_text(angle = 90,
                                        hjust = 1,
                                        vjust = .5))

  # reordering in x. Found reorder() and "-data" with google
  # geom_col not bar cause bar doesn't work great
  # theme_dark and colors cause it looks cool
  # Extra theme at end to alter element_text
  
  # Still not sure why element_text made me put hjust and vjust to get angle to work
  
# VI
cumulativeplot <- cleaned_covid_data %>% 
  group_by(Last_Update) %>% 
  summarize(TotalDeaths = sum(Deaths))

  # similar stuff to IV
  # summarizing deaths to get all states together

cumulativeplot %>% 
  ggplot(aes(x=Last_Update,y=TotalDeaths)) +
  geom_point() +
  theme_minimal()

  # Regular ol' plot

  # Oh shit, could have fixed x axis text. So it goes.
