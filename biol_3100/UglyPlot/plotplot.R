# Ugly Plot Contest

library(tidyverse)
library(GGally)
library(palmerpenguins)
library(plotrix)

penguins_raw %>% 
  ggplot(aes(y= `Sample Number`,
             x= `Culmen Depth (mm)`,
             fill= `Clutch Completion`)) +
  theme_minimal() +
  geom_hex(color="#f0e9d6") +
  labs(x= "hEIGHT OF pLOT(pLOT/pLOT)",
       y="wIDTH OF pLOT (pLOT/pLOT)",
       fill= "pLOTLYNESS") +
  theme(axis.text.x = element_text(angle = 120,
                                   hjust = 1,
                                   vjust = .5, 
                                   face = 'italic',
                                   color="#f6e5b3"),
        axis.text.y = element_text(angle = 150,
                                   face = 'bold',
                                   size=30,
                                   color='#f6e9c3'),
    axis.title.x = element_text(face='bold',
                                size=45,
                                color="#f3f3c5",
                                vjust = 10),
        axis.title.y = element_text(face='italic',
                                    size = 40,
                                    color = '#fffcf5'),
        axis.title = element_text(size = 25),
        panel.grid.major.x = element_line(color= "#f8f1dd"),
        plot.background = element_rect(color="#f9efe4",
                               fill="beige"),
    legend.background = element_rect(color= '#f0e0d0',fill = '#fbefce'),
    legend.text = element_text(color='#f3e9aa',
                               size=30,
                               angle=69,
                               hjust=1,
                               face= "italic"),
    legend.title = element_text(color='#f0e0d0',
                                face = "bold.italic",
                                size = 50,
                                vjust = 3,
                                angle = 5)) +
  scale_fill_manual(values = c("#f0e8ba","#f0f0b2","#F7E9B5")) +
  scale_y_reverse()+
  scale_x_reverse()+
  geom_smooth(color="#ece0bc")
  




data <- c(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
           1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
           1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
           1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1)

data %>%
   pie3D(radius = 3,
       height = 2,
       theta = 0.1,
       # col =,
       border = "beige",
       shade = 10,
       labels = c("M'kay?","Pie charts are bad"),
       explode = 1)

      