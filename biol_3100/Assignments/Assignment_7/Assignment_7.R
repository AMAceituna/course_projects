# Assignemnt 7

# 2/25/2023

library(tidyverse)
library(janitor)

ruhlijeon <- read.csv("./Utah_Religions_by_County.csv")

ruhlijeon <- ruhlijeon %>% clean_names()
# Okay that's a little nicer

ruhlijeon$county <- ruhlijeon$county %>% str_remove("County")
# Redundant and the long names were less readable

# So sect is a variable and needs to be its own column, yeah?
  # What about religious and non_religious? Part of sect variable?
    # non_religious can be considered a sect. religious is then implicit within values

ruhlijeon <- ruhlijeon %>% pivot_longer(cols = c("assemblies_of_god","episcopal_church",
                                    "pentecostal_church_of_god", "greek_orthodox",
                                    "lds", #how come this is abbreviated this one but not the others?
                                    "southern_baptist_convention","united_methodist_church",
                                    "buddhism_mahayana","catholic", "evangelical",
                                    "muslim", "non_denominational","orthodox",
                                    "non_religious"),
                                    names_to = "sect")
                                    # Could have done with -C() too

# The way these are grouped is idiotic. 
  # Why specify "mahayana" if there is only one buddhist sect?
  # If you have Greek Orthodox, then you have to say what the other Orthodox is. Russian? General Eastern?
  # Why have AoG, pentecostal, baptist, methodist, and then also evangelical? 
  # Is evangelical meant to be a general protestant group? Is this supposed to be part of the tidying?
    # All problems for whoever made the data to deal with

# How do you tell the difference between an inherent problem with data and a tidyness problem?
  # Practice and stop worrying about problems with someone else's data
# Fixing these problems would mean destroying some specificity of the data.Is that chill?
  # No. Dumb collection stays dumb.
# It seems like this is leading to trying to single out the Mormons somehow
  # Fixing bias is not part of tidying


# “Does population of a county correlate with the proportion of any specific religious group in that county?”

ruhlijeon <- ruhlijeon %>% rename(proportion = value)
  # Wasn't a fan of "value" as a column name

ruhlijeon %>% 
  ggplot(aes(x= pop_2010, y= proportion)) +
  geom_smooth() +
  theme(axis.text.x = element_text(angle = 90)) +
  facet_wrap(vars(sect),
             scales = "free")
  # It doesn't really seem like the population and sects correlate without free scales
    # Guess it depends on what we're calling significant. The Islamic proportion quadruples by 100K pop
    # There seem to be some points doing weird stuff at ~10K.
      # Some outlier area like Park City or Saint George? Probably too big
      # Maybe there's a bunch of people in Delta or Toole giving into religious anarchy

  # Linear version w/o free scales
ruhlijeon %>% 
  ggplot(aes(x= pop_2010, y= proportion)) +
  geom_smooth(method = "lm") +
  theme(axis.text.x = element_text(angle = 90)) +
  facet_wrap(vars(sect))
  # This way it doesn't look like much. non_religious goes down a little with pop though

# “Does proportion of any specific religion in a given county correlate with the proportion of non-religious people?”

ruhlijeon %>% 
  ggplot(aes(x = proportion, y = 1-religious)) +
  geom_point() +
  facet_wrap(vars(sect),
             scales = "free")
  # Hmmm. Not quite there.

ruhlijeon %>% 
  ggplot(aes(x = proportion/religious, y = 1-religious)) +
  geom_point() +
  geom_smooth() +
  facet_wrap(vars(sect),
             scales = "free")
  # This has a bit better feel. Should be proportion of particular religion vs non_religious
  # Okay, maybe geom_smooth is a little frivolous. The baptist plot is my favorite.

ruhlijeonNO0 <- ruhlijeon %>% filter(proportion > 0)
  # Like half the tidy data is zeroes. This seems unecessary

ruhlijeonNO0 %>% 
  ggplot(aes(x = proportion/religious, y = 1-religious)) +
  geom_point() +
  # geom_smooth() +
  facet_wrap(vars(sect),
             scales = "free")
  # This seems like the best so far
    # Most of these seem to be positively correlated with the proportion of non_religious
    # Ngl this data is all over the place. Could be anything
    # My guess is that it's not that *just* non_religious goes up with fewer lds, but that everything does
      # Although, it almost seems like in earlier graphs fewer lds meant fewer nonreligious, but more everything else


