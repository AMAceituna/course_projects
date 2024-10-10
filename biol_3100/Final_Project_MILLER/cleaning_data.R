# Cleaning Data

library(tidyverse)
library(dplyr)
library(easystats)
library(janitor)
library(lubridate)
# library(hms)

# Facebook only lets you download 3 months at a time for some reason.
  # I want a full year. More observations is better.
apr <- read.csv("./raw_csvs/Apr-01-2022_Jun-30-2022.csv")
jan <- read.csv("./raw_csvs/Dec-31-2021_Mar-31-2022.csv")
  # hol on a sec
  head(jan)
  # Nevermind. Does not actually include an observation for Dec 31.
jul <- read.csv("./raw_csvs/Jul-01-2022_Sep-30-2022.csv")
oct <- read.csv("./raw_csvs/Oct-01-2022_Dec-30-2022.csv")

# Adding 2021 because want to use Prophet package seasonality
apr2 <- read.csv("./raw_csvs/Apr-01-2021_Jun-30-2021.csv")
jan2 <- read.csv("./raw_csvs/Dec-31-2020_Mar-31-2021.csv")
jul2 <- read.csv("./raw_csvs/Jul-01-2021_Sep-30-2021.csv")
oct2 <- read.csv("./raw_csvs/Oct-01-2021_Dec-30-2021.csv")

# Adding 2023 so far cause wanna see if that April bump holds
jan3 <- read.csv("./raw_csvs/Dec-31-2022_Mar-31-2023.csv")
apr3 <- read.csv("./raw_csvs/Apr-01-2023_Apr-30-2023.csv")

head(apr)
glimpse(apr)
# Wow this is going to be annoying
  # Why is my facebook in Spanish again?
  # Soy ehstoopeedo

apr <- janitor::clean_names(apr)
jan <- janitor::clean_names(jan)
jul <- janitor::clean_names(jul)
oct <- janitor::clean_names(oct)

apr2 <- janitor::clean_names(apr2)
jan2 <- janitor::clean_names(jan2)
jul2 <- janitor::clean_names(jul2)
oct2 <- janitor::clean_names(oct2)

apr3 <- janitor::clean_names(apr3)
jan3 <- janitor::clean_names(jan3)
  # Got rid of the tildes
  # Ahora es menos ehstoopeedo

dfyear22 <- rbind(jan, apr, jul, oct)
# dfyear21 <- rbind(jan2, apr2, jul2, oct2)
  # It appears that some of the 2021 data is missing a few variables
  # Fix by selecting first
apr2 %>% colnames()
jan2 %>% colnames()
oct2 %>% colnames()

# dfyear <- rbind(jan, apr, jul, oct, jan2, apr2, jul2, oct2)

# Got the full year of data (2022)
  # Let's get rid of some of these irrelevant/empty columns
  # Date and time ought to be split up too

# dfyear22 <- dfyear22 %>% remove_empty_columns()
  # Hmmm this needs a bit more. Easier to pick out what *is* relevant
dfyear22 %>% colnames()
dfyear22 <- dfyear22 %>% select(date_hour=hora_de_publicacion, impressions=impresiones, 
                                likes=me_gusta, shares=veces_compartido, 
                                total_clicks=total_de_clics, engagements=interacciones,
                                description=descripcion, other_clicks=otros_clics, 
                                photo_views=visualizaciones_de_fotos,
                                comments=comentarios, reach=personas_alcanzadas)

# The 2021 data is being annoying about variables so we gotta pare down the columns first
jan2 <- jan2 %>% select(date_hour=hora_de_publicacion, impressions=impresiones, 
                        likes=me_gusta, shares=veces_compartido, 
                        total_clicks=total_de_clics, engagements=interacciones,
                        description=descripcion, other_clicks=otros_clics, 
                        photo_views=visualizaciones_de_fotos,
                        comments=comentarios, reach=personas_alcanzadas)
  # Found the missing variables. The unique_negative_comments_hidden and _total.
    # That's okay. Wasn't planning anything for those, so can get rid of them in
    # the other dfs too. It is interesting data tho.

apr2 <- apr2 %>% select(date_hour=hora_de_publicacion, impressions=impresiones, 
                        likes=me_gusta, shares=veces_compartido, 
                        total_clicks=total_de_clics, engagements=interacciones,
                        description=descripcion, other_clicks=otros_clics, 
                        photo_views=visualizaciones_de_fotos,
                        comments=comentarios, reach=personas_alcanzadas)

jul2 <- jul2 %>% select(date_hour=hora_de_publicacion, impressions=impresiones, 
                        likes=me_gusta, shares=veces_compartido, 
                        total_clicks=total_de_clics, engagements=interacciones,
                        description=descripcion, other_clicks=otros_clics, 
                        photo_views=visualizaciones_de_fotos,
                        comments=comentarios, reach=personas_alcanzadas)

oct2 <- oct2 %>% select(date_hour=hora_de_publicacion, impressions=impresiones, 
                        likes=me_gusta, shares=veces_compartido, 
                        total_clicks=total_de_clics, engagements=interacciones,
                        description=descripcion, other_clicks=otros_clics, 
                        photo_views=visualizaciones_de_fotos,
                        comments=comentarios, reach=personas_alcanzadas)

# 2023 Data too
apr3 <- apr3 %>% select(date_hour=hora_de_publicacion, impressions=impresiones, 
                        likes=me_gusta, shares=veces_compartido, 
                        total_clicks=total_de_clics, engagements=interacciones,
                        description=descripcion, other_clicks=otros_clics, 
                        photo_views=visualizaciones_de_fotos,
                        comments=comentarios, reach=personas_alcanzadas)

jan3 <- jan3 %>% select(date_hour=hora_de_publicacion, impressions=impresiones, 
                        likes=me_gusta, shares=veces_compartido, 
                        total_clicks=total_de_clics, engagements=interacciones,
                        description=descripcion, other_clicks=otros_clics, 
                        photo_views=visualizaciones_de_fotos,
                        comments=comentarios, reach=personas_alcanzadas)

# Now it's less busy and has Anglo-ish column names.

dfyear21 <- rbind(jan2, apr2, jul2, oct2)
dfyear23 <- rbind(jan3, apr3)
dfyear <- rbind(dfyear21,dfyear22,dfyear23)

# Now we've got a df for each year and one for all of them. Perfect

# This selection bugs me for a few reasons.

  # It should be possible to differentiate what is original content or not by
    # what originates from other pages. The identificador_de_pagina (page id) and
    # nombre_de_la_pagina (page name) variables should show this. 
    # For some reason Facebook doesn't record page of origin in either of these.
    # Why bother putting in useful data when you could just write our own page name
    # Over and over instead?
    # Luckily we put "OC" (or variations) on our original content post descriptions.

  # I picked what actually had data and seemed like it *could* be relevant.
    # Still probably not going to use half these columns. Might select again later.
    # Edit: pared it down even more. Was getting unwieldy.

  # Edit: I put in the 2021 data to be able to work with Prophet more, but there's
    # a reason I excluded it to begin with. The page only started in March 2020.
    # Any major data skewing world events happening at the time? It started *after*
    # The pandemic began, so there's no before/after data. But there's also the
    # issue of 2021 with still being a small page with few followers and the weird
    # data that can come with small numbers and such.
    # Still think it's worth it though.

  # Edit: Added 2023 Jan-Apr
    # Many of the same caveats.

dfyear <- dfyear %>% 
  separate_wider_delim(date_hour, delim = " ", names = c("date", "time"))
  # Time already in 24hr time because fr why does anyone use anything else?

class(dfyear$date)
class(dfyear$time)
  # Needs fixing

# as.Date(dfyear$date)
# as.Date(dfyear$time)
  # This doesn't work because wrong format.

# Use as.POSIXct()

day <- "02/07/2022" %>% 
  as.POSIXct(format="%m/%d/%Y")

# POSIX internaitonal standard
  # R actually good at this, just needs right format
  # Can play with timezones in arguments (tz=gmt+- etc.)

# Tidyverse has lubridate package
lubridate::day(day)
lubridate::week(day)
  # There's also a holidays function for different cultures etc.
weekdays(day)
  # This super useful for checking weekends and such. Remember this!

dfyear$date <- dfyear$date %>% 
  as.POSIXct(format="%m/%d/%Y")
  # Awesome.
class(dfyear$date)
  # Okay gives a POSIXct class. I bet R will work with that, but let's make sure.
dfyear$date <- as.Date(dfyear$date)
  # Ahhh, gets ride of the timezone. Less cluttered at least.
class(dfyear$date)

dfyear$time <- dfyear$time %>% 
  as.POSIXct(format="%H:%M")

# dfyear$time <- as_hms(ymd_hms(dfyear$time))
  # This works with library(hms)
  # But it leaves the empty seconds and makes it a weird class

# sprintf("%02d:%02d", hour(dfyear$time), minute(dfyear$time))
  # This works without adding hms package, and it can even get rid of the minutes
  # But it makes it a character
  # Maybe it'll still work

dfyear$time <- strftime(dfyear$time, format="%H:%M")
  # Same as the last one. Maybe can get one of these to work somehow, but I've wasted
  # Too much time on it already.

# Edit: Need to do for new seperate 2021 and 2022 dfs.

# 2021
dfyear21 <- dfyear21 %>% 
  separate_wider_delim(date_hour, delim = " ", names = c("date", "time"))

dfyear21$date <- dfyear21$date %>% 
  as.POSIXct(format="%m/%d/%Y")

dfyear21$time <- dfyear21$time %>%
  as.POSIXct(format="%H:%M")

dfyear21$time <- strftime(dfyear21$time, format="%H:%M")

# 2022
dfyear22 <- dfyear22 %>% 
  separate_wider_delim(date_hour, delim = " ", names = c("date", "time"))

dfyear22$date <- dfyear22$date %>% 
  as.POSIXct(format="%m/%d/%Y")

dfyear22$time <- dfyear22$time %>% 
  as.POSIXct(format="%H:%M")

dfyear22$time <- strftime(dfyear22$time, format="%H:%M")

# 2023
dfyear23 <- dfyear23 %>% 
  separate_wider_delim(date_hour, delim = " ", names = c("date", "time"))

dfyear23$date <- dfyear23$date %>% 
  as.POSIXct(format="%m/%d/%Y")

dfyear23$time <- dfyear23$time %>% 
  as.POSIXct(format="%H:%M")

dfyear23$time <- strftime(dfyear23$time, format="%H:%M")


# We need a new variable to show what is or is not OC
  # Need to pick out character strings from the descriptions

dfyear$description %>% 
  unique()

oc <- grep("OC",dfyear$description)
oc2 <- grep("O.c",dfyear$description)
  # Should also pick up "O.c."
oc3 <- grep("oc", dfyear$description)
oc4 <- grep("O.C",dfyear$description)
oc5 <- grep("\\(O\\)",dfyear$description)
  # There was a hot minute where a certain admin thought it was funny to write "OC" as
  # dumb stuff like "Myth(O)poeti(C) homies where you at" inside the words with parentheses
    # ...it was me
oc6 <- grep("\\(o\\)",dfyear$description)
  # At least my stupidity knows *some* bounds

oc<-append(oc, oc2)
oc<-append(oc, oc3)
oc<-append(oc, oc4)
oc<-append(oc, oc5)
  # 'taint pretty, but it works.

oc <- oc %>% 
  unique()
  # Caught one of the descriptions with the word "social". Gotta deal with repeats.

dfyear$vectorific <- vectorific <- c(1:1490)
class(vectorific)
isOc <- vectorific %in% oc 

dfyear$isOc <-  isOc
  # Got it in there. Logical might be a problem, but it's there now.

# Edit: Need to do for 2021 and 2022

# 2021
oc <- grep("OC",dfyear21$description)
oc2 <- grep("O.c",dfyear21$description)
oc3 <- grep("oc", dfyear21$description)
oc4 <- grep("O.C",dfyear21$description)
oc5 <- grep("\\(O\\)",dfyear21$description)
oc6 <- grep("\\(o\\)",dfyear21$description)

oc<-append(oc, oc2)
oc<-append(oc, oc3)
oc<-append(oc, oc4)
oc<-append(oc, oc5)

oc <- oc %>% 
  unique()

dfyear21$vectorific <- vectorific <- c(1:668)
class(vectorific)
isOc <- vectorific %in% oc 

dfyear21$isOc <-  isOc

# 2022
oc <- grep("OC",dfyear22$description)
oc2 <- grep("O.c",dfyear22$description)
oc3 <- grep("oc", dfyear22$description)
oc4 <- grep("O.C",dfyear22$description)
oc5 <- grep("\\(O\\)",dfyear22$description)
oc6 <- grep("\\(o\\)",dfyear22$description)

oc<-append(oc, oc2)
oc<-append(oc, oc3)
oc<-append(oc, oc4)
oc<-append(oc, oc5)

oc <- oc %>% 
  unique()

dfyear22$vectorific <- vectorific <- c(1:693)
class(vectorific)
isOc <- vectorific %in% oc 

dfyear22$isOc <-  isOc

# 2023
oc <- grep("OC",dfyear23$description)
oc2 <- grep("O.c",dfyear23$description)
oc3 <- grep("oc", dfyear23$description)
oc4 <- grep("O.C",dfyear23$description)
oc5 <- grep("\\(O\\)",dfyear23$description)
oc6 <- grep("\\(o\\)",dfyear23$description)

oc<-append(oc, oc2)
oc<-append(oc, oc3)
oc<-append(oc, oc4)
oc<-append(oc, oc5)

oc <- oc %>% 
  unique()

dfyear23$vectorific <- vectorific <- c(1:129)
class(vectorific)
isOc <- vectorific %in% oc 

dfyear23$isOc <-  isOc


# Gonna need to manually input it if we want to show who made which posts.
  # That means manually scrolling the page's Facebook feed and writing who made what.
  # ...For 693 posts across a whole year.
  # Why doesn't Meta just record which admin made what in Business Suite?
  # The Zucc does not like to be questioned.
  # Edit: with all three years it would be 1490 posts. Sorry, but I'm not doing that.

# Prophet has made me wanna know how we do on different days of the week too
dfyear$weekday <- weekdays(dfyear$date)
dfyear21$weekday <- weekdays(dfyear21$date)
dfyear22$weekday <- weekdays(dfyear22$date)
dfyear23$weekday <- weekdays(dfyear23$date)


dfyear %>% 
  write.csv(file = "./dfyear.csv")

dfyear21 %>% 
  write.csv(file = "./dfyear21.csv")

dfyear22 %>% 
  write.csv(file = "./dfyear22.csv")

dfyear23 %>% 
  write.csv(file = "./dfyear23.csv")

# Just occurred to me that I could have used for loops for some of that. Oh well.