# Assignment 6

library(tidyverse)

dat <- read_csv("./Data/BioLog_Plate_Data.csv")

# 1.)

longdat <- dat %>% pivot_longer(col= starts_with("HR"),
                     names_to = "Hour" ,
                     values_to = "Absorbance")
# Right off the bat, hour is a variable and should be its own column

unique(longdat$`Sample ID`)
# Need the particular names of locations

# 2.)

waterdat <- longdat %>% mutate(Origin_Type = if_else(`Sample ID` %in% c("Soil_1", "Soil_2"), "soil", "water"))
# Uh. It works. Yeah. 

# 3.)

waterdat$Hour <- waterdat$Hour %>% str_remove("^Hr_")
# Make Hour values pretty

dilutiondat <- waterdat %>% filter(Dilution == "0.1")
# Almost didn't see this line. Just want 0.1 stuff

dilutiondat %>% 
  ggplot(aes(x = as.numeric(Hour), y = Absorbance, color= Origin_Type)) +
  geom_smooth(method= "loess", se=FALSE) +
  labs(x = "Time",
       y = "Absorbance",
       fill = "Type") +
  theme_classic() +
  facet_wrap(vars(Substrate))

# 4.)

library(gganimate)
library(plotly)

itonicdat <- waterdat %>% filter(Substrate == "Itaconic Acid")
# Getting it down to just the acid

welldat <- itonicdat %>% group_by(Dilution, `Sample ID`, Hour) %>% 
  summarize(Mean_absorbance = mean(Absorbance))
# Summarizing the right stuff. Needed the right things to mean.

welldat$Hour <- as.numeric(welldat$Hour)
# Not even this would make R like Hour. 

Anime <- welldat %>% 
  ggplot(aes(x = Hour, y = Mean_absorbance, color= `Sample ID`)) +
  geom_line() +
  transition_reveal(Hour) +
  labs(x = "Time",
       y = "Mean_Absorbance",
       fill = "Sample ID") +
  theme_classic() +
  facet_wrap(vars(Dilution))
  
animate(Anime)
# Transition_time absolutely would not work. No clue. Reveal does the same thing.
# R didn't like Hour for some reason. Idk. R is a spiteful god.



