# IQBIO UPRRP Summer 2024
# R Carpentry 6/11/2024


#### Notes R ####

# ggplot ####
library(ggplot2)

getwd()

dir()
gapminder <- read.csv("gapminder_data.csv")
str(gapminder)

View(gapminder)

ggplot(data = gapminder, mapping = aes (x = year, y = lifeExp, group = country, color = continent)) +
  geom_line() +
  geom_point() +
  theme_minimal()

ggplot(data = gapminder[gapminder$continent == "Americas",], mapping = aes(x = gdpPercap, y = lifeExp, color = continent)) +
  geom_point(alpha = 0.5, color = "seagreen", size = 10) +
  scale_x_log10() +
  theme_minimal() +
  geom_smooth() +
  labs(title = "Le Plotte",
       x = "Mohnay",
       y = "Lifeness")


americas <- gapminder[gapminder$continent == "Americas",]

ggplot(data = americas, mapping = aes(x = year, y = lifeExp, color = continent)) +
  geom_line() + 
  facet_wrap( ~ country) +
  theme(axis.text.x = element_text(angle =60))


ggplot(data = americas, mapping = aes(x = year, y = lifeExp, color=continent)) +
  geom_line() + facet_wrap( ~ country) +
  labs(
    x = "Year",              # x axis title
    y = "Life expectancy",   # y axis title
    title = "Figure 1",      # main title of figure
    color = "Continent"      # title of legend
  ) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))


ggsave(filename = "results/lifeExp.png", plot = lifeExp_plot, width = 12, height = 10, dpi = 300, units = "cm")


ggplot(data = gapminder, mapping = aes(x = continent, y = lifeExp, color = continent)) +
  geom_boxplot() +
  facet_wrap( ~ year ) +
  labs(title = "Le Plotte",
       y = "Life Expectancy") +
  theme(axis.text.x = element_blank()) # Can remove labels like this

View(gapminder[gapminder$continent == "Oceania",])
# This doesn't seem very representative of Oceania...


