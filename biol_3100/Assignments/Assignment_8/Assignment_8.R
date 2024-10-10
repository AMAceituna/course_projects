# Assignment 8

# 3/13/2023

library(modelr)
library(easystats)
library(broom)
library(tidyverse)
library(fitdistrplus)

# 1.

mushy <- read.csv("./mushroom_growth.csv")

# 2.
  # Ngl, I'm not entirely sure what this is asking for.
  # I'll just make some plots to explore around in the data.
    # GrowthRate is response, yeah?

ggplot(mushy, aes(x=Nitrogen,y=GrowthRate, color = Species)) + 
  geom_point() + 
  geom_smooth() +
  theme_minimal()
  # Not great, but there does seem to be a little trend
  # Cornucopia seems more distributed

ggplot(mushy, aes(x=Light, y=GrowthRate, color = Species)) + 
  geom_point() + 
  geom_smooth() +
  theme_minimal()
  # More light good, more light past 10 more good, and more light more good for cornucopiae
  # Light seems kind of exponential

ggplot(mushy, aes(x=Temperature,y=GrowthRate)) + 
  geom_point() + 
  geom_smooth() +
  theme_minimal()


# 3.

mod1 <- glm(data = mushy,
            formula = GrowthRate ~ Species)
  # Presumably different species grow differently
summary(mod1)

mod2 <- glm(data = mushy,
            formula = GrowthRate ~ Light * Nitrogen)
  # Atmospheric variables effect on growth
summary(mod2)

mod3 <- glm(data = mushy,
            formula = GrowthRate ~ Humidity * Temperature * Species)
  # Atmospheric variables interacting w/species effect on growth
summary(mod3)

mod4 <- glm(data = mushy,
            formula = GrowthRate ~ Humidity * Species)
summary(mod4)

compare_performance(mod1,mod2,mod3,mod4) %>% plot
  # mod3 seems pretty good. Relatively.

# 4.

mean(mod1$residuals^2)
  # A little surprised that this is this bad.
mean(mod2$residuals^2)

mean(mod3$residuals^2)
  
mean(mod4$residuals^2)
  # Apparently piling things in is good. 
  # I did try piling in all the factors at once, but the AIC and BIC didn't like that very much.

# 5.

mushydf <- mushy %>% 
  add_predictions(mod3) 
mushydf %>% dplyr::select("GrowthRate","pred")
  # This is certainly one of the models of all time

# 6.

mushydf2 = data.frame(Temperature = c(30,35,40,45,50,30,35,40,45,50,30,35,40,45,50,30,35,40,45,50), 
                      Humidity = c("Low","Low","Low","Low","Low","Low","Low","Low","Low","Low","High","High","High","High","High","High","High","High","High","High"),
                      Species = c("P.cornucopiae","P.cornucopiae","P.cornucopiae","P.cornucopiae","P.cornucopiae","P.ostreotus","P.ostreotus","P.ostreotus","P.ostreotus","P.ostreotus","P.cornucopiae","P.cornucopiae","P.cornucopiae","P.cornucopiae","P.cornucopiae","P.ostreotus","P.ostreotus","P.ostreotus","P.ostreotus","P.ostreotus"))
  # Making predictions. Having the 2 species together just didn't look like anything.

pred = predict(mod3, newdata = mushydf2)

hyp_preds <- data.frame(Temperature = mushydf2$Temperature,
                        Species = mushydf2$Species,
                        Humidity = mushydf2$Humidity,
                        pred = pred)

mushydf$PredictionType <- "Real"
hyp_preds$PredictionType <- "Mushythetical"

mushypreds <- full_join(mushydf,hyp_preds)

# 7.

mushypreds <- mushypreds %>% 
  mutate(dankness=paste(Humidity, Temperature,
                    sep =" "))
ggplot(mushypreds,aes(x=dankness,y=pred,color=PredictionType)) +
  geom_point() +
  geom_point(aes(y=GrowthRate),color="Black") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 60)) +
  labs(x = "Dankness(Humid*Temp)") +
  facet_wrap(vars(Species), scales = "free")
  # Needed color to show the predicted values
  # Okay it's not pretty, but the data was mostly categorical.



# 1.

  # I'm going to make a bold scientific claim that Mushrooms can't ungrow themselves.
    # Idk tho. Fungi are weird.
  # I assume that mushrooms also don't grow faster in a dry 50 C environment.
  # Models are models. A simple line isn't going to be able to truly predict very far out.
  # The temp collected was also only 20 or 25 which is a pretty small range to extrapolate from.

# 2.

  # The relationship with light in the second plot in #2 looked a little exponential.
https://study.com/skill/learn/transforming-nonlinear-models-to-linear-explanation.html
  # Well it's basic and not specifically about R, but a log() was the first thing that came to mind.
http://sthda.com/english/articles/40-regression-analysis/162-nonlinear-regression-essentials-in-r-polynomial-and-spline-regression-models/
  # This seems more like it but 1. I barely understand it and 2. #3 is asking for a "linear model" of nonlinear data

# 3.

nonlinear <- read.csv("./non_linear_relationship.csv")

nonlinear %>% 
  ggplot(aes(x=predictor,y=response)) +
  geom_point() +
  theme_minimal()
  # Well it certainly doesn't look linear

  # I'm not entirely sure what is being asked by "with a linear model"
  # Isn't any linear model of nonlinear data going to be way off?

  # You could just make it linear with glm and have a crappy model:
crappymod <- glm(data = nonlinear,
                 formula = response ~ predictor)
summary(crappymod)

  # Could just plot the log() of the response and make it linear that way
nonlinear %>% 
  ggplot(aes(x=predictor,y= log(response))) +
  geom_point() +
  geom_smooth() +
  theme_minimal()
  # Linear, but it seems like we've modified the data we want.

logmod <- glm(data = nonlinear,
                 formula = log(response) ~ predictor)
summary(logmod)
compare_performance(crappymod,logmod) %>% plot
  # Well, it's better in most ways.
