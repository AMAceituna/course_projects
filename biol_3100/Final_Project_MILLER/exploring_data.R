# Exploring Data

library(tidyverse)
library(dplyr)
library(easystats)
library(modelr)
library(GGally)
library(lubridate)

dfyear <- read.csv("./dfyear.csv")
dfyear21 <- read.csv("./dfyear21.csv")
dfyear22 <- read.csv("./dfyear22.csv")
dfyear23 <- read.csv("./dfyear23.csv")

# Let's just take a looksee

dfyear %>%
  select(impressions,engagements, shares) %>% 
  ggpairs() +
  theme(axis.text.x = element_text(angle = 90))
  # That's a little hard to read with so many observations.
  # It looks like there are 3 outliers consistently messing with things.
    # Those probably represent our posts that went really viral.
    # It looks like there is a cluster of 5 or so posts that were also quite
    # successful sitting behind them, but at the front of the pack.

dfyear %>% 
  ggplot(aes(x = impressions, y = engagements)) +
  geom_point() +
  theme_lucid() +
  theme(axis.text.x = element_text(angle = 90))

dfyear %>% 
  ggplot(aes(x = time, y = engagements)) +
  geom_point() +
  theme_lucid() +
  theme(axis.text.x = element_text(angle = 90))

dfyear %>% 
  ggplot(aes(x = date, y = engagements)) +
  geom_point() +
  theme_lucid() +
  theme(axis.text.x = element_text(angle = 90))
# Ehh.

dfyear %>% 
  ggplot(aes(x = impressions,color = isOc)) +
  geom_histogram(binwidth = 500) +
  theme_light() +
  theme(axis.text.x = element_text(angle = 0)) +
  labs(x = "Impressions",
       y = "# of Posts")

dfyear %>% 
  ggplot(aes(x = log10(impressions),color = isOc)) +
  geom_histogram() +
  theme_light() +
  theme(axis.text.x = element_text(angle = 0)) +
  labs(x = "Log10(Impressions)",
       y = "# of Posts")
# Oh this actually gud


# Can already get an idea


dfyear$engagements %>% mean()
dfyear22$engagements %>% median()
dfyear$impressions %>% sum()
dfyear$engagements %>% sum()
dfyear$shares %>% sum()

topimp <- dfyear %>% filter(impressions >= 10000)
topeng <- dfyear %>% filter(engagements >= 1000)
topshare <- dfyear %>% filter(shares >= 100)
topreach <- dfyear %>% filter(reach >= 10000)

topimp %>% count()
topimp %>% filter(isOc == TRUE) %>% 
  count()

topeng %>% count()
topeng %>% filter(isOc == TRUE) %>% 
  count()

topshare %>% count()
topshare %>% filter(isOc == TRUE) %>% 
  count()

topreach %>% count()
topreach %>% filter(isOc == TRUE) %>% 
  count()


dfyear %>% 
  group_by(isOc) %>% 
  summarize(count=n(), meanI = mean(impressions), medianI = median(impressions), sd(impressions))

dfyear %>% 
  group_by(isOc) %>% 
  summarize(count=n(), meanS = mean(shares), medianS = median(shares), sd(shares))

dfyear %>% 
  group_by(isOc) %>% 
  summarize(count=n(), meanE = mean(engagements), medianE = median(engagements), sd(engagements))

lratio <- dfyear %>%
  mutate(likeratio = likes/impressions)



library(prophet)
  # Let's see what this does

# prophet::generated_holidays
# view(generated_holidays)
  # Pretty cool. Goes all the way to 2044. Idk if it's useful for us, as we've only 
    # got a year of data. Maybe see how American holidays affect engagement?
    # That's not ideal. We have followers all over.

# dfyear %>% 
#   prophet()
  # It's just a little cranky cause daddy Zucc didn't hug it enough as a child.
dfyear$date <- dfyear$date %>% 
  as.POSIXct()

class(dfyear$date)

dfyear21$date <- dfyear21$date %>%
  as.POSIXct()

dfyear22$date <- dfyear22$date %>%
  as.POSIXct()

dfyear23$date <- dfyear23$date %>%
  as.POSIXct()

dfyear21$date %>% class()

# Log10 Impressions for dfyear

Pdfyear <- dfyear
Pdfyear$ds <- Pdfyear$date
Pdfyear$y <- log10(Pdfyear$impressions)
P <- Pdfyear %>% 
  prophet(yearly.seasonality = TRUE)
  # Can turn daily and yearly seasonality on and off. Awesome. (Off by default)

# "Predictions are made on a dataframe with a column ds containing the dates for 
# which predictions are to be made. The make_future_dataframe function takes 
# the model object and a number of periods to forecast and produces a suitable 
# dataframe. By default it will also include the historical dates so we can 
# evaluate in-sample fit."
  # Cool. Let's try that then.
  
future <- make_future_dataframe(P, periods = 365)
tail(future)

forecast <- predict(P, future)
tail(forecast)

plot(P,forecast)
  # Awesome. Not super useful rn, but let's see if we can get it to do weekly.
    # Now I wish we had a couple of years, go back and look at 2021? Done.

prophet_plot_components(P, forecast)
  # Super interesting, but is it because we post more on those days?

# Engagement dfyear

Pdfyeareng <- dfyear
Pdfyeareng$ds <- Pdfyeareng$date
Pdfyeareng$y <- log10(Pdfyear$engagements + 1)
  # Had to add 1 for the log to not freak out at 0 values.
Peng <- Pdfyeareng %>% 
  prophet(yearly.seasonality = TRUE)

futureE <- make_future_dataframe(Peng, periods = 365)

forecastE <- predict(Peng, futureE)

plot(Peng,forecastE,
     ylabel = "Log10(Engagements)",
     xlabel = "Date")

prophet_plot_components(Peng, forecastE)
  # Make compare graph


# Histogram of our '21 and '22 posts based on day of the week to compare.
  # Need lubridate

dfyear$weekday <- weekdays(dfyear$date)
dfyear$weekday <- as.factor(dfyear$weekday)
dfyear$weekday %>% levels()
dfyear$weekday <- factor(dfyear$weekday, levels=c('Sunday', 'Monday', 'Tuesday', 'Wednesday',
                                              'Thursday', 'Friday', 'Saturday'))
  # Weekday is factor and levels set. Days are in order now.

dfyear %>% 
  ggplot(aes(x = weekday, color = isOc)) +
  geom_histogram(stat="count") +
  theme_light() +
  theme(axis.text.x = element_text(angle = 90)) +
  labs(title = "2021-2023 Weekday Post Spread") +
  labs(x = "Weekday",
       y = "# of Posts")


# Check diff 21 and 22
  # This should be significantly different in 2022 because I stopped working graves
  # and started going to UVU
# After talking to my co-admins, I also realized that I'm the main one who does the
  # Resharing. David does some too, but Ben doesn't do almost any.

# 2021 Histogram

dfyear21$weekday <- weekdays(dfyear21$date)
dfyear21$weekday <- as.factor(dfyear21$weekday)
dfyear21$weekday %>% levels()
dfyear21$weekday <- factor(dfyear21$weekday, levels=c('Sunday', 'Monday', 'Tuesday', 'Wednesday',
                                                  'Thursday', 'Friday', 'Saturday'))

dfyear21 %>% 
  ggplot(aes(x = weekday, color = isOc)) +
  geom_histogram(stat="count") +
  theme_lucid() +
  theme(axis.text.x = element_text(angle = 90)) +
  labs(title = "2021 Weekday Post Spread")

# 2022 Histogram

dfyear22$weekday <- weekdays(dfyear22$date)
dfyear22$weekday <- as.factor(dfyear22$weekday)
dfyear22$weekday %>% levels()
dfyear22$weekday <- factor(dfyear22$weekday, levels=c('Sunday', 'Monday', 'Tuesday', 'Wednesday',
                                                      'Thursday', 'Friday', 'Saturday'))

dfyear22 %>% 
  ggplot(aes(x = weekday, color = isOc)) +
  geom_histogram(stat="count") +
  theme_lucid() +
  theme(axis.text.x = element_text(angle = 90)) +
  labs(title = "2022 Weekday Post Spread")

# Well it *is* different. 2021 is better distributed OC and nonOC. I'm guessing 
  # that I was using Facebook and sharing more consistently across the week because
  # I was on my phone at work. 2022 is distributed to the days I was studying.
  # OC and non almost look inversely proportional here.

# 2023 Histogram
  # This'll be weird. This semester killed David and I, but Ben was pretty free.

dfyear23$weekday <- weekdays(dfyear23$date)
dfyear23$weekday <- as.factor(dfyear23$weekday)
dfyear23$weekday %>% levels()
dfyear23$weekday <- factor(dfyear23$weekday, levels=c('Sunday', 'Monday', 'Tuesday', 'Wednesday',
                                                      'Thursday', 'Friday', 'Saturday'))

dfyear23 %>% 
  ggplot(aes(x = weekday, color = isOc)) +
  geom_histogram(stat="count") +
  theme_lucid() +
  theme(axis.text.x = element_text(angle = 90)) +
  labs(title = "2023 Weekday Post Spread") +
  labs(x = "Weekday",
       y = "# of Posts")


# Make all the graphs pretty

# Edit the writing up in markdown
  # Presentations are 5 minutes
  # "Keep it brief, explain like people are 5"

dfyear %>% 
  write.csv(file = "./dfyear.csv")

dfyear21 %>% 
  write.csv(file = "./dfyear21.csv")

dfyear22 %>% 
  write.csv(file = "./dfyear22.csv")

dfyear23 %>% 
  write.csv(file = "./dfyear23.csv")



