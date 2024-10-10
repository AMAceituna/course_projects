# Exam 2
  # 3/21/2023

library(tidyverse)
library(easystats)
library(janitor)
library(modelr)

# 1. Read in the unicef data

u5mr <- read.csv("./unicef-u5mr.csv")

# 2. Get it into tidy format

view(u5mr)
  # Okay, so variables: Country(done), Year, u5mr... I think that's it.
  # This is a lot of columns
  # Oh, almost missed the extras after column 50. Continent and Region look ok rn

tidyu5mr <- u5mr %>% clean_names()

years <- tidyu5mr %>% colnames()
years
years <- years[years!="country_name"]
years <- years[years!="continent"]
years <- years[years!="region"]
  # There is definitely a more elegant way to do this
  # I just really don't want to type out 66 years of column names in pivot_longer

tidyu5mr <- tidyu5mr %>% pivot_longer(cols = years,
                                  names_to = "u5mr")
  # Way better looking now

tidyu5mr$u5mr <- tidyu5mr$u5mr %>% str_remove("u5mr.")
  # Years are just years now

tidyu5mr <- tidyu5mr %>% rename(year = u5mr)
tidyu5mr <- tidyu5mr %>% rename(u5mr = value)
  # And the year/u5mr variables are labeled correctly
tidyu5mr <- tidyu5mr %>% rename(country = country_name)
  # That one was just bugging me

tidyu5mr <- remove_missing(tidyu5mr)
tidyu5mr <- tidyu5mr %>% 
  mutate(yearnum = as.numeric(year))

# 3. Plot each country’s U5MR over time

tidyu5mr %>% ggplot(aes(x = yearnum, y = u5mr, group = country)) +
  geom_line() +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 90)) +
  scale_x_continuous(n.breaks = 5) +
  facet_wrap(vars(continent))
  

# 4. Save this plot as LASTNAME_Plot_1.png

MILLER_Plot_1 <- tidyu5mr %>% 
ggplot(aes(x = yearnum, y = u5mr, group = country)) +
  geom_line() +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 90)) +
  facet_wrap(vars(continent))

MILLER_Plot_1 %>% 
  ggsave(filename = "./MILLER_PLOT_1.png",device = "png", path = "./",dpi =1000)

# 5. Create another plot that shows the mean U5MR for all the countries within a given continent at each year

  # We'll make a new column of mean values
    # First let's get rid of these NAs
      # I worry a little about these representing zeroes
      # But seem more likely to be from before data collection began in those places
meanu5mr <- remove_missing(tidyu5mr)

  # Now let's mean it up
meanu5mr <- 
  meanu5mr %>% group_by(continent,year) %>%  
  summarize(mean_u5mr = mean(u5mr))

meanu5mr %>% 
  ggplot(aes(x = year, y = mean_u5mr, group = continent, color = continent)) +
  geom_line() +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 90))
  

# 6. Save that plot as LASTNAME_Plot_2.png

MILLER_PLOT_2 <- meanu5mr %>% 
  ggplot(aes(x = year, y = mean_u5mr, group = continent, color = continent)) +
  geom_line() +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 90))

MILLER_PLOT_2 %>% 
  ggsave(filename = "./MILLER_PLOT_2.png",device = "png", path = "./",dpi =1000)

# 7. Create three models of U5MR

modu5mr <- remove_missing(tidyu5mr)
modu5mr <- modu5mr %>% 
  mutate(yearnum = as.numeric(year))
  # Year as character was creating loads of factors
  # Better BIC
  
  # 1.
mod1 <- glm(data = modu5mr,
            formula = u5mr ~ continent)
summary(mod1)
  # 2.
mod2 <- glm(data = modu5mr,
            formula = u5mr ~ continent * yearnum)
summary(mod2)
  # 3.
mod3 <- glm(data = modu5mr,
            formula = u5mr ~ region * yearnum)
summary(mod3)
  # Suspect region is better predictor than continent
  # Canada and Honduras are not all that similar
    # Ngl I resent separating Southern Europe from Western Europe

# 8. Compare the three models with respect to their performance

compare_performance(mod1,mod2,mod3) %>% plot
  # Three looks pretty good. Region *is*  better than continent

# 9. Plot the 3 models’ predictions like so:
                   
predu5mr <- modu5mr %>% 
  add_column(mod1 = mod1$linear.predictors,mod2 = mod2$linear.predictors,mod3 = mod3$linear.predictors)

predu5mr <- predu5mr %>% 
  pivot_longer(cols = contains("mod"),
               names_to = "mod")

predu5mr %>% 
  ggplot(aes (x=yearnum, y=value, group = region, color = continent)) +
  geom_line() +
  theme_classic() +
  facet_wrap(vars(mod))
  # What's interesting is that the worst fatality rate places also decline the fastest

# 10. BONUS - Using your preferred model, predict what the U5MR would be for Ecuador in the year 2020.
  # The real value for Ecuador for 2020 was 13 under-5 deaths per 1000 live births. 
  # How far off was your model prediction???

ecuadorpred <- 
  data.frame(yearnum = c(2020),
             region = c("South America"))
predict(mod3, newdata = ecuadorpred)
  # South America has one of the steepest slopes so we've got a negative value
  # Presumably, South America is going to start having diminishing returns like the West
  # Actually becoming comparable to Eastern Europe

