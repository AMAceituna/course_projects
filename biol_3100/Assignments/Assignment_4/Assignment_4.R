# Assignment 4

# Step 5 Plot

# There's some weird error when I load the .csv files Meta is giving me.
# I pasted some of the data into a new Excel, saved as a .csv, and used that instead

library(tidyverse)
library(GGally)

Results %>% 
  ggplot(aes(y= Page_Reach, x= Date, )) +
  geom_line() +
  theme_minimal()
