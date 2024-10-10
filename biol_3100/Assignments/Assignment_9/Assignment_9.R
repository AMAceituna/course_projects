# Assignment 9
  # 3/23/2023

library(tidyverse)
library(modelr)
library(easystats)
library(GGally)

# Use the data set “/Data/GradSchool_Admissions.csv”

df <- read.csv("./GradSchool_Admissions.csv")

# You will explore and model the predictors of graduate school admission
  # the “admit” column is coded as 1=success and 0=failure (that’s binary, so model appropriately)
  # the other columns are the GRE score, the GPA, and the rank of the undergraduate institution, where I is “top-tier.”

view(df)
  # Realized this isn't great in markdown. Guess that's what glimpse is for.

df$admit <- as.logical(df$admit)
df$rank <- as.factor(df$rank)

glimpse(df)
  # That's better

df %>% 
  select(admit,gre,gpa,rank) %>% 
  ggpairs()
  # So gre, gpa, and rank all matter
  # Hard to tell, but I'd guess rank matters most

df %>% 
  ggplot(aes(x=admit,fill=rank)) +
  geom_bar(alpha=.5) +
  theme_minimal() +
  scale_y_continuous(n.breaks = 15) +
  labs(x = "Admit",
       y = "Count")
# Yeah yeah bar graphs bad. This shows it kinda well tho
# Rank really seems to be the thing

mod1 <- glm(data = df,
            formula = admit ~ gpa + gre)
summary(mod1)

mod2 <- glm(data = df,
            formula = admit ~ gpa * gre)
summary(mod2)
  # Seems too simple

mod3 <- glm(data = df,
           formula = admit ~ gre + gpa + rank,
           family = "binomial")
summary(mod3)
  # Feels better

mod4 <- glm(data = df,
            formula = admit ~ (gre * gpa) + rank,
            family = "binomial")
summary(mod4)
  # Could we make it better? Gre and Gpa sure seem pretty similar.
  # Overfitting?
    # I haven't taken stats yet, but am I right in assuming that AIC and BIC penalize overfitting?
    # Didn't totally understand the explanations when I looked it up, but seems like it.

compare_performance(mod1,mod2,mod3,mod4) %>% 
  plot()
  # None are amazing, but mod2 is looking pretty good.

preds <- add_predictions(df,mod3,type = "response")

preds %>% 
  ggplot(aes(x = gpa, y = pred, color = rank, group = rank))+
  geom_smooth() +
  theme_minimal() +
  labs(x = "GPA",
       y = "Predictions") +
  scale_colour_social()

preds %>% 
  ggplot(aes(x=gre,y=pred,color=rank,group=rank)) +
  geom_smooth() +
  theme_minimal() +
  labs(x = "GRE Score",
       y = "Predictions") +
  scale_colour_social()
  # Was trying to figure out a better way than this
  # pivot_wider, make whether its gpa or gre into a factor, and then facet_wrap that?
    # Pretty sure that would mess up the data

  # This data is depressing.

# Document your data explorations, figures, and conclusions in a reproducible R-markdown report

# That means I want to see, in your html report, your process of model evaluation and selection. Here’s an example

# Upload your self-contained R project, including knitted HTML report, to GitHub in your Assignment_9 directory
